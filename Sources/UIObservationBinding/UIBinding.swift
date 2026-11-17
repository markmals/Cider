import Observation

/// A value that a control can read and write: SwiftUI's `Binding`, for UIKit and AppKit.
///
/// Get bindings to a model's properties through ``UIBindable`` (`$model.isEnabled`), or declare
/// local state that owns its value with `@UIBinding var isPlaying = false`. Reading
/// `wrappedValue` tracks the `@Observable` state underneath, so bound controls follow it.
///
/// A control holding a binding to `$model.isEnabled` retains the model, never the view
/// controller that created it.
@MainActor
@propertyWrapper
@dynamicMemberLookup
public struct UIBinding<Value> {
    private let read: @MainActor () -> Value
    private let write: @MainActor (Value) -> Void

    public init(get: @escaping @MainActor () -> Value, set: @escaping @MainActor (Value) -> Void) {
        read = get
        write = set
    }

    /// Local state that this binding owns. Swift calls this for `@UIBinding var isPlaying = false`;
    /// the value is stored observably, so bindings and `updateProperties()` that read it update.
    public init(wrappedValue: Value) {
        let storage = Storage(wrappedValue)
        self.init(get: { storage.value }, set: { storage.value = $0 })
    }

    public init(projectedValue: UIBinding<Value>) {
        self = projectedValue
    }

    /// A binding that always reads `value` and ignores writes.
    public static func constant(_ value: Value) -> Self {
        Self(get: { value }, set: { _ in })
    }

    public var wrappedValue: Value {
        get { read() }
        nonmutating set { write(newValue) }
    }

    public var projectedValue: Self { self }

    /// A binding to a property of this binding's value, such as a field of a struct:
    /// `$model.filters.showsDrafts`. Writes go back through this binding.
    public subscript<Member>(
        dynamicMember keyPath: WritableKeyPath<Value, Member>
    ) -> UIBinding<Member> {
        UIBinding<Member>(
            get: { self.wrappedValue[keyPath: keyPath] },
            set: { self.wrappedValue[keyPath: keyPath] = $0 }
        )
    }
}

extension UIBinding {
    @MainActor
    @Observable
    fileprivate final class Storage {
        var value: Value

        init(_ value: Value) {
            self.value = value
        }
    }
}

/// Hands out bindings to an `@Observable` model's properties: SwiftUI's `Bindable`, for UIKit and
/// AppKit.
///
/// ```swift
/// @UIBindable var model: SettingsModel
///
/// let toggle = UISwitch(isOn: $model.isEnabled)
/// ```
@MainActor
@propertyWrapper
@dynamicMemberLookup
public struct UIBindable<Model: AnyObject & Observable> {
    public var wrappedValue: Model

    public init(wrappedValue: Model) {
        self.wrappedValue = wrappedValue
    }

    public init(_ model: Model) {
        self.init(wrappedValue: model)
    }

    public var projectedValue: Self { self }

    public subscript<Member>(
        dynamicMember keyPath: ReferenceWritableKeyPath<Model, Member>
    ) -> UIBinding<Member> {
        let model = wrappedValue
        return UIBinding(get: { model[keyPath: keyPath] }, set: { model[keyPath: keyPath] = $0 })
    }
}
