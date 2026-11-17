# Cider

Swift packages for building UIKit and AppKit apps around `@Observable` models. Each module is its own library product, so a target imports only what it uses.

| Module | Platforms | Use |
| --- | --- | --- |
| `CocoaObservation` | macOS | `ObservingViewController` and `ObservingView`, AppKit versions of UIKit's `updateProperties()` hook. |
| `UIObservationBinding` | macOS, iOS, tvOS, visionOS, Mac Catalyst | Solid-style bindings from `@Observable` state to individual control properties, one way or two. |
| `Layout` | macOS, iOS, tvOS, visionOS, Mac Catalyst | An Auto Layout DSL, plus result-builder stack views. |
| `Configurable` | All | `configure { }` for objects and `configured { }` for value types. |
| `Cancellation` | All | `LatestTask`, which runs one async operation at a time for a feature model and drops superseded results. |
| `HexColor` | macOS, iOS, tvOS, visionOS, Mac Catalyst | `UIColor`, `NSColor` and SwiftUI `Color` from a `0xRRGGBB` literal. |
| `Cider` | iOS, Mac Catalyst | Legacy UIKit and Combine helpers from 2023, kept for reference until each piece is either modernized or removed. |

Cider needs Swift 6.4 tools and OS 27. Add the package and depend on the products you need:

```swift
.package(url: "https://github.com/markmals/Cider", branch: "main")
```

```swift
.product(name: "UIObservationBinding", package: "Cider")
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

A binding stores an expression and re-evaluates it whenever the `@Observable` state it read changes, the way Solid wraps a JSX expression in an effect. Control initializers take live arguments as autoclosures, so the expression reads like a plain value:

```swift
import UIObservationBinding

final class CounterViewController: UIViewController {
    let counter = Counter()

    override func viewDidLoad() {
        super.viewDidLoad()
        let counter = counter

        let label = UILabel(text: "The count is \(counter.count)")
        let add = UIButton(title: "Add one", action: UIAction { _ in counter.count += 1 })
        let limit = UISwitch(isOn: counter, \.isLimited)
        add.bind(\.isEnabled, to: !counter.isLimited || counter.count < 10)
        // …
    }
}
```

Capture models in a local, as `let counter = counter` does, and never through `self`. A bound expression that reads `self.counter` keeps the controller alive through its own view: controller → view → label → binding → controller. `UIAction` handlers need the same rule.

- A binding sets its value immediately, then again on a later main-actor turn after the state it read changes. Synchronous changes coalesce, and an equal value isn't reassigned, so a text field keeps its selection.
- Binding the same key path again replaces the earlier binding, which suits reused cells. Every binding ends when its object deallocates.
- `bind(to:_:)` drives anything a key path can't, such as a diffable data source: `dataSource.bind(to: model.snapshot) { $0.apply($1, animatingDifferences: true) }`.

| Platform | One way | Two way |
| --- | --- | --- |
| Both | `bind(_:to:)` on any `NSObject` | |
| UIKit | `UILabel(text:)`, `UIButton(title:action:)` | `UITextField(text:_:)`, `UISwitch(isOn:_:)`, `UISearchBar.bindText(to:_:)`, and `bind(_:to:_:sentBy:)` on any `UIControl` |
| AppKit | `NSTextField(label:)`, `NSButton(title:action:)` | `NSTextField(text:_:)`, `NSButton(checkboxWithTitle:isOn:_:)`, `NSSwitch(isOn:_:)`, and `bind(_:to:_:)` on any `NSControl` |

Two-way bindings write user edits back through a writable key path on the model. On AppKit, `bind(_:to:_:)` takes over the control's `target` and `action`; text fields use notifications instead, so their actions stay free.

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
        if let author { UILabel(text: author.name) }
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

## Cancellation

```swift
import Cancellation

@MainActor @Observable
final class SearchModel {
    private(set) var results: [Recipe] = []
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

Starting an operation cancels the running one. A superseded or cancelled operation never reaches its completion, even if it ignores cancellation and finishes anyway, so a late response can't overwrite newer state. A delivered error is a real failure, never the expected cancellation. Deallocating the `LatestTask` cancels its work. The module imports no UI framework, so domain and feature targets can use it.

## HexColor

```swift
import HexColor

let accent = UIColor(hex: 0x1E90FF)
let scrim = NSColor(hex: 0x000000, alpha: 0.4)
let badge = Color(hex: 0xFF3B30, opacity: 0.9)
```

Each initializer reads a 24-bit `0xRRGGBB` value as sRGB, with alpha or opacity as its own argument. A wider value, such as `0xRRGGBBAA`, traps instead of shifting every channel.

## Legacy Cider

The `Cider` product holds the original 2023 helpers, mostly Combine publishers and subscribers for UIKit controls. Each is kept for reference until it's modernized or removed. It builds only for UIKit platforms in the Swift 5 language mode, and it has never built for tvOS. `Herald/` and `PodcastExample/` are kept for the same reason and aren't part of the package build.

## Development

| Command | Runs |
| --- | --- |
| `mise run check` | swift-format and actionlint, then every test suite on macOS |
| `mise run test:ios` | Every test suite on an iOS Simulator, covering the UIKit code paths |
| `mise run build:platforms` | Each library except legacy Cider for iOS, tvOS, visionOS and Mac Catalyst, with warnings as errors |
| `mise run fmt` | swift-format on every modern source |

CI runs the same three gates on every push to `main` and every pull request.
