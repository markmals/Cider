#if os(macOS)
import AppKit
import Testing

import CocoaObservation
import TestSupport

@MainActor
@Suite("ObservingViewController", .timeLimit(.minutes(1)))
struct ObservingViewControllerTests {
    @Test("renders the initial state once the view loads")
    func initialRender() async {
        let controller = ProbeController(model: ProbeModel())
        controller.loadViewIfNeeded()

        await wait { !controller.renders.isEmpty }
        #expect(controller.renders == [0])
    }

    @Test("re-renders when a property it read changes")
    func reactsToReadProperty() async {
        let model = ProbeModel()
        let controller = ProbeController(model: model)
        controller.loadViewIfNeeded()
        await wait { controller.renders == [0] }

        model.value = 1
        await wait { controller.renders.last == 1 }
        #expect(controller.renders == [0, 1])
    }

    @Test("ignores properties it didn't read")
    func ignoresUnreadProperty() async {
        let model = ProbeModel()
        let controller = ProbeController(model: model)
        controller.loadViewIfNeeded()
        await wait { controller.renders == [0] }

        model.unrelated = 1
        await settle()
        #expect(controller.renders == [0])
    }

    @Test("follows a dependency set that changes between renders")
    func conditionalDependencies() async {
        let model = ProbeModel()
        let controller = ProbeController(model: model)
        controller.read = { $0.showsDetail ? $0.detail : -1 }
        controller.loadViewIfNeeded()
        await wait { controller.renders == [-1] }

        model.detail = 1
        await settle()
        #expect(controller.renders == [-1])

        model.showsDetail = true
        await wait { controller.renders.last == 1 }
        model.detail = 2
        await wait { controller.renders.last == 2 }
        #expect(controller.renders == [-1, 1, 2])
    }

    @Test("coalesces synchronous mutations into one update")
    func coalescesMutations() async {
        let model = ProbeModel()
        let controller = ProbeController(model: model)
        controller.loadViewIfNeeded()
        await wait { controller.renders == [0] }

        model.value = 1
        model.value = 2
        model.value = 3
        await wait { controller.renders.last == 3 }
        #expect(controller.renders == [0, 3])
    }

    @Test("setNeedsUpdateProperties re-renders with no model change")
    func manualInvalidation() async {
        let controller = ProbeController(model: ProbeModel())
        controller.loadViewIfNeeded()
        await wait { controller.renders == [0] }

        controller.setNeedsUpdateProperties()
        await wait { controller.renders.count == 2 }
        #expect(controller.renders == [0, 0])
    }

    @Test("a requested update flushes synchronously and tracking continues")
    func synchronousFlush() async {
        let model = ProbeModel()
        let controller = ProbeController(model: model)
        controller.loadViewIfNeeded()
        await wait { controller.renders == [0] }

        model.value = 7
        controller.setNeedsUpdateProperties()
        controller.updatePropertiesIfNeeded()
        #expect(controller.renders.last == 7)

        model.value = 8
        await wait { controller.renders.last == 8 }
        #expect(controller.renders.last == 8)
    }

    @Test("an invalidation requested during an update isn't lost")
    func reentrantInvalidation() async {
        let controller = ProbeController(model: ProbeModel())
        controller.afterRender = { controller in
            if controller.renders.count == 1 { controller.setNeedsUpdateProperties() }
        }
        controller.loadViewIfNeeded()

        await wait { controller.renders.count == 2 }
        #expect(controller.renders == [0, 0])
    }

    @Test("deallocates while observing")
    func deallocates() async {
        let model = ProbeModel()
        weak var weakController: ProbeController?
        autoreleasepool {
            let controller = ProbeController(model: model)
            controller.loadViewIfNeeded()
            weakController = controller
        }
        await settle()
        #expect(weakController == nil)

        model.value = 1
        await settle()
    }
}
#endif
