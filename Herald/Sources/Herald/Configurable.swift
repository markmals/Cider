import Foundation

public protocol Configurable {
    associatedtype T
    @discardableResult func configure(_ closure: (_ instance: T) -> Void) -> T
}

public extension Configurable {
    @discardableResult func configure(_ closure: (_ instance: Self) -> Void) -> Self {
        closure(self)
        return self
    }
}

extension NSObject: Configurable {}

public protocol ValueConfigurable {
    associatedtype T
    @discardableResult func configure(_ closure: (_ instance: inout T) -> Void) -> T
}

public extension ValueConfigurable {
    @discardableResult
    func configure(_ closure: (_ instance: inout Self) -> Void) -> Self {
        var this = self
        closure(&this)
        return this
    }
}
