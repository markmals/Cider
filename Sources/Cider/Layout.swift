import UIKit

extension NSLayoutConstraint {
    @resultBuilder
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

public func ==(lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constraint(equalToConstant: rhs)
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
    public func layout(@NSLayoutConstraint.ConstraintBuilder using closure: (UIView) -> [NSLayoutConstraint]) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(closure(self))
    }
    
    public func addSubviews(_ views: [UIView]) {
        for view in views {
            addSubview(view)
        }
    }
    
    public static func spacer() -> UIView {
        let view = UIView()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentHuggingPriority(.required, for: .vertical)
        return view
    }
}

extension UIStackView {
    public func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
    
    public func addArrangedSubviews(_ subviews: [UIView]) {
        subviews.forEach { addArrangedSubview($0) }
    }
    
    public func replaceArrangedSubviews(with subviews: [UIView]) {
        removeAllArrangedSubviews()
        addArrangedSubviews(subviews)
    }
}
