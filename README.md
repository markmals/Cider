# Cider

A Swift package for building UIKit and AppKit apps around `@Observable` models. Each module is its own library product, so a target imports only what it uses; the `Cider` product re-exports all of them for a target that wants everything.

| Module | Use |
| --- | --- |
| `Cider` | Re-exports every module below, so `import Cider` brings them all in. |
| `CocoaObservation` | `ObservingViewController` and `ObservingView`, AppKit versions of UIKit's `updateProperties()` hook. macOS only. |
| `UIObservationBinding` | Solid-style bindings from `@Observable` state to individual control properties, one way or two, through `UIBinding` and `@UIBindable`. |
| `Layout` | An Auto Layout DSL, plus result-builder stack views. |
| `Configurable` | `configure { }` for objects and `configured { }` for value types. |
| `LatestTask` | `LatestTask`, which runs one async operation at a time for a feature model and drops superseded results. |
| `HexColor` | `UIColor`, `NSColor` and SwiftUI `Color` from a `0xRRGGBB` literal. |

Every module builds for macOS, iOS, tvOS, visionOS and Mac Catalyst, with the platform exceptions noted below. Cider needs Swift 6.4 tools and OS 27. Add the package, then depend on `Cider` for everything or on the individual products you need:

```swift
.package(url: "https://github.com/markmals/Cider", branch: "main")
```

```swift
.product(name: "Cider", package: "Cider")                 // import Cider
.product(name: "UIObservationBinding", package: "Cider")  // import UIObservationBinding
```

## CocoaObservation

UIKit on iOS, tvOS, and visionOS 26 already tracks the `@Observable` properties read in `updateProperties()`. AppKit has no equivalent, so subclass `ObservingViewController` or `ObservingView` and override `updateProperties()`:

```swift
import CocoaObservation

final class RecipeViewController: ObservingViewController {
    let model: RecipeModel

    override func updateProperties() {
        super.updateProperties()
        titleField.stringValue = model.title
        favoriteButton.state = model.isFavorite ? .on : .off
    }
}
```

The properties read in `updateProperties()` are its dependencies. Changing one re-runs it on a later main-actor turn, and synchronous changes coalesce into a single update. That turn comes from SE-0506 continuous observation and isn't tied to the layout pass, so keep geometry in `layout()` and `viewWillLayout()`.

- A controller observes from `viewDidLoad()` until it deallocates. A view observes only while it's in a window, and moving it back into one renders the latest state.
- `setNeedsUpdateProperties()` schedules an update with no model change. `updatePropertiesIfNeeded()` runs a pending update synchronously, for example to paint current state before revealing a view. A model change on its own isn't pending for `updatePropertiesIfNeeded()`; it arrives asynchronously.
- `updateProperties()` should only copy model state into views. Don't do I/O, start tasks, or write to the observed model there.

## UIObservationBinding

A binding stores an expression and re-evaluates it whenever the `@Observable` state it read changes, the way Solid wraps a JSX expression in an effect. One-way control initializers take live arguments as autoclosures, so the expression reads like a plain value. Two-way controls take a `UIBinding`, which `@UIBindable` hands out as `$model.property`:

```swift
import UIObservationBinding

final class CounterViewController: UIViewController {
    @UIBindable var counter = Counter()

    override func viewDidLoad() {
        super.viewDidLoad()
        let counter = counter

        let label = UILabel(text: "The count is \(counter.count)")
        let add = UIButton(title: "Add one", action: UIAction { _ in counter.count += 1 })
        let limit = UISwitch(isOn: $counter.isLimited)
        add.bind(\.isEnabled, to: !counter.isLimited || counter.count < 10)
        // …
    }
}
```

Capture models in a local, as `let counter = counter` does, and never through `self`. A live expression that reads `self.counter` keeps the controller alive through its own view: controller → view → label → binding → controller. `UIAction` handlers need the same rule. `$counter.isLimited` is safe as written: the binding holds the model, not the controller.

- A binding sets its value immediately, then again on a later main-actor turn after the state it read changes. Synchronous changes coalesce, and an equal value isn't reassigned, so a text field keeps its selection.
- Binding the same key path again replaces the earlier binding, which suits reused cells. The earlier binding never applies again, and a two-way one stops writing back, whether the new binding is one way or two. Every binding ends when its object deallocates.
- `bind(to:_:)` drives anything a key path can't, such as a diffable data source: `dataSource.bind(to: model.snapshot) { $0.apply($1, animatingDifferences: true) }`.

| Platform | One way | Two way |
| --- | --- | --- |
| Both | `bind(_:to:)` on any `NSObject` | |
| UIKit | `UILabel(text:)`, `UIButton(title:action:)` | `UITextField(text:)`, `UISwitch(isOn:)`, `bind(text:)` on text fields and search bars, and `bind(_:to:sentBy:)` on any `UIControl` |
| AppKit | `NSTextField(label:)`, `NSButton(title:action:)` | `NSTextField(text:)`, `NSButton(checkboxWithTitle:isOn:)`, `NSSwitch(isOn:)`, `bind(text:)` on text fields, and `bind(_:to:)` on any `NSControl` |

