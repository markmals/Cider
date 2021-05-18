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

public func <=(lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constraint(lessThanOrEqualToConstant: rhs)
}

public func >=(lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constraint(greaterThanOrEqualToConstant: rhs)
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
    
    public func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        
        if let width = width {
            constraints.append(widthAnchor == width)
        }
        
        if let height = height {
            constraints.append(heightAnchor == height)
        }
        
        return constraints
    }
    
    public func frame(size: CGFloat? = nil) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        
        if let size = size {
            constraints = [
                widthAnchor == size,
                heightAnchor == size
            ]
        }
        
        return constraints
    }
    
    public func frame(
        minWidth: CGFloat? = nil,
        maxWidth: CGFloat? = nil,
        minHeight: CGFloat? = nil,
        maxHeight: CGFloat? = nil
    ) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        
        if let minWidth = minWidth {
            constraints.append(widthAnchor >= minWidth)
        }
        
        if let maxWidth = maxWidth {
            constraints.append(widthAnchor <= maxWidth)
        }
        
        if let minHeight = minHeight {
            constraints.append(widthAnchor >= minHeight)
        }
        
        if let maxHeight = maxHeight {
            constraints.append(widthAnchor <= maxHeight)
        }
        
        return constraints
    }
    
    public func padding(_ insets: UIEdgeInsets) {
        self.layoutMargins = insets
    }
    
    public func padding(_ length: CGFloat) {
        self.padding(.init(top: length, left: length, bottom: length, right: length))
    }
    
    func padding(_ edges: NSDirectionalRectEdge = .all, _ length: CGFloat? = nil) {
        if let length = length {
            switch edges {
            case .all: self.padding(length)
            case .top: self.layoutMargins.top = length
            case .bottom: self.layoutMargins.bottom = length
            case .leading: self.layoutMargins.left = length
            case .trailing: self.layoutMargins.right = length
            default: break
            }
        }
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
