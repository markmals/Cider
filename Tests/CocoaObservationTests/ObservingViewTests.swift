#if os(macOS)
import AppKit
import Testing

import CocoaObservation
import TestSupport

@MainActor
@Suite("ObservingView", .timeLimit(.minutes(1)))
struct ObservingViewTests {
    @Test("observes only while in a window")
    func observesWithinWindowLifetime() async {
        let model = ProbeModel()
        let view = ProbeView(model: model)
        let window = makeWindow()
        window.contentView?.addSubview(view)
        await wait { view.renders == [0] }

        model.value = 1
        await wait { view.renders.last == 1 }

        view.removeFromSuperview()
        let rendersAtRemoval = view.renders
        model.value = 2
        await settle()
        #expect(view.renders == rendersAtRemoval)
    }

    @Test("reattaching renders the latest state with a single observation loop")
    func reattachResumesTracking() async {
        let model = ProbeModel()
        let view = ProbeView(model: model)
        let window = makeWindow()
        window.contentView?.addSubview(view)
        await wait { view.renders == [0] }

        view.removeFromSuperview()
        window.contentView?.addSubview(view)
        view.removeFromSuperview()
        model.value = 2
        window.contentView?.addSubview(view)
        await wait { view.renders.last == 2 }

        model.value = 3
        await wait { view.renders.last == 3 }
        await settle()
        #expect(view.renders == [0, 2, 3])
    }

    @Test("a flush right after reattaching renders changes made while detached")
    func flushAfterReattach() async {
        let model = ProbeModel()
        let view = ProbeView(model: model)
        let window = makeWindow()
        window.contentView?.addSubview(view)
        await wait { view.renders == [0] }

        view.removeFromSuperview()
        model.value = 4
        window.contentView?.addSubview(view)
        view.updatePropertiesIfNeeded()
        #expect(view.renders.last == 4)
    }
}
#endif