tvOS has no `UISwitch`, and its search text field isn't a `UITextField`, so `UISwitch(isOn:)` and the search bar's `bind(text:)` aren't available there.

`UIBinding` is SwiftUI's `Binding` for UIKit and AppKit, modeled on Point-Free's swift-navigation. Besides `$model.property`, `$model.filters.showsDrafts` reaches into a struct, `UIBinding(get:set:)` wraps any storage, `.constant(_:)` ignores writes, and `@UIBinding var isPlaying = false` declares local state that controls and live expressions observe. On AppKit, `bind(_:to:)` takes over the control's `target` and `action`; text fields use notifications instead, so their actions stay free.

Bindings and `updateProperties()` run on the same observation machinery at different granularity. Bind a property when one expression determines it. Use `updateProperties()` when several properties must change together in one pass, or when the update adds and removes views.

## Layout

```swift
import Layout

header.layout {
    $0.topAnchor == view.safeAreaLayoutGuide.topAnchor + 16
    $0.leadingAnchor == view.leadingAnchor + 20
    $0.trailingAnchor <= view.trailingAnchor - 20
    $0.widthAnchor == 600 ~ .defaultHigh
}

avatar.frame(48)
content.pin(to: container, insets: .init(top: 8, leading: 16, bottom: 8, trailing: 16))
```

`layout { }` turns off `translatesAutoresizingMaskIntoConstraints` and activates the constraints it builds. `pin(to:insets:)` takes `NSDirectionalEdgeInsets`, so leading and trailing insets flip in right-to-left layouts, and `pinned(to:insets:)` returns the view to end a construction chain. Set a priority with `~` before activation; switching an active constraint between required and optional throws.

Stack views take their arranged subviews from a result builder that accepts views, arrays, `if`/`else` and `for` loops:

```swift
let row = UIStackView(axis: .horizontal, alignment: .center, spacing: 12) {
    artwork.frame(60)
    UIStackView(axis: .vertical, spacing: 4) {
        titleLabel
        if showsAuthor { authorLabel }
    }
    UIView.spacer()
}
```

`NSStackView(orientation:alignment:distribution:spacing:arrangedSubviews:)` is the AppKit equivalent; a `nil` setting keeps `NSStackView`'s default. Both have `addArrangedSubviews`, `replaceArrangedSubviews(with:)` and `removeAllArrangedSubviews()`, which leaves each view's own constraints, such as a fixed size, in place.

## Configurable

```swift
import Configurable

let buy = UIButton().configure {
    $0.configuration = .filled().configured { $0.title = "Buy Now" }
    $0.layer.cornerCurve = .continuous
}
```

Every `NSObject` gets `configure(_:)`, which sets the instance up in place and returns it. `ValueConfigurable` types get `configured(_:)`, which returns a changed copy and leaves the original alone. Diffable data source snapshots and UIKit's button, list content and background configurations conform already; conform your own value types directly.

## LatestTask

```swift
import LatestTask

@MainActor @Observable
final class SearchModel {
    private(set) var results: [Recipe] = []
    @ObservationIgnored private let service: RecipeService
    @ObservationIgnored private let latestSearch = LatestTask<[Recipe]>()

    func search(for query: String) {
        latestSearch.run { [service] in
            try await service.recipes(matching: query)
        } completion: { [weak self] result in
            self?.results = (try? result.get()) ?? []
        }
    }
}
```

Starting an operation cancels the running one. A superseded or cancelled operation never reaches its completion, even if it ignores cancellation and finishes anyway, so a late response can't overwrite newer state. A delivered error is a real failure, never the expected cancellation. Deallocating the `LatestTask` cancels its work. The module imports no UI framework, so domain and feature targets can use it, and `LatestTask::LatestTask` names the type wherever the module's name would make `LatestTask` ambiguous.

## HexColor

```swift
import HexColor

let accent = UIColor(hex: 0x1E90FF)              // UIKit
let scrim = NSColor(hex: 0x000000, alpha: 0.4)   // AppKit
let badge = Color(hex: 0xFF3B30, opacity: 0.9)   // SwiftUI
```

Each initializer reads a 24-bit `0xRRGGBB` value as sRGB, with alpha or opacity as its own argument. A wider value, such as `0xRRGGBBAA`, traps instead of shifting every channel.

## Development

| Command | Runs |
| --- | --- |
| `mise run check` | swift-format, actionlint and the `Cider` re-export check, then every test suite on macOS |
| `mise run test:ios` | Every test suite on an iOS Simulator, covering the UIKit code paths |
| `mise run build:platforms` | Every library for iOS, tvOS, visionOS and Mac Catalyst, with warnings as errors |
| `mise run fmt` | swift-format on every Swift source |

CI runs the same three gates on every push to `main` and every pull request. [`AGENTS.md`](AGENTS.md) covers module boundaries, the contracts the tests hold, and the platform pitfalls found so far.
