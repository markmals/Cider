import UIKit
import SnapKit

extension UIView {
    public var layout: ConstraintViewDSL {
        self.snp
    }
}

extension ConstraintViewDSL {
    public func constraints(using closure: (ConstraintMaker) -> Void) {
        self.makeConstraints(closure)
    }
}

extension ConstraintMaker {
    public func frame(width: CGFloat? = nil, height: CGFloat? = nil) {
        if let width = width {
            self.width == width
        }
        
        if let height = height {
            self.height == height
        }
    }
    
    public func frame(size: CGFloat? = nil) {
        if let size = size {
            self.size == size
        }
    }
    
    public func frame(
        minWidth: CGFloat? = nil,
        maxWidth: CGFloat? = nil,
        minHeight: CGFloat? = nil,
        maxHeight: CGFloat? = nil
    ) {
        if let minWidth = minWidth {
            self.width >= minWidth
        }
        
        if let maxWidth = maxWidth {
            self.width <= maxWidth
        }
        
        if let minHeight = minHeight {
            self.width >= minHeight
        }
        
        if let maxHeight = maxHeight {
            self.width <= maxHeight
        }
    }
    
    public func padding(_ insets: UIEdgeInsets) {
        self.margins == insets
    }
    
    public func padding(_ length: CGFloat) {
        self.margins == length
    }
    
    func padding(_ edges: NSDirectionalRectEdge = .all, _ length: CGFloat? = nil) {
        if let length = length {
            switch edges {
            case .all: self.margins == length
            case .top: self.topMargin == length
            case .bottom: self.bottomMargin == length
            case .leading: self.leadingMargin == length
            case .trailing: self.trailingMargin == length
            default: break
            }
        }
    }
}

public func ==(lhs: ConstraintMakerExtendable, rhs: ConstraintRelatableTarget) {
    lhs.equalTo(rhs)
}

public func <=(lhs: ConstraintMakerExtendable, rhs: ConstraintRelatableTarget) {
    lhs.lessThanOrEqualTo(rhs)
}

public func >=(lhs: ConstraintMakerExtendable, rhs: ConstraintRelatableTarget) {
    lhs.greaterThanOrEqualTo(rhs)
}

public func +(lhs: ConstraintRelatableTarget, rhs: ConstraintOffsetTarget) -> (ConstraintRelatableTarget, ConstraintOffsetTarget) {
    return (lhs, rhs)
}

public func ==(lhs: ConstraintMakerExtendable, rhs: (ConstraintRelatableTarget, ConstraintOffsetTarget)) {
    lhs.equalTo(rhs.0).offset(rhs.1)
}

public func <=(lhs: ConstraintMakerExtendable, rhs: (ConstraintRelatableTarget, ConstraintOffsetTarget)) {
    lhs.lessThanOrEqualTo(rhs.0).offset(rhs.1)
}

public func >=(lhs: ConstraintMakerExtendable, rhs: (ConstraintRelatableTarget, ConstraintOffsetTarget)) {
    lhs.greaterThanOrEqualTo(rhs.0).offset(rhs.1)
}

public func -(lhs: ConstraintRelatableTarget, rhs: ConstraintInsetTarget) -> (ConstraintRelatableTarget, ConstraintInsetTarget) {
    return (lhs, rhs)
}

public func ==(lhs: ConstraintMakerExtendable, rhs: (ConstraintRelatableTarget, ConstraintInsetTarget)) {
    lhs.equalTo(rhs.0).inset(rhs.1)
}

public func <=(lhs: ConstraintMakerExtendable, rhs: (ConstraintRelatableTarget, ConstraintInsetTarget)) {
    lhs.lessThanOrEqualTo(rhs.0).inset(rhs.1)
}

public func >=(lhs: ConstraintMakerExtendable, rhs: (ConstraintRelatableTarget, ConstraintInsetTarget)) {
    lhs.greaterThanOrEqualTo(rhs.0).inset(rhs.1)
}

public func *(lhs: ConstraintRelatableTarget, rhs: ConstraintMultiplierTarget) -> (ConstraintRelatableTarget, ConstraintMultiplierTarget) {
    return (lhs, rhs)
}

public func /(lhs: ConstraintRelatableTarget, rhs: ConstraintMultiplierTarget) -> (ConstraintRelatableTarget, ConstraintMultiplierTarget) {
    return (lhs, (1.0 / rhs.constraintMultiplierTargetValue))
}

public func ==(lhs: ConstraintMakerExtendable, rhs: (ConstraintRelatableTarget, ConstraintMultiplierTarget)) {
    lhs.equalTo(rhs.0).multipliedBy(rhs.1)
}

public func <=(lhs: ConstraintMakerExtendable, rhs: (ConstraintRelatableTarget, ConstraintMultiplierTarget)) {
    lhs.lessThanOrEqualTo(rhs.0).multipliedBy(rhs.1)
}

public func >=(lhs: ConstraintMakerExtendable, rhs: (ConstraintRelatableTarget, ConstraintMultiplierTarget)) {
    lhs.greaterThanOrEqualTo(rhs.0).multipliedBy(rhs.1)
}

infix operator ! : AdditionPrecedence
public func !(lhs: ConstraintRelatableTarget, rhs: ConstraintPriority) -> (ConstraintRelatableTarget, ConstraintPriority) {
    return (lhs, rhs)
}

public func ==(lhs: ConstraintMakerExtendable, rhs: (ConstraintRelatableTarget, ConstraintPriority)) {
    lhs.equalTo(rhs.0).priority(rhs.1)
}

public func <=(lhs: ConstraintMakerExtendable, rhs: (ConstraintRelatableTarget, ConstraintPriority)) {
    lhs.lessThanOrEqualTo(rhs.0).priority(rhs.1)
}

public func >=(lhs: ConstraintMakerExtendable, rhs: (ConstraintRelatableTarget, ConstraintPriority)) {
    lhs.greaterThanOrEqualTo(rhs.0).priority(rhs.1)
}

public func !(lhs: ConstraintRelatableTarget, rhs: ConstraintPriorityTarget) -> (ConstraintRelatableTarget, ConstraintPriorityTarget) {
    return (lhs, rhs)
}

public func ==(lhs: ConstraintMakerExtendable, rhs: (ConstraintRelatableTarget, ConstraintPriorityTarget)) {
    lhs.equalTo(rhs.0).priority(rhs.1)
}

public func <=(lhs: ConstraintMakerExtendable, rhs: (ConstraintRelatableTarget, ConstraintPriorityTarget)) {
    lhs.lessThanOrEqualTo(rhs.0).priority(rhs.1)
}

public func >=(lhs: ConstraintMakerExtendable, rhs: (ConstraintRelatableTarget, ConstraintPriorityTarget)) {
    lhs.greaterThanOrEqualTo(rhs.0).priority(rhs.1)
}

infix operator ^ : AdditionPrecedence
public func ^(lhs: ConstraintRelatableTarget, rhs: String) -> (ConstraintRelatableTarget, String) {
    return (lhs, rhs)
}

public func ==(lhs: ConstraintMakerExtendable, rhs: (ConstraintRelatableTarget, String)) {
    lhs.equalTo(rhs.0).labeled(rhs.1)
}

public func <=(lhs: ConstraintMakerExtendable, rhs: (ConstraintRelatableTarget, String)) {
    lhs.lessThanOrEqualTo(rhs.0).labeled(rhs.1)
}

public func >=(lhs: ConstraintMakerExtendable, rhs: (ConstraintRelatableTarget, String)) {
    lhs.greaterThanOrEqualTo(rhs.0).labeled(rhs.1)
}
