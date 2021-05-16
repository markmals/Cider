import UIKit
import SnapKit

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
