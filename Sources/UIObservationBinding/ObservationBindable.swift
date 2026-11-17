import Foundation

/// An object whose properties can track `@Observable` state. Every `NSObject` is one.
///
/// Bound values are stored and re-evaluated, so capture models in locals rather than through
/// `self`. A view controller binding a view to `self.model` keeps itself alive through its own
/// view: controller → view → binding → controller.
public protocol ObservationBindable: AnyObject {}

extension NSObject: ObservationBindable {}

extension ObservationBindable {
    /// Keeps `keyPath` equal to `value`. It's set now, then again on a later main-actor turn
    /// whenever `@Observable` state that `value` read changes; synchronous changes coalesce.
    ///
    /// Binding the same key path again replaces the earlier binding, a two-way one's write-back
    /// included, and every binding ends when this object deallocates. A key path names its root
    /// type, so `\TitleLabel.text` doesn't replace a binding made through `\UILabel.text`:
    /// rebind through the same type, or through the control's own method, such as `bind(text:)`.
    @MainActor
    public func bind<Value>(
        _ keyPath: ReferenceWritableKeyPath<Self, Value>,
        to value: @escaping @autoclosure @MainActor () -> Value
    ) {
        sink(.value(keyPath), value) { object, newValue in object[keyPath: keyPath] = newValue }
    }

    /// Keeps `keyPath` equal to `value`, like the general overload, but never reassigns an equal
    /// value: a text field keeps its selection when an unrelated change re-runs `value`.
    @MainActor
    public func bind<Value: Equatable>(
        _ keyPath: ReferenceWritableKeyPath<Self, Value>,
        to value: @escaping @autoclosure @MainActor () -> Value
    ) {
        bind(keyPath, to: value, writeBack: nil)
    }

    /// Calls `apply` with `value` now, then whenever `@Observable` state that `value` read
    /// changes. These bindings accumulate rather than replace each other; each ends when this
    /// object deallocates.
    ///
    /// ```swift
    /// dataSource.bind(to: model.snapshot) { dataSource, snapshot in
    ///     dataSource.apply(snapshot, animatingDifferences: true)
    /// }
    /// ```
    @MainActor
    public func bind<Value>(
        to value: @escaping @autoclosure @MainActor () -> Value,
        _ apply: @escaping @MainActor (Self, Value) -> Void
    ) {
        bindingStore.add(observe(value, apply))
    }

    /// The `Equatable` binding, with what writes the control's value back when it's two-way.
    @MainActor
    func bind<Value: Equatable>(
        _ keyPath: ReferenceWritableKeyPath<Self, Value>,
        to value: @escaping @MainActor () -> Value,
        writeBack: AnyObject?
    ) {
        sink(.value(keyPath), value, writeBack: writeBack) { object, newValue in
            if object[keyPath: keyPath] != newValue { object[keyPath: keyPath] = newValue }
        }
    }

    /// Binds under `key`, replacing its earlier binding. `writeBack` is whatever sends a
    /// control's value back to the model; it must stop when released, because the binding that
    /// replaces this one releases it.
    @MainActor
    func sink<Value>(
        _ key: BindingKey,
        _ value: @escaping @MainActor () -> Value,
        writeBack: AnyObject? = nil,
        _ apply: @escaping @MainActor (Self, Value) -> Void
    ) {
        bindingStore.set(observe(value, apply), writeBack: writeBack, for: key)
    }

    /// Applies `value` now and after each change to what it read, for as long as the returned
    /// observation is alive.
    @MainActor
    private func observe<Value>(
        _ value: @escaping @MainActor () -> Value,
        _ apply: @escaping @MainActor (Self, Value) -> Void
    ) -> AnyObject {
        let object = WeakReference(self)
        return BindingObservation(value) { newValue in
            guard let object = object.value else { return }
            apply(object, newValue)
        }
    }
}
