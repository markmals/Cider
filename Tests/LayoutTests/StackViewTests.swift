import Layout
import Testing

#if os(macOS)
import AppKit

@MainActor
private func horizontalStack(
    @SubviewBuilder _ views: () -> [NSView]
) -> NSStackView {
    NSStackView(orientation: .horizontal, distribution: .fill, spacing: 0, arrangedSubviews: views)
}

@MainActor
private func layOut(_ view: NSView) { view.layoutSubtreeIfNeeded() }
#else
import UIKit

@MainActor
private func horizontalStack(
    @SubviewBuilder _ views: () -> [UIView]
) -> UIStackView {
    UIStackView(axis: .horizontal, arrangedSubviews: views)
}

@MainActor
private func layOut(_ view: UIView) { view.layoutIfNeeded() }
#endif

@MainActor
@Suite("Stack views")
struct StackViewTests {
    @Test("the builder keeps order through if, else, for and arrays")
    func builderOrder() {
        let first = LayoutView()
        let optional = LayoutView()
        let skipped = LayoutView()
        let alternative = LayoutView()
        let looped = [LayoutView(), LayoutView()]
        let array = [LayoutView()]
        let showsOptional = true

        let stack = horizontalStack {
            first
            if showsOptional { optional }
            if !showsOptional { skipped } else { alternative }
            for view in looped { view }
            array
        }

        #expect(stack.arrangedSubviews == [first, optional, alternative] + looped + array)
    }

    @Test("removing arranged subviews leaves each view's own constraints intact")
    func removeKeepsOwnConstraints() {
        let sized = LayoutView().frame(48)
        let stack = horizontalStack { sized }
        let ownConstraints = sized.constraints.filter(\.isActive)

        stack.removeAllArrangedSubviews()

        #expect(stack.arrangedSubviews.isEmpty)
        #expect(sized.superview == nil)
        #expect(!ownConstraints.isEmpty)
        #expect(ownConstraints.allSatisfy { $0.isActive })
    }

    @Test("replaceArrangedSubviews swaps the stack's contents")
    func replaceSwapsContents() {
        let old = LayoutView()
        let new = LayoutView()
        let stack = horizontalStack { old }

        stack.replaceArrangedSubviews { new }

        #expect(stack.arrangedSubviews == [new])
        #expect(old.superview == nil)
    }

    @Test("a spacer takes the spare space")
    func spacerStretches() {
        let leading = LayoutView().frame(width: 50, height: 10)
        let spacer = LayoutView.spacer()
        let trailing = LayoutView().frame(width: 30, height: 10)
        let stack = horizontalStack {
            leading
            spacer
            trailing
        }
        let container = LayoutView(frame: .init(x: 0, y: 0, width: 200, height: 10))
        container.addSubview(stack)
        stack.pin(to: container)

        layOut(container)

        #expect(spacer.frame.width == 120)
        #expect(trailing.frame.minX == 170)
    }
}
