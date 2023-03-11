import Foundation

protocol Configurable: AnyObject {}

extension Configurable {
    func configure<Object: Configurable>(closure: (Object) -> Void) -> Object {
        closure(self as! Object)
        return self as! Object
    }
}

extension NSObject: Configurable {}
