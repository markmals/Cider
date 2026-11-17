import Foundation

/// A reference type that sets itself up inside one expression:
///
/// ```swift
/// let button = UIButton().configure {
///     $0.setTitle("Buy Now", for: .normal)
///     $0.layer.cornerCurve = .continuous
/// }
/// ```
///
/// Every `NSObject` conforms.
public protocol Configurable: AnyObject {}

extension Configurable {
    /// Runs `body` on this instance, then returns the instance.
    @discardableResult
    public func configure(_ body: (Self) throws -> Void) rethrows -> Self {
        try body(self)
        return self
    }
}

extension NSObject: Configurable {}
