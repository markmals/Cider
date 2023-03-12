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

public final class CombineSearchController: UISearchController {
    let _searchBar = CombineSearchBar()

    override public var searchBar: CombineSearchBar {
        _searchBar
    }
}

public final class CombineSearchBar: UISearchBar {
    private final class Coordinator: NSObject, UISearchBarDelegate {
        let searchButtonClickedPublisher = PassthroughSubject<String, Never>()
        let cancelButtonClickedPublisher = PassthroughSubject<Void, Never>()

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            guard let text = searchBar.text else { return }
            searchButtonClickedPublisher.send(text)
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            cancelButtonClickedPublisher.send()
        }
    }

    private let _delegate = Coordinator()
    override public var delegate: UISearchBarDelegate? {
        get { _delegate }
        set {}
    }

    public var searchButtonClickedPublisher: AnyPublisher<String, Never> {
        _delegate.searchButtonClickedPublisher.eraseToAnyPublisher()
    }

    public var cancelButtonClickedPublisher: AnyPublisher<Void, Never> {
        _delegate.cancelButtonClickedPublisher.eraseToAnyPublisher()
    }
}
