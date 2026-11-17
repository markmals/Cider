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

    /// Fixes the width, the height, or both; a `nil` dimension stays unconstrained.
    @discardableResult
    public func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        layout {
            if let width { $0.widthAnchor == width }
            if let height { $0.heightAnchor == height }
        }
    }

    @discardableResult
    public func frame(_ size: CGFloat) -> Self {
        frame(width: size, height: size)
    }

    /// Constrains all four edges to `other`'s, inset by `insets`. Leading and trailing follow
    /// the user interface layout direction.
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
