# Cider agent guide

Cider is a SwiftPM package of independently importable modules for UIKit and AppKit apps built around `@Observable` models. It's the shared, versioned home for the Apple infrastructure in [agentic-projects proposal 0002](https://github.com/markmals/agentic-projects/blob/design/composable-holotypes/proposals/0002-apple-microapps.md); read that proposal before changing how a module observes state or cancels work.

## Modules and boundaries

| Module | Imports | Holds |
| --- | --- | --- |
| `Cider` | Every other module | Only `@_exported import`s, one per product |
| `CocoaObservation` | AppKit, Observation | `ObservingViewController`, `ObservingView`: AppKit's missing `updateProperties()` |
| `UIObservationBinding` | UIKit or AppKit, Observation | Autoclosure bindings from `@Observable` state to control properties, and `UIBinding`/`@UIBindable` for two-way controls |
| `Layout` | UIKit or AppKit | Constraint operators, `ConstraintBuilder`, view helpers, stack view builders |
| `Configurable` | Foundation, plus UIKit or AppKit for conformances | `configure` and `configured` |
| `LatestTask` | Swift only | `LatestTask` for feature models |
| `HexColor` | UIKit or AppKit, SwiftUI | Hex color initializers |

- Apart from `Cider`, modules don't depend on each other. Add a dependency only when a module genuinely needs another's API, and say why in the commit.
- A new product needs a line in `Sources/Cider/Cider.swift` and a dependency on the `Cider` target. `mise run lint` fails without the line, and the build fails without the dependency.
- `LatestTask` stays free of UI frameworks, because domain and feature targets import it. The module and its main type share a name, so qualify the type as `LatestTask::LatestTask` when it's ambiguous.
- `CocoaObservation` stays AppKit-only. UIKit has a native `updateProperties()` on OS 26 and later, so don't build a UIKit version.

## Contracts the tests hold

- **Observation adapter** (`CocoaObservationTests`): first render, only properties read are tracked, dependency sets can change, synchronous changes and repeated invalidations coalesce, explicit invalidation and synchronous flush work, a flush is the only render it causes and tracks what it read, detach/reattach renders the latest state with one observation, a change pending at detach never renders, a view that leaves its window during an update stops observing, deallocation, and invalidation requested during an update.
- **Bindings** (`UIObservationBindingTests`): a binding evaluates and applies once when made and once for each change, on a later main-actor turn; it coalesces, skips equal values, doesn't lose a change made while it applies, is replaced when its key path is bound again, never applies once replaced even with a change pending, and ends with its object. Live expressions must capture models, never `self`, or the controller leaks through its own views. Two-way controls take a `UIBinding`: one from `$model` holds only the model, writes through a struct field land in the model, and local `@UIBinding` state is observable. Rebinding a key path, one way or two, ends the earlier binding's write-back. A control built by a binding initializer rebinds through its own method, such as `bind(text:)`, on a subclass too.
- **LatestTask** (`LatestTaskTests`): a superseded or cancelled operation never delivers, even when it ignores cancellation, and every delivered error is a real failure.

A change that alters one of these needs its test updated in the same commit, along with the README.

## Gates

```sh
mise run check            # swift-format, actionlint, Cider's re-exports, every suite on macOS
mise run test:ios         # every suite on an iOS Simulator
mise run build:platforms  # every library for iOS, tvOS, visionOS, Mac Catalyst
```

Run `check` for every change. A change to UIKit code also needs `test:ios` and `build:platforms`, because `swift test` only compiles the macOS side. CI runs all three.

## Conventions

- Swift 6 language mode, Swift 6.4 tools and an OS 27 floor. Every target treats warnings as errors through `strict` in `Package.swift`.
- Gate platform code with `#if os(macOS)` for AppKit and `#elseif os(iOS) || os(tvOS) || os(visionOS)` for UIKit. Mac Catalyst is `os(iOS)`.
- Tests use Swift Testing. Shared polling helpers live in `TestSupport`; gate AppKit test files with `#if os(macOS)` and UIKit ones with the UIKit condition.
- Format with `mise run fmt` before committing.
- Commit subjects are plain imperative sentences without a scope prefix, matching the history: "Add the Layout module".

## Pitfalls already hit

- A key path rooted in a convenience initializer's dynamic `Self` crashes at runtime with "could not demangle keypath type". Name the root type, as `bind(text:)` does with `\UILabel.text`.
- A key path's root type is part of its identity: `\TitleLabel.text` and `\UILabel.text` are different binding keys. Key a control's own bindings on the framework class. A key path's description is no identity at all: for equal key paths it differs between modules in optimized builds.
- In an `NSObject` subclass, `#selector(Type.perform(_:))` resolves to NSObject's `performSelector:`. Name action methods something else.
- UIKit's SDK isolates `NSLayoutAnchor` and `NSLayoutConstraint.priority` to the main actor, and AppKit's doesn't. Code that compiles on macOS can still warn on UIKit.
- `xcodebuild build` given several `-destination` flags builds nothing and exits 0, and it ignores the manifest's `treatAllWarnings`.
- AppKit controls send actions through `NSApp`, which a `swift test` process doesn't create; target-action tests call `NSApplication.shared` first.
- Swift Testing's `#expect` treats a `rethrows` call with a key-path argument as throwing; pass a closure instead.
- `withContinuousObservation` doesn't suit either loop here, so both use a one-shot `withObservationTracking(options:)` and schedule the next run themselves. Releasing a continuous token still delivers one more callback when a change was pending, it leaves its tracking registered with the model until the model next changes, and it can't track a run made outside its closure, such as a synchronous flush or a binding's first apply.
- A one-shot `withObservationTracking(options:)` can't be cancelled from outside, and stays registered with the model until one of the properties it read changes: about 750 bytes each, and all of them run inside the setter that finally fires them. To cancel one, have the tracked closure also read a private `@Observable` counter and bump that counter, as `TrackingCancellation` does; the callback tells the bump from a model change with `event.matches(_:)`.
- Observation tracking registers when its closure returns, so a change made inside the closure is never reported. Keep writes out of tracked closures: a binding tracks only its expression and applies the result afterwards.

## Where the time goes

Measured in a release build on Apple silicon, with 1,000 bindings reading one model property. Treat the figures as orders of magnitude, and measure again before acting on them.

- A binding takes about 4 µs to make and about 2.4 KB while it lives. A change costs each binding that read it about 0.6 µs inside the model's setter, where Observation runs the tracking's callback, and about 0.8 µs more on the next main-actor turn to evaluate and apply.
- A third of the setter's share pays for `TrackingCancellation`, which doubles what Observation registers for each binding. It earns that: a tracking left uncancelled keeps about 750 bytes, and costs about 2.5 µs inside a later setter, for every binding ever released.
- If a profile shows a setter or a turn dominated by bindings, first move that screen's properties into one `updateProperties()`: one tracking costs one registration and one turn however many properties it writes. After that, batch the bindings. Each `BindingObservation` starts its own `Task` for every change; queueing them into one shared main-actor flush per turn took about 15% off both figures in a prototype.
- `replaceArrangedSubviews(with:)` moves each view at most once and finds a misplaced view with a linear scan, so it's quadratic in the views that move. That suits a stack view of dozens of views, not a list of hundreds of rows.
