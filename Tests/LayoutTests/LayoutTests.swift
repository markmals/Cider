#if os(macOS)
import AppKit
import Layout
import Testing

@MainActor
@Suite("Layout")
struct LayoutTests {
    private func makeContainer() -> NSView {
        NSView(frame: NSRect(x: 0, y: 0, width: 100, height: 100))
    }

    @Test("pin(to:insets:) insets each edge inward")
    func pinLeftToRight() {
        let container = makeContainer()
        let child = NSView()
        container.addSubview(child)

        child.pin(to: container, insets: .init(top: 10, leading: 20, bottom: 30, trailing: 40))
        container.layoutSubtreeIfNeeded()

        // AppKit's default coordinate space is unflipped: y grows upward from the bottom edge.
        #expect(child.frame == NSRect(x: 20, y: 30, width: 40, height: 60))
    }

    @Test("pin(to:insets:) mirrors leading and trailing right-to-left")
    func pinRightToLeft() {
        let container = makeContainer()
        container.userInterfaceLayoutDirection = .rightToLeft
        let child = NSView()
        child.userInterfaceLayoutDirection = .rightToLeft
        container.addSubview(child)

        child.pin(to: container, insets: .init(top: 10, leading: 20, bottom: 30, trailing: 40))
        container.layoutSubtreeIfNeeded()

        #expect(child.frame == NSRect(x: 40, y: 30, width: 40, height: 60))
    }

    @Test("frame(width:height:) fixes only the given dimensions")
    func frameFixesDimensions() {
        let container = makeContainer()
        let child = NSView()
        container.addSubview(child)

        child.frame(width: 30).layout {
            $0.heightAnchor == container.heightAnchor - 16
            $0.topAnchor == container.topAnchor
            $0.leadingAnchor == container.leadingAnchor
        }
        container.layoutSubtreeIfNeeded()

        #expect(child.frame.size == NSSize(width: 30, height: 84))
    }

    @Test("frame called again changes the size it fixed instead of adding constraints")
    func frameUpdatesItsOwnConstraints() {
        let container = makeContainer()
        let child = NSView()
        container.addSubview(child)

        child.frame(48)
        child.frame(width: 60)
        child.layout {
            $0.topAnchor == container.topAnchor
            $0.leadingAnchor == container.leadingAnchor
        }
        container.layoutSubtreeIfNeeded()

        #expect(child.frame.size == NSSize(width: 60, height: 48))
        #expect(child.constraints.count == 2)
    }

    @Test("relation operators keep the relation, sign, and priority")
    func relationOperators() {
        let first = NSView()
        let second = NSView()

        let below = first.topAnchor >= second.bottomAnchor + 8
        #expect(below.relation == .greaterThanOrEqual)
        #expect(below.constant == 8)

        let inset = first.trailingAnchor <= second.trailingAnchor - 12 ~ .defaultLow
        #expect(inset.relation == .lessThanOrEqual)
        #expect(inset.constant == -12)
        #expect(inset.priority == .defaultLow)

        let width = first.widthAnchor == 300 ~ .defaultHigh
        #expect(width.relation == .equal)
        #expect(width.constant == 300)
        #expect(width.secondAnchor == nil)
        #expect(width.priority == .defaultHigh)
    }
}
#endif
