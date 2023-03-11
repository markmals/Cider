//
//  UISearch+Publishers.swift
//
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
