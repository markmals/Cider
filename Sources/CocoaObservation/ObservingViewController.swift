#if os(macOS)
import AppKit

/// An `NSViewController` with UIKit's `updateProperties()` model-observation hook.
///
/// Observation starts in `viewDidLoad()` and lasts until the controller deallocates, whether
/// or not its view is in a window.
@MainActor
open class ObservingViewController: NSViewController {
    private lazy var propertyUpdates = PropertyUpdateLoop { [weak self] in
        self?.updateProperties()
    }

    /// Override to project `@Observable` state into view properties; call `super`.
    ///
    /// The `@Observable` properties read here are the dependencies: changing any of them re-runs
    /// this method on a later main-actor turn, and synchronous changes coalesce into one call.
    /// That turn is not tied to the layout pass. Keep it cheap: no I/O, no new tasks, and no
    /// writes to the observed model.
    open func updateProperties() {}

    /// Schedules `updateProperties()` on the next observation turn, even with no model change.
    public final func setNeedsUpdateProperties() {
        propertyUpdates.setNeedsUpdate()
    }

    /// Runs `updateProperties()` now if `setNeedsUpdateProperties()` requested an update or no
    /// update has run yet.
    ///
    /// A model change alone doesn't make an update pending here; it arrives asynchronously.
    public final func updatePropertiesIfNeeded() {
        propertyUpdates.updateIfNeeded()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        propertyUpdates.start()
    }
}
#endif
