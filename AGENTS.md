# Cider agent guide

Cider is a SwiftPM package of independently importable modules for UIKit and AppKit apps built around `@Observable` models. It's the shared, versioned home for the Apple infrastructure in [agentic-projects proposal 0002](https://github.com/markmals/agentic-projects/blob/design/composable-holotypes/proposals/0002-apple-microapps.md); read that proposal before changing how a module observes state or cancels work.

## Modules and boundaries

| Module | Imports | Holds |
| --- | --- | --- |
| `CocoaObservation` | AppKit, Observation | `ObservingViewController`, `ObservingView`: AppKit's missing `updateProperties()` |
| `UIObservationBinding` | UIKit or AppKit, Observation | Autoclosure bindings from `@Observable` state to control properties |
| `Layout` | UIKit or AppKit | Constraint operators, `ConstraintBuilder`, view helpers, stack view builders |
| `Configurable` | Foundation, plus UIKit or AppKit for conformances | `configure` and `configured` |
| `LatestTask` | Swift only | `LatestTask` for feature models |
| `HexColor` | UIKit or AppKit, SwiftUI | Hex color initializers |

- Modules don't depend on each other. Add a dependency only when a module genuinely needs another's API, and say why in the commit.
- `LatestTask` stays free of UI frameworks, because domain and feature targets import it. The module and its main type share a name, so qualify the type as `LatestTask::LatestTask` when it's ambiguous.
- `CocoaObservation` stays AppKit-only. UIKit has a native `updateProperties()` on OS 26 and later, so don't build a UIKit version.
- The `Cider` target, `Herald/` and `PodcastExample/` are frozen legacy code kept for reference. Don't edit, format or extend them. Bring a piece forward by porting it into a modern module, and only with the owner's agreement.

## Contracts the tests hold

- **Observation adapter** (`CocoaObservationTests`): first render, only properties read are tracked, dependency sets can change, synchronous changes coalesce, explicit invalidation and synchronous flush work, detach/reattach renders the latest state with one observation, deallocation, and invalidation requested during an update.
- **Bindings** (`UIObservationBindingTests`): a binding sets its value immediately and updates on a later main-actor turn, coalesces, skips equal values, is replaced when its key path is bound again, and ends with its object. Live expressions must capture models, never `self`, or the controller leaks through its own views. Two-way controls take a `UIBinding`: one from `$model` holds only the model, writes through a struct field land in the model, and local `@UIBinding` state is observable.
- **LatestTask** (`LatestTaskTests`): a superseded or cancelled operation never delivers, even when it ignores cancellation, and every delivered error is a real failure.

A change that alters one of these needs its test updated in the same commit, along with the README.

## Gates

```sh
mise run check            # swift-format, actionlint, every suite on macOS
mise run test:ios         # every suite on an iOS Simulator
mise run build:platforms  # each modern library for iOS, tvOS, visionOS, Mac Catalyst
```

Run `check` for every change. A change to UIKit code also needs `test:ios` and `build:platforms`, because `swift test` only compiles the macOS side. CI runs all three.

## Conventions

- Swift 6 language mode, Swift 6.4 tools and an OS 27 floor. Every modern target treats warnings as errors through `strict` in `Package.swift`.
- Gate platform code with `#if os(macOS)` for AppKit and `#elseif os(iOS) || os(tvOS) || os(visionOS)` for UIKit. Mac Catalyst is `os(iOS)`.
- Tests use Swift Testing. Shared polling helpers live in `TestSupport`; gate AppKit test files with `#if os(macOS)` and UIKit ones with the UIKit condition.
- Format with `mise run fmt` before committing.
- Commit subjects are plain imperative sentences without a scope prefix, matching the history: "Add the Layout module".

## Pitfalls already hit

- A key path rooted in a convenience initializer's dynamic `Self` crashes at runtime with "could not demangle keypath type". Upcast first: `(self as UILabel).bind(\.text, to: …)`.
- In an `NSObject` subclass, `#selector(Type.perform(_:))` resolves to NSObject's `performSelector:`. Name action methods something else.
- UIKit's SDK isolates `NSLayoutAnchor` and `NSLayoutConstraint.priority` to the main actor, and AppKit's doesn't. Code that compiles on macOS can still warn on UIKit.
- `xcodebuild build` given several `-destination` flags builds nothing and exits 0, and it ignores the manifest's `treatAllWarnings`.
- AppKit controls send actions through `NSApp`, which a `swift test` process doesn't create; target-action tests call `NSApplication.shared` first.
- Swift Testing's `#expect` treats a `rethrows` call with a key-path argument as throwing; pass a closure instead.
