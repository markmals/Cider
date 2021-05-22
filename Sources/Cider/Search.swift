import UIKit
import Combine

extension UISearchController {
    var searchButtonClickedPublisher: AnyPublisher<String, Never> {
        SearchBarButtonPublisher(searchBar).eraseToAnyPublisher()
    }

    private final class SearchBarButtonPublisher: Publisher {
        typealias Output = String
        typealias Failure = Never

        private let delegate = SearchBarDelegate()
        init(_ bar: UISearchBar) { bar.delegate = delegate }

        func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, String == S.Input {
            delegate.publisher.receive(subscriber: subscriber)
        }

        private final class SearchBarDelegate: NSObject, UISearchBarDelegate {
            let publisher = PassthroughSubject<String, Never>()

            func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
                guard let text = searchBar.text else { return }
                publisher.send(text)
            }
        }
    }
}
