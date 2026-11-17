#if os(macOS)
import AppKit
#elseif os(iOS) || os(tvOS) || os(visionOS)
import UIKit
#endif

/// A value type that builds a configured copy inside one expression:
///
/// ```swift
/// let snapshot = NSDiffableDataSourceSnapshot<Section, Item.ID>().configured {
///     $0.appendSections([.main])
///     $0.appendItems(items.map(\.id))
/// }
/// ```
///
/// Conform your own value types directly. Conforming another module's type needs `@retroactive`.
public protocol ValueConfigurable {}

extension ValueConfigurable {
    /// Returns a copy of this value after `body` mutates it; this value is left unchanged.
    public func configured(_ body: (inout Self) throws -> Void) rethrows -> Self {
        var copy = self
        try body(&copy)
        return copy
    }
}

#if os(macOS)
extension NSDiffableDataSourceSnapshot: ValueConfigurable {}
#elseif os(iOS) || os(tvOS) || os(visionOS)
extension NSDiffableDataSourceSnapshot: ValueConfigurable {}
extension NSDiffableDataSourceSectionSnapshot: ValueConfigurable {}
extension UIBackgroundConfiguration: ValueConfigurable {}
extension UIButton.Configuration: ValueConfigurable {}
extension UIListContentConfiguration: ValueConfigurable {}
#endif
