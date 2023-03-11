//
//  UITableViewDiffableDataSource+subscriber.swift
//
//  Created by Mark Malstrom on 3/11/23.
//

import Combine
import UIKit

public extension UITableViewDiffableDataSource {
    var subscriber: AnySubscriber<NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>, Never> {
        AnySubscriber(DiffableDataSourceSubscriber(self))
    }
}
