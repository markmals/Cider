#if os(macOS)
import AppKit

/// An `NSView` with UIKit's `updateProperties()` model-observation hook.
///
/// The view observes only while it's in a window. Moving it back into a window renders the
/// latest state and resumes tracking.
@MainActor
open class ObservingView: NSView {
    private lazy var propertyUpdates = PropertyUpdateLoop { [weak self] in
        self?.updateProperties()
    }

    /// Override to project `@Observable` state into subview properties; call `super`.
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

    /// Runs `updateProperties()` now if `setNeedsUpdateProperties()` requested an update, no
    /// update has run yet, or the view has left a window since the last update.
    ///
    /// A model change alone doesn't make an update pending here; it arrives asynchronously.
    public final func updatePropertiesIfNeeded() {
        propertyUpdates.updateIfNeeded()
    }

    override open func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if window == nil {
            propertyUpdates.stop()
        } else {
            propertyUpdates.start()
        }
    }
}
#endif
