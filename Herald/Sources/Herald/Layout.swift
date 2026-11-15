import UIKit

extension NSLayoutConstraint {
    @_functionBuilder
    public struct ConstraintBuilder {
        public static func buildBlock(_ constraints: [NSLayoutConstraint]...) -> [NSLayoutConstraint] {
            constraints.flatMap { $0 }
        }
        
        public static func buildExpression(_ constraint: NSLayoutConstraint) -> [NSLayoutConstraint] {
          return [constraint]
        }
        
        public static func buildOptional(_ constraint: [NSLayoutConstraint]?) -> [NSLayoutConstraint] {
            constraint ?? []
        }
        
        public static func buildEither(first constraint: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
            constraint
        }

        public static func buildEither(second constraint: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
            constraint
        }
    }
}

public func +<Anchor: AnyObject>(lhs: NSLayoutAnchor<Anchor>, rhs: CGFloat) -> (NSLayoutAnchor<Anchor>, CGFloat) {
    return (lhs, rhs)
}

public func ==<Anchor: AnyObject>(lhs: NSLayoutAnchor<Anchor>, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constraint(equalTo: lhs, constant: rhs)
}

public func -<Anchor: AnyObject>(lhs: NSLayoutAnchor<Anchor>, rhs: CGFloat) -> (NSLayoutAnchor<Anchor>, CGFloat) {
    return (lhs, -rhs)
}

public func ==<Anchor: AnyObject>(lhs: NSLayoutAnchor<Anchor>, rhs: (NSLayoutAnchor<Anchor>, CGFloat)) -> NSLayoutConstraint {
    lhs.constraint(equalTo: rhs.0, constant: rhs.1)
}

public func ==<Anchor: AnyObject>(lhs: NSLayoutAnchor<Anchor>, rhs: NSLayoutAnchor<Anchor>) -> NSLayoutConstraint {
    lhs.constraint(equalTo: rhs)
}

public func >=<Anchor: AnyObject>(lhs: NSLayoutAnchor<Anchor>, rhs: (NSLayoutAnchor<Anchor>, CGFloat)) -> NSLayoutConstraint {
    lhs.constraint(greaterThanOrEqualTo: rhs.0, constant: rhs.1)
}

public func >=<Anchor: AnyObject>(lhs: NSLayoutAnchor<Anchor>, rhs: NSLayoutAnchor<Anchor>) -> NSLayoutConstraint {
    lhs.constraint(greaterThanOrEqualTo: rhs)
}

public func <=<Anchor: AnyObject>(lhs: NSLayoutAnchor<Anchor>, rhs: (NSLayoutAnchor<Anchor>, CGFloat)) -> NSLayoutConstraint {
    lhs.constraint(lessThanOrEqualTo: rhs.0, constant: rhs.1)
}

public func <=<Anchor: AnyObject>(lhs: NSLayoutAnchor<Anchor>, rhs: NSLayoutAnchor<Anchor>) -> NSLayoutConstraint {
    lhs.constraint(lessThanOrEqualTo: rhs)
}

extension UIView {
    @discardableResult
    public func layout(@NSLayoutConstraint.ConstraintBuilder using closure: (UIView) -> [NSLayoutConstraint]) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(closure(self))
        return self
    }
    
    @discardableResult
    public func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        return layout {
            if let width = width {
                $0.widthAnchor.constraint(equalToConstant: width)
            }
            
            if let height = height {
                $0.heightAnchor.constraint(equalToConstant: height)
            }
        } as! Self
    }
    
    @discardableResult
    public func frame(_ size: CGFloat? = nil) -> Self {
        frame(width: size, height: size)
    }

    @discardableResult
    public func margins(top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) -> Self {
        var margins = layoutMargins
        margins.top = top ?? margins.top
        margins.left = left ?? margins.left
        margins.bottom = bottom ?? margins.bottom
        margins.right = right ?? margins.right
        layoutMargins = margins

        return self
    }
    
    public func pin(to guide: UILayoutGuide, insets: UIEdgeInsets = .zero) {
        guard let _ = superview else {
            return
        }
        
        layout {
            $0.topAnchor == guide.topAnchor + insets.top
            $0.bottomAnchor == guide.bottomAnchor - insets.bottom
            $0.leftAnchor == guide.leftAnchor + insets.left
            $0.rightAnchor == guide.rightAnchor - insets.right
        }
    }
    
    public func pin(to pinningView: UIView, insets: UIEdgeInsets = .zero) {
        guard let _ = superview else {
            return
        }
        
        layout {
            $0.topAnchor == pinningView.topAnchor + insets.top
            $0.bottomAnchor == pinningView.bottomAnchor - insets.bottom
            $0.leftAnchor == pinningView.leftAnchor + insets.left
            $0.rightAnchor == pinningView.rightAnchor - insets.right
        }
    }
    
    public func pinned(to guide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self {
        configure { $0.pin(to: guide, insets: insets) }
    }
    
    public func pinned(to pinningView: UIView, insets: UIEdgeInsets = .zero) -> Self {
        configure { $0.pin(to: pinningView, insets: insets) }
    }
    
    public func padding(left: CGFloat = 0, right: CGFloat = 0, top: CGFloat = 0, bottom: CGFloat = 0) -> Self {
        if let view = superview {
            return pinned(to: view, insets: .init(top: left, left: left, bottom: bottom, right: right))
        } else { return self }
    }
}

