#if os(macOS)
import AppKit
#elseif os(iOS) || os(tvOS) || os(visionOS)
import UIKit
#endif

#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
@resultBuilder
public enum ConstraintBuilder {
    public static func buildBlock(_ parts: [NSLayoutConstraint]...) -> [NSLayoutConstraint] {
        parts.flatMap { $0 }
    }

    public static func buildExpression(_ expression: NSLayoutConstraint) -> [NSLayoutConstraint] {
        [expression]
    }

    public static func buildExpression(_ expression: [NSLayoutConstraint])
        -> [NSLayoutConstraint]
    {
        expression
    }

    public static func buildOptional(_ component: [NSLayoutConstraint]?) -> [NSLayoutConstraint] {
        component ?? []
    }

    public static func buildEither(first component: [NSLayoutConstraint])
        -> [NSLayoutConstraint]
    {
        component
    }

    public static func buildEither(second component: [NSLayoutConstraint])
        -> [NSLayoutConstraint]
    {
        component
    }

    public static func buildArray(_ components: [[NSLayoutConstraint]]) -> [NSLayoutConstraint] {
        components.flatMap { $0 }
    }
}
#endif
