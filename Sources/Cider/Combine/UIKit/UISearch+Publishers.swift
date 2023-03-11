//
//  UISearch+Publishers.swift
//
//  Created by Mark Malstrom on 3/11/23.
//

import Combine
import UIKit

public extension UISearchBar {
    var searchTextPublisher: AnyPublisher<String, Never> {
        searchTextField.textPublisher
    }
}

public extension UISearchController {
    var searchTextPublisher: AnyPublisher<String, Never> {
        searchBar.searchTextPublisher
    }
}

extension UISearchBar {
    var searchButtonClickedPublisher: AnyPublisher<String, Never> {
        CombineCoordinator(searchBar)
            .delegate
            .searchBarSearchButtonClickedPublisher
            .eraseToAnyPublisher()
    }
}

extension UISearchBar {
    private final class CombineDelegate: NSObject, UISearchBarDelegate {
        let searchBarSearchButtonClickedPublisher = PassthroughSubject<String, Never>()

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            guard let text = searchBar.text else { return }
            publisher.send(text)
        }
    }

    private final class CombineCoordinator {
        let delegate = CombineDelegate()

        init(_ bar: UISearchBar) { 
            bar.delegate = delegate 
        }
    }
}


