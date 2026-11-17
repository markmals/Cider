#if os(macOS)
import AppKit
#elseif os(iOS) || os(tvOS) || os(visionOS)
import UIKit
#endif

#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
/// Collects views in order: single views, arrays, `if`/`else`, and `for` loops.
@resultBuilder
public enum SubviewBuilder {
    public static func buildBlock(_ parts: [LayoutView]...) -> [LayoutView] {
        parts.flatMap { $0 }
    }

    public static func buildExpression(_ view: LayoutView) -> [LayoutView] {
        [view]
    }

    public static func buildExpression(_ views: [LayoutView]) -> [LayoutView] {
        views
    }

    public static func buildOptional(_ component: [LayoutView]?) -> [LayoutView] {
        component ?? []
    }

    public static func buildEither(first component: [LayoutView]) -> [LayoutView] {
        component
    }

    public static func buildEither(second component: [LayoutView]) -> [LayoutView] {
        component
    }

    public static func buildArray(_ components: [[LayoutView]]) -> [LayoutView] {
        components.flatMap { $0 }
    }

    public static func buildLimitedAvailability(_ component: [LayoutView]) -> [LayoutView] {
        component
    }
}
#endif
