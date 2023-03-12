//
//  UIButton+Publishers.swift
//
//  Created by Mark Malstrom on 3/11/23.
//

import Combine
import UIKit

extension UIButton {
    var tapPublisher: EventPublisher {
        publisher(for: .touchUpInside)
    }
}
