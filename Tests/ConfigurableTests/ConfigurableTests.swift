import Configurable
import Foundation
import Testing

#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
@Suite("Configurable")
struct ConfigurableTests {
    @Test("configure mutates the instance itself and returns it")
    func configureInPlace() {
        let formatter = DateFormatter()
        let configured = formatter.configure { $0.dateFormat = "yyyy-MM-dd" }

        #expect(configured === formatter)
        #expect(formatter.dateFormat == "yyyy-MM-dd")
    }

    @Test("configured returns a changed copy and leaves the original alone")
    func configuredCopiesValues() {
        let empty = NSDiffableDataSourceSnapshot<Int, String>()
        let filled = empty.configured {
            $0.appendSections([0])
            $0.appendItems(["a", "b"])
        }

        #expect(filled.itemIdentifiers == ["a", "b"])
        #expect(empty.numberOfItems == 0)
    }
}
