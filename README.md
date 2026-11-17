# Cider

Swift packages for building UIKit and AppKit apps. Each module is its own library product, so a target imports only what it uses.

| Module | Platforms | Use |
| --- | --- | --- |
| `CocoaObservation` | macOS 26+ | `ObservingViewController` and `ObservingView`, AppKit versions of UIKit's `updateProperties()` hook for `@Observable` models. |
| `Layout` | macOS, iOS, tvOS, visionOS, Mac Catalyst | An Auto Layout DSL: anchor operators, a constraint result builder, and `layout`, `frame`, and `pin` helpers for views. |
| `Cider` | iOS, tvOS, Mac Catalyst | Legacy UIKit and Combine helpers from 2023, kept for reference until each piece is either modernized or removed. It builds only in the Swift 5 language mode, and it fails to build for tvOS. |

Add the package and depend on the products you need:

```swift
.package(url: "https://github.com/markmals/Cider", branch: "main")
```

```swift
.product(name: "CocoaObservation", package: "Cider")
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

The properties read in `updateProperties()` are its dependencies. Changing one re-runs it on a later main-actor turn, and synchronous changes coalesce into a single update. That turn comes from an `Observations` loop and isn't tied to the layout pass, so keep geometry in `layout()` and `viewWillLayout()`.

- A controller observes from `viewDidLoad()` until it deallocates. A view observes only while it's in a window, and moving it back into one renders the latest state.
- `setNeedsUpdateProperties()` schedules an update with no model change. `updatePropertiesIfNeeded()` runs a pending update synchronously, for example to paint current state before revealing a view. A model change on its own isn't pending for `updatePropertiesIfNeeded()`; it arrives asynchronously.
- `updateProperties()` should only copy model state into views. Don't do I/O, start tasks, or write to the observed model there.

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

`layout { }` turns off `translatesAutoresizingMaskIntoConstraints` and activates the constraints it builds. `pin(to:insets:)` takes `NSDirectionalEdgeInsets`, so leading and trailing insets flip in right-to-left layouts. Set a priority with `~` before activation; switching an active constraint between required and optional throws.

## Development

```sh
swift test
```

`swift test` runs on macOS. To build the UIKit platforms, run `xcodebuild -scheme Layout -destination 'generic/platform=iOS Simulator' build`.
