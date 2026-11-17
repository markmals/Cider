import Foundation
import Observation

@MainActor
@Observable
final class FormModel {
    var title = "Draft"
    var count = 0
    var isEnabled = false
    var query = ""
    var volume = 5.0
    var filters = Filters()
}

struct Filters {
    var showsDrafts = false
}

/// Counts writes, so tests can tell a skipped assignment from an equal one.
final class WriteCounter: NSObject {
    private(set) var writes = 0
    var text = "" {
        didSet { writes += 1 }
    }
}
