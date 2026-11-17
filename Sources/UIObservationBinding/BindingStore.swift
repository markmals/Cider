import Foundation
import Observation

enum BindingKey: Hashable {
    case value(AnyKeyPath)
    case named(String)
}

/// Everything an object's bindings keep alive, owned by the object itself so it all goes away
/// when the object deallocates.
@MainActor
final class BindingStore {
    private var keyed: [BindingKey: AnyObject] = [:]
    private var unkeyed: [AnyObject] = []

    func set(_ part: AnyObject, for key: BindingKey) {
        keyed[key] = part
    }

    func add(_ part: AnyObject) {
        unkeyed.append(part)
    }
}

/// Runs an update under continuous observation until released.
final class BindingObservation {
    private var token: ObservationTracking.Token?

    @MainActor
    init(_ update: @escaping @MainActor () -> Void) {
        let observation = WeakReference(self)
        token = withContinuousObservation(options: [.willSet]) { _ in
            // Releasing the token doesn't stop the callback for a change that was already
            // pending, so a binding that has been replaced must ignore it.
            guard observation.value != nil else { return }
            update()
        }
    }
}

/// Lets a `@Sendable` observation closure refer to its object without retaining it.
final class WeakReference<Object: AnyObject>: @unchecked Sendable {
    // Unchecked: only read on the main actor, inside observation closures isolated to it.
    private(set) weak var value: Object?

    init(_ value: Object) {
        self.value = value
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
