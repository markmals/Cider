//
//  UIButton+convenience.swift
//
//  Created by Mark Malstrom on 3/11/23.
//
//  h/t @johnsundell@mastodon.social:
//  https://www.swiftbysundell.com/tips/creating-closure-based-ui-controls-with-uiaction/
//

import UIKit

extension UIButton {
    convenience init(
        title: String = "",
        image: UIImage? = nil,
        handler: @escaping () -> Void
    ) {
        self.init(primaryAction: UIAction(
            title: title,
            image: image,
            handler: { _ in
                handler()
            }
        ))
    }
}
