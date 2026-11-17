#if os(macOS)
import AppKit

public typealias LayoutView = NSView
#elseif os(iOS) || os(tvOS) || os(visionOS)
import UIKit

public typealias LayoutView = UIView
#endif

#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
extension LayoutView {
    /// Turns off autoresizing-mask translation and activates the built constraints.
    @discardableResult
    public func layout(@ConstraintBuilder using constraints: (Self) -> [NSLayoutConstraint])
        -> Self
    {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints(self))
        return self
    }

    /// Fixes the width, the height, or both, and leaves a `nil` dimension as it is. Calling it
    /// again changes the size it fixed earlier instead of adding a second constraint.
    @discardableResult
    public func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        if let width { fix(widthAnchor, at: width, identifier: "Layout.frame.width") }
        if let height { fix(heightAnchor, at: height, identifier: "Layout.frame.height") }
        return self
    }

    /// Sets the constant of the constraint this view holds under `identifier`, adding that
    /// constraint the first time.
    private func fix(_ dimension: NSLayoutDimension, at constant: CGFloat, identifier: String) {
        if let fixed = constraints.first(where: { $0.identifier == identifier }) {
            fixed.constant = constant
        } else {
            let constraint = dimension.constraint(equalToConstant: constant)
            constraint.identifier = identifier
            constraint.isActive = true
        }
    }

    @discardableResult
    public func frame(_ size: CGFloat) -> Self {
        frame(width: size, height: size)
    }

    /// Constrains all four edges to `other`'s, inset by `insets`. Leading and trailing follow
    /// the user interface layout direction. Every call adds four constraints, so pin a view
    /// once.
    public func pin(to other: LayoutView, insets: NSDirectionalEdgeInsets = .init()) {
        layout {
            $0.topAnchor == other.topAnchor + insets.top
            $0.bottomAnchor == other.bottomAnchor - insets.bottom
            $0.leadingAnchor == other.leadingAnchor + insets.leading
            $0.trailingAnchor == other.trailingAnchor - insets.trailing
        }
    }

    /// `pin(to:insets:)`, returning this view so the call can end a construction chain.
    @discardableResult
    public func pinned(to other: LayoutView, insets: NSDirectionalEdgeInsets = .init()) -> Self {
        pin(to: other, insets: insets)
        return self
    }
}
#endif
