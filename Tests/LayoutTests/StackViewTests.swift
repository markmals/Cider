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

    @Test("replacing with the same views leaves the stack untouched")
    func replaceWithSameViews() {
        let views = [TrackedView(), TrackedView()]
        let stack = horizontalStack { views }

        stack.replaceArrangedSubviews { views }

        #expect(stack.arrangedSubviews.elementsEqual(views) { $0 === $1 })
        #expect(views.allSatisfy { $0.superviewChanges == 1 })
    }

    @Test("views that stay never leave the hierarchy while others come, go and move")
    func replaceKeepsStayingViews() {
        let staying = [TrackedView(), TrackedView(), TrackedView()]
        let leaving = TrackedView()
        let arriving = TrackedView()
        let stack = horizontalStack {
            staying[0]
            staying[1]
            leaving
            staying[2]
        }

        stack.replaceArrangedSubviews {
            staying[2]
            arriving
            staying[1]
            staying[0]
        }

        #expect(stack.arrangedSubviews == [staying[2], arriving, staying[1], staying[0]])
        #expect(staying.allSatisfy { $0.superviewChanges == 1 })
        #expect(leaving.superview == nil)
    }

    @Test("replacing reaches any arrangement from any other")
    func replaceReachesAnyArrangement() {
        var random = SplitMix64(state: 0x5EED)
        for _ in 0..<300 {
            let views = (0..<8).map { _ in TrackedView() }
            let before = views.shuffled(using: &random).prefix(
                Int.random(in: 0...8, using: &random)
            )
            let after = views.shuffled(using: &random).prefix(Int.random(in: 0...8, using: &random))
            let stack = horizontalStack { Array(before) }

            stack.replaceArrangedSubviews { Array(after) }

            #expect(stack.arrangedSubviews.elementsEqual(after) { $0 === $1 })
            for view in views {
                let wasArranged = before.contains { $0 === view }
                let isArranged = after.contains { $0 === view }
                #expect((view.superview === stack) == isArranged)
                if wasArranged, isArranged { #expect(view.superviewChanges == 1) }
            }
        }
    }

    @Test("a view listed twice is arranged once, where it first appears")
    func replaceIgnoresRepeats() {
        let first = LayoutView()
        let second = LayoutView()
        let stack = horizontalStack { second }

        stack.replaceArrangedSubviews {
            first
            second
            first
        }

        #expect(stack.arrangedSubviews == [first, second])
    }

    #if os(macOS)
    @Test("a field that stays arranged keeps its editing session")
    func replaceKeepsFirstResponder() {
        let field = NSTextField(string: "editing")
        let label = NSTextField(labelWithString: "label")
        let stack = horizontalStack {
            field
            label
        }
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 40),
            styleMask: [.titled],
            backing: .buffered,
            defer: true
        )
        window.contentView?.addSubview(stack)
        window.makeFirstResponder(field)

        stack.replaceArrangedSubviews {
            label
            field
        }

        #expect(field.currentEditor() != nil)
    }
    #endif

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

/// Counts its moves into and out of a superview, to tell a view that stayed put from one that
/// was removed and added back.
private final class TrackedView: LayoutView {
    private(set) var superviewChanges = 0

    #if os(macOS)
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        superviewChanges += 1
    }
    #else
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        superviewChanges += 1
    }
    #endif
}

/// A seeded generator, so the shuffled arrangements are the same on every run.
private struct SplitMix64: RandomNumberGenerator {
    var state: UInt64

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var mixed = state
        mixed = (mixed ^ (mixed >> 30)) &* 0xBF58_476D_1CE4_E5B9
        mixed = (mixed ^ (mixed >> 27)) &* 0x94D0_49BB_1331_11EB
        return mixed ^ (mixed >> 31)
    }
}
