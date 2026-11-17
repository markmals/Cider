#if os(macOS)
import Observation

/// Runs a render closure inside an `Observations` (SE-0475) loop. The emit closure is where
/// Observation records dependencies, so every `@Observable` property the render reads re-runs it.
@MainActor
final class PropertyUpdateLoop {
    private let invalidation = Invalidation()
    private let render: @MainActor () -> Void
    private var task: Task<Void, Never>?
    private var needsUpdate = true
    private var isUpdating = false

    init(render: @escaping @MainActor () -> Void) {
        self.render = render
    }

    deinit { task?.cancel() }

    func start() {
        guard task == nil else { return }
        task = Task { @MainActor [weak self] in
            let updates = Observations<Void, Never>.untilFinished { [weak self] in
                guard let self else { return .finish }
                _ = invalidation.generation
                update()
                return .next(())
            }
            for await _ in updates {
                if Task.isCancelled { break }
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
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
            // A bump inside the emit closure fires before the loop tracks the generation it just
            // read, so the request would be lost; bump on a later turn instead.
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
