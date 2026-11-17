#if os(macOS)
import AppKit
#elseif os(iOS) || os(tvOS) || os(visionOS)
import UIKit
#endif

#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
// MARK: - Offsets

public func + <Anchor: AnyObject>(
    lhs: NSLayoutAnchor<Anchor>,
    rhs: CGFloat
) -> (NSLayoutAnchor<Anchor>, CGFloat) { (lhs, rhs) }

public func - <Anchor: AnyObject>(
    lhs: NSLayoutAnchor<Anchor>,
    rhs: CGFloat
) -> (NSLayoutAnchor<Anchor>, CGFloat) { (lhs, -rhs) }

// UIKit isolates anchors and constraints to the main actor; AppKit doesn't, so isolating these
// keeps one set of operators for both.

// MARK: - Anchor relations

@MainActor
public func == <Anchor: AnyObject>(
    lhs: NSLayoutAnchor<Anchor>,
    rhs: NSLayoutAnchor<Anchor>
) -> NSLayoutConstraint { lhs.constraint(equalTo: rhs) }

@MainActor
public func == <Anchor: AnyObject>(
    lhs: NSLayoutAnchor<Anchor>,
    rhs: (NSLayoutAnchor<Anchor>, CGFloat)
) -> NSLayoutConstraint { lhs.constraint(equalTo: rhs.0, constant: rhs.1) }

@MainActor
public func >= <Anchor: AnyObject>(
    lhs: NSLayoutAnchor<Anchor>,
    rhs: NSLayoutAnchor<Anchor>
) -> NSLayoutConstraint { lhs.constraint(greaterThanOrEqualTo: rhs) }

@MainActor
public func >= <Anchor: AnyObject>(
    lhs: NSLayoutAnchor<Anchor>,
    rhs: (NSLayoutAnchor<Anchor>, CGFloat)
) -> NSLayoutConstraint { lhs.constraint(greaterThanOrEqualTo: rhs.0, constant: rhs.1) }

@MainActor
public func <= <Anchor: AnyObject>(
    lhs: NSLayoutAnchor<Anchor>,
    rhs: NSLayoutAnchor<Anchor>
) -> NSLayoutConstraint { lhs.constraint(lessThanOrEqualTo: rhs) }

@MainActor
public func <= <Anchor: AnyObject>(
    lhs: NSLayoutAnchor<Anchor>,
    rhs: (NSLayoutAnchor<Anchor>, CGFloat)
) -> NSLayoutConstraint { lhs.constraint(lessThanOrEqualTo: rhs.0, constant: rhs.1) }

// MARK: - Dimension constants

@MainActor
public func == (lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constraint(equalToConstant: rhs)
}

@MainActor
public func >= (lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constraint(greaterThanOrEqualToConstant: rhs)
}

@MainActor
public func <= (lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constraint(lessThanOrEqualToConstant: rhs)
}

// MARK: - Priority

// Binds looser than the relation operators, so `a == b + 8 ~ .defaultLow` builds the
// constraint first and then sets its priority.
precedencegroup ConstraintPriorityPrecedence {
    lowerThan: ComparisonPrecedence
    associativity: none
}

infix operator ~ : ConstraintPriorityPrecedence

#if os(macOS)
/// Sets the constraint's priority and returns it. Set priority before activation: changing a
/// required active constraint to optional, or back, throws an exception.
@MainActor
public func ~ (
    constraint: NSLayoutConstraint,
    priority: NSLayoutConstraint.Priority
) -> NSLayoutConstraint {
    constraint.priority = priority
    return constraint
}
#else
/// Sets the constraint's priority and returns it. Set priority before activation: changing a
/// required active constraint to optional, or back, throws an exception.
@MainActor
public func ~ (constraint: NSLayoutConstraint, priority: UILayoutPriority)
    -> NSLayoutConstraint
{
    constraint.priority = priority
    return constraint
}
#endif
#endif
