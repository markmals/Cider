/// Runs one operation at a time for a feature model: starting another cancels the running one,
/// and only the latest operation's result is delivered.
///
/// A superseded or cancelled operation never reaches its completion, even if it ignores
/// cancellation and finishes anyway, so a late response can't overwrite newer state. A delivered
/// error is a real failure, never the expected cancellation. Deallocating the `LatestTask`
/// cancels its running operation.
///
/// ```swift
/// @ObservationIgnored private let search = LatestTask<[Recipe]>()
///
/// func search(for query: String) {
///     search.run { [service] in
///         try await service.recipes(matching: query)
///     } completion: { [weak self] result in
///         self?.apply(result)
///     }
/// }
/// ```
@MainActor
public final class LatestTask<Success: Sendable> {
    private var running: Task<Void, Never>?
    private var generation: UInt64 = 0

    public init() {}

    deinit { running?.cancel() }

    /// Whether the latest operation is still running: it hasn't delivered or been cancelled.
    public var isRunning: Bool { running != nil }

    /// Cancels the running operation, if any, and starts `operation`. `completion` gets its
    /// result on the main actor unless `run` or `cancel()` is called first.
    public func run(
        _ operation: sending @escaping @isolated(any) () async throws -> Success,
        completion: @escaping @MainActor (Result<Success, any Error>) -> Void
    ) {
        cancel()
        let id = generation
        running = Task { [weak self] in
            let result: Result<Success, any Error>
            do {
                result = .success(try await operation())
            } catch {
                result = .failure(error)
            }
            guard let self, generation == id else { return }
            running = nil
            completion(result)
        }
    }

    /// Cancels the running operation and drops its result.
    public func cancel() {
        running?.cancel()
        running = nil
        generation &+= 1
    }
}
