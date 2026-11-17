#if os(macOS)
import AppKit

public typealias LayoutStackView = NSStackView

extension NSStackView {
    /// A stack view of the views `arrangedSubviews` builds. A `nil` setting keeps
    /// `NSStackView`'s default.
    public convenience init(
        orientation: NSUserInterfaceLayoutOrientation,
        alignment: NSLayoutConstraint.Attribute? = nil,
        distribution: NSStackView.Distribution? = nil,
        spacing: CGFloat? = nil,
        @SubviewBuilder arrangedSubviews: () -> [NSView]
    ) {
        self.init(views: arrangedSubviews())
        self.orientation = orientation
        if let alignment { self.alignment = alignment }
        if let distribution { self.distribution = distribution }
        if let spacing { self.spacing = spacing }
    }
}
#elseif os(iOS) || os(tvOS) || os(visionOS)
import UIKit

public typealias LayoutStackView = UIStackView

extension UIStackView {
    /// A stack view of the views `arrangedSubviews` builds.
    public convenience init(
        axis: NSLayoutConstraint.Axis,
        alignment: UIStackView.Alignment = .fill,
        distribution: UIStackView.Distribution = .fill,
        spacing: CGFloat = 0,
        isBaselineRelativeArrangement: Bool = false,
        isLayoutMarginsRelativeArrangement: Bool = false,
        @SubviewBuilder arrangedSubviews: () -> [UIView]
    ) {
        self.init(arrangedSubviews: arrangedSubviews())
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
        self.spacing = spacing
        self.isBaselineRelativeArrangement = isBaselineRelativeArrangement
        self.isLayoutMarginsRelativeArrangement = isLayoutMarginsRelativeArrangement
    }
}
#endif

#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
extension LayoutStackView {
    public func addArrangedSubviews(@SubviewBuilder _ views: () -> [LayoutView]) {
        for view in views() { addArrangedSubview(view) }
    }

    /// Removes every arranged subview from the stack view and the view hierarchy. Each view
    /// keeps its own constraints, such as a fixed size, so it can be added again as it was.
    public func removeAllArrangedSubviews() {
        for view in arrangedSubviews { view.removeFromSuperview() }
    }

    /// Makes `views` the arranged subviews, in order. A view that's already arranged stays in
    /// the hierarchy, keeping its first-responder status and any state, and moves only if its
    /// position changed. Views not in `views` leave the stack view and the hierarchy, as with
    /// `removeAllArrangedSubviews()`. Nothing happens when the arranged subviews already match.
    public func replaceArrangedSubviews(@SubviewBuilder with views: () -> [LayoutView]) {
        var staying = Set<ObjectIdentifier>()
        // A view can be arranged only once; one listed again keeps its first position.
        let replacements = views().filter { staying.insert(ObjectIdentifier($0)).inserted }
        var arranged = arrangedSubviews
        guard !arranged.elementsEqual(replacements, by: ===) else { return }

        let leaving = arranged.filter { !staying.contains(ObjectIdentifier($0)) }
        for view in leaving { view.removeFromSuperview() }
        if !leaving.isEmpty { arranged = arrangedSubviews }

        // Everything before `index` already matches, so a view found out of place is further on
        // and moving it forward leaves the matched part alone.
        for (index, view) in replacements.enumerated() {
            if index < arranged.count, arranged[index] === view { continue }
            if let current = arranged.firstIndex(where: { $0 === view }) {
                arranged.remove(at: current)
            }
            arranged.insert(view, at: index)
            insertArrangedSubview(view, at: index)
        }
    }
}

extension LayoutView {
    /// An empty view that takes a stack view's spare space along its axis. It stretches first
    /// because its content hugging priority is the lowest possible.
    public static func spacer() -> LayoutView {
        let spacer = LayoutView()
        spacer.setContentHuggingPriority(.init(1), for: .horizontal)
        spacer.setContentHuggingPriority(.init(1), for: .vertical)
        return spacer
    }
}
#endif
