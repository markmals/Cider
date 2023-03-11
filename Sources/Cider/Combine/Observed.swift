//
//  Observed.swift
//
//
//  Created by Mark Malstrom on 3/11/23.
//

import Combine

public protocol Observable: AnyObject {
    var objectDidChange: PassthroughSubject<Void, Never> { get }
}

@propertyWrapper
public struct Observed<Value> {
    public static subscript<T: Observable>(
        _enclosingInstance instance: T,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<T, Self>
    ) -> Value {
        get {
            instance[keyPath: storageKeyPath].storage
        }
        set {
            instance.objectDidChange.send()
            instance[keyPath: storageKeyPath].storage = newValue
        }
    }

    @available(*, unavailable, message: "@Observed can only be applied to classes")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }

    private var storage: Value

    public init(wrappedValue: Value) {
        storage = wrappedValue
    }

    @propertyWrapper
    public struct Detached<Value> {
        public var wrappedValue: Value {
            get { subject.value }
            set { subject.send(newValue) }
        }

        public var projectedValue: AnyPublisher<Value, Never> {
            subject.eraseToAnyPublisher()
        }

        private let subject: CurrentValueSubject<Value, Never>

        public init(wrappedValue: Value) {
            subject = CurrentValueSubject(wrappedValue)
        }
    }
}
