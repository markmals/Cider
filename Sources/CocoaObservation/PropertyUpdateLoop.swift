#if os(macOS)
import Observation

/// Runs a render closure again whenever an `@Observable` property it read changes: on a later
/// main-actor turn, with synchronous changes coalesced into one render.
///
/// Each render runs under a one-shot SE-0506 observation tracking, which the next change uses
/// up. The loop cancels a tracking it no longer wants, so the model never holds more than one.
@MainActor
final class PropertyUpdateLoop {
    private let render: @MainActor () -> Void
    private let cancellation = TrackingCancellation()
    private var isObserving = false
    private var needsUpdate = true
    private var isUpdating = false
    private var isUpdateScheduled = false
    /// Counts tracked renders, so a change reported by an earlier render's tracking can be told
    /// from one the latest render hasn't shown.
    private var trackedRenders: UInt64 = 0

    init(render: @escaping @MainActor () -> Void) {
        self.render = render
    }

    isolated deinit {
        cancellation.cancel()
    }

    func start() {
        guard !isObserving else { return }
        isObserving = true
        // Anything rendered while stopped went untracked, so the first turn renders again.
        needsUpdate = true
        scheduleUpdate()
    }

    func stop() {
        isObserving = false
        cancellation.cancel()
        // Changes made while stopped go unobserved, so a flush before the restarted loop's first
        // turn must still render.
        needsUpdate = true
    }

    func setNeedsUpdate() {
        needsUpdate = true
        if isObserving, !isUpdating { scheduleUpdate() }
    }

    func updateIfNeeded() {
        guard needsUpdate else { return }
        update()
    }

    private func update() {
        guard !isUpdating else { return }
        isUpdating = true
        needsUpdate = false
        // A flush renders while the previous render's tracking is still registered.
        cancellation.cancel()
        if isObserving {
            renderTracked()
        } else {
            render()
        }
        isUpdating = false
        // The render can stop the loop itself, by taking its view out of the window; the
        // tracking it has just registered goes too.
        if !isObserving { cancellation.cancel() }
        if needsUpdate, isObserving { scheduleUpdate() }
    }

    private func renderTracked() {
        let ordinal = trackedRenders &+ 1
        withObservationTracking(options: [.didSet]) {
            cancellation.arm()
            render()
        } onChange: { [weak self] event in
            // Cancelling triggers the tracking as well; only a model change asks for a render.
            guard !event.matches(\TrackingCancellation.count) else { return }
            Task { @MainActor [weak self] in self?.dependencyChanged(afterRender: ordinal) }
        }
        trackedRenders = ordinal
    }

    private func dependencyChanged(afterRender ordinal: UInt64) {
        // A later render, such as a flush, has already shown this change.
        guard ordinal == trackedRenders else { return }
        needsUpdate = true
        updateIfObserving()
    }

    private func scheduleUpdate() {
        guard !isUpdateScheduled else { return }
        isUpdateScheduled = true
        Task { @MainActor [weak self] in
            self?.isUpdateScheduled = false
            self?.updateIfObserving()
        }
    }

    private func updateIfObserving() {
        guard isObserving, needsUpdate else { return }
        update()
    }
}

/// Cancels a one-shot observation tracking, which Observation offers no way to do from outside.
///
/// A tracked closure that calls `arm()` depends on this object as well as on the model, so
/// `cancel()` triggers the tracking, and a triggered one-shot tracking unregisters from
/// everything it read. Its callback tells that trigger from a model change with
/// `event.matches(\TrackingCancellation.count)`.
@Observable
private final class TrackingCancellation {
    private(set) var count: UInt64 = 0

    func arm() { _ = count }

    func cancel() { count &+= 1 }
}
#endif
