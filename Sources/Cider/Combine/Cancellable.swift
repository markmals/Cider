////
////  Cancellable.swift
////
////  Created by Mark Malstrom on 3/12/23.
////
//
// import Combine
// import UIKit
//
// @propertyWrapper
// public struct Cancellable {
//    public static subscript<T: UIViewController>(
//        _enclosingInstance instance: T,
////        wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value>,
//        storage storageKeyPath: ReferenceWritableKeyPath<T, Self>
//    ) -> [AnyCancellable] {
//        get {
//            instance[keyPath: storageKeyPath].storage
//        }
//        set {
//            // TODO:
//            instance[keyPath: storageKeyPath].storage = newValue
//        }
//    }
//
//    @available(*, unavailable, message: "@Cancellable can only be applied to classes")
//    public var wrappedValue: [AnyCancellable] {
//        get { fatalError() }
//        set { fatalError() }
//    }
//
//    private var storage: [AnyCancellable] = []
//
//    public init() {}
//
////    public init(wrappedValue: [AnyCancellable] = []) {
////        storage = wrappedValue
////    }
// }
