import Foundation

enum BindingKey: Hashable {
    case value(AnyKeyPath)
    case named(String)
}

/// Everything an object's bindings keep alive, owned by the object itself so it all goes away
/// when the object deallocates.
@MainActor
final class BindingStore {
    private var keyed: [BindingKey: (observation: AnyObject, writeBack: AnyObject?)] = [:]
    private var unkeyed: [AnyObject] = []

    /// Replaces the binding for `key`. Releasing the earlier one ends its observation and, if
    /// it was two-way, whatever wrote the control's value back.
    func set(_ observation: AnyObject, writeBack: AnyObject?, for key: BindingKey) {
        keyed[key] = (observation, writeBack)
    }

    func add(_ part: AnyObject) {
        unkeyed.append(part)
    }
}

private nonisolated(unsafe) var bindingStoreKey: UInt8 = 0

extension ObservationBindable {
    @MainActor
    var bindingStore: BindingStore {
        if let store = objc_getAssociatedObject(self, &bindingStoreKey) as? BindingStore {
            return store
        }
        let store = BindingStore()
        objc_setAssociatedObject(self, &bindingStoreKey, store, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return store
    }
}
