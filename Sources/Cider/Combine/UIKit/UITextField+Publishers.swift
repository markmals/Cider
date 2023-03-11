//
//  UITextField+Publishers.swift
//
//
//  Created by Mark Malstrom on 3/11/23.
//

import Combine
import UIKit

extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        publisher(for: .editingChanged)
            .map { self.text ?? "" }
            .eraseToAnyPublisher()
    }
}
