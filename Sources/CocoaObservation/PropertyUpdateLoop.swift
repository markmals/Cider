#if os(macOS)
import Observation

/// Runs a render closure under SE-0506 continuous observation: every `@Observable` property the
/// render reads re-runs it on a later main-actor turn, with synchronous changes coalesced.
@MainActor
final class PropertyUpdateLoop {
    private let invalidation = Invalidation()
    private let render: @MainActor () -> Void
    private var observation: ObservationTracking.Token?
    /// Identifies the current observation, so a callback can tell that its own has since stopped.
    private var epoch: UInt64 = 0
    private var needsUpdate = true
    private var isUpdating = false

    init(render: @escaping @MainActor () -> Void) {
        self.render = render
    }

    func start() {
        guard observation == nil else { return }
        let epoch = epoch
        observation = withContinuousObservation(options: [.willSet]) { [weak self] _ in
            guard let self, self.epoch == epoch else { return }
            _ = invalidation.generation
            update()
        }
    }

    func stop() {
        observation = nil
        // Releasing the token doesn't stop the callback for a change that was already pending;
        // moving the epoch on turns that callback into a no-op.
        epoch &+= 1
        // Changes made while stopped go unobserved, so a flush before the restarted loop's first
        // turn must still render.
        needsUpdate = true
    }

    func setNeedsUpdate() {
        needsUpdate = true
        if !isUpdating { invalidation.bump() }
    }

    func updateIfNeeded() {
        guard needsUpdate else { return }
        update()
    }

    private func update() {
        guard !isUpdating else { return }
        isUpdating = true
        needsUpdate = false
        render()
        isUpdating = false
        if needsUpdate {
            // A bump inside the observation closure fires before tracking of the generation it
            // just read is installed, so the request would be lost; bump on a later turn instead.
            Task { @MainActor [weak self] in self?.invalidation.bump() }
        }
    }
}

/// A tracked counter that `setNeedsUpdate()` bumps, so the loop re-runs with no model change.
@MainActor
@Observable
private final class Invalidation {
    private(set) var generation: UInt64 = 0

    func bump() { generation &+= 1 }
}
#endif
