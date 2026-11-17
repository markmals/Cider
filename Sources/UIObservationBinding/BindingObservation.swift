import Observation

/// Keeps something in step with an expression: evaluates it, applies the result, and does both
/// again on a later main-actor turn whenever `@Observable` state the expression read changes.
/// Releasing it ends that.
@MainActor
final class BindingObservation<Value> {
    private let value: @MainActor () -> Value
    private let apply: @MainActor (Value) -> Void
    private let cancellation = TrackingCancellation()

    init(_ value: @escaping @MainActor () -> Value, apply: @escaping @MainActor (Value) -> Void) {
        self.value = value
        self.apply = apply
        update()
    }

    isolated deinit {
        cancellation.cancel()
    }

    private func update() {
        // Only the evaluation is tracked. A tracking registers when its closure returns, so it
        // never reports a change made inside it; applying afterwards means a change the apply
        // sets off, such as a control writing an adjusted value back, runs this again.
        let newValue = withObservationTracking(options: [.didSet]) {
            cancellation.arm()
            return value()
        } onChange: { [weak self] event in
            // Cancelling triggers the tracking as well; only a model change asks for an update.
            guard !event.matches(\TrackingCancellation.count) else { return }
            Task { @MainActor [weak self] in self?.update() }
        }
        apply(newValue)
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
