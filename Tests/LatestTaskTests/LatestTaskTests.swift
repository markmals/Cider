import LatestTask
import TestSupport
import Testing

@MainActor
private final class Log {
    var entries: [String] = []

    func record(_ result: Result<String, any Error>) {
        switch result {
        case .success(let value): entries.append(value)
        case .failure(let error): entries.append("failure: \(error)")
        }
    }

    func note(_ entry: String) { entries.append(entry) }
}

/// Holds an operation until the test opens it, ignoring cancellation the way a
/// non-cooperative network call would.
private actor Gate {
    private var isOpen = false
    private var waiter: CheckedContinuation<Void, Never>?

    func wait() async {
        guard !isOpen else { return }
        await withCheckedContinuation { waiter = $0 }
    }

    func open() {
        isOpen = true
        waiter?.resume()
        waiter = nil
    }
}

private struct ServiceError: Error, CustomStringConvertible {
    var description: String { "offline" }
}

@MainActor
@Suite("LatestTask", .timeLimit(.minutes(1)))
struct LatestTaskTests {
    @Test("delivers only the latest operation, even when a superseded one finishes later")
    func supersededResultIsDropped() async {
        let task = LatestTask<String>()
        let log = Log()
        let gate = Gate()

        task.run(
            {
                await gate.wait()
                return "first"
            },
            completion: log.record
        )
        task.run({ "second" }, completion: log.record)
        await wait { log.entries == ["second"] }

        await gate.open()
        await settle()
        #expect(log.entries == ["second"])
        #expect(!task.isRunning)
    }

    @Test("cancel() cancels the operation and drops its result")
    func cancelDropsResult() async {
        let task = LatestTask<String>()
        let log = Log()

        task.run(
            {
                do {
                    try await Task.sleep(for: .seconds(30))
                } catch {
                    await log.note("cancelled")
                    throw error
                }
                return "late"
            },
            completion: log.record
        )
        #expect(task.isRunning)
        task.cancel()

        await wait { !log.entries.isEmpty }
        await settle()
        #expect(log.entries == ["cancelled"])
        #expect(!task.isRunning)
    }

    @Test("delivers the latest operation's error as a failure")
    func deliversFailure() async {
        let task = LatestTask<String>()
        let log = Log()

        task.run({ throw ServiceError() }, completion: log.record)

        await wait { !log.entries.isEmpty }
        #expect(log.entries == ["failure: offline"])
    }

    @Test("deallocating it cancels the running operation")
    func deinitCancels() async {
        let log = Log()
        var task: LatestTask<String>? = LatestTask()

        task?.run(
            {
                do {
                    try await Task.sleep(for: .seconds(30))
                } catch {
                    await log.note("cancelled")
                }
                return "late"
            },
            completion: log.record
        )
        task = nil

        await wait { !log.entries.isEmpty }
        await settle()
        #expect(log.entries == ["cancelled"])
    }
}
