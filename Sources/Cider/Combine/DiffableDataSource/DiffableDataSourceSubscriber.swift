//
//  DiffableDataSourceSubscriber.swift
//
//
//  Created by Mark Malstrom on 3/11/23.
//

import Combine
import UIKit

internal protocol DiffableDataSource<SectionIdentifierType, ItemIdentifierType> {
    associatedtype SectionIdentifierType: Hashable
    associatedtype ItemIdentifierType: Hashable

    nonisolated func apply(
        _ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>,
        animatingDifferences: Bool,
        completion: (() -> Void)?
    )
}

extension UICollectionViewDiffableDataSource: DiffableDataSource {}
extension UITableViewDiffableDataSource: DiffableDataSource {}

internal final class DiffableDataSourceSubscriber<
    SectionIdentifierType: Hashable,
    ItemIdentifierType: Hashable,
    DataSource: DiffableDataSource<SectionIdentifierType, ItemIdentifierType>
>: Subscriber {
    typealias Input = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>
    typealias Failure = Never

    private var dataSource: DataSource?

    init(_ dataSource: DataSource) {
        self.dataSource = dataSource
    }

    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    func receive(_ input: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>) -> Subscribers.Demand {
        dataSource?.apply(input, animatingDifferences: false, completion: nil)
        return .unlimited
    }

    func receive(completion: Subscribers.Completion<Never>) {
        dataSource = nil
    }
}
