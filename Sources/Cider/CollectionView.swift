import UIKit

@available(iOS 14.0, *)
extension UICollectionViewDiffableDataSource where ItemIdentifierType: UIContentConfiguration {
    public convenience init<Cell: UICollectionViewCell>(
        collectionView: UICollectionView,
        cellType: Cell.Type
    ) {
        // FIXME: I don't have any idea how this compiles without specifying the `SectionIdentifierType`
        // None of the informaion here conveys the concrete type of the `SectionIdentifierType`
        
        // Yet, I can still apply a Snapshot<AnyArbitrarySectionIdentifierType> to a data
        // source created with this init.
        
        // Why... How... What if I need to use a method on UICollectionViewDiffableDataSource
        // that needs to know the SectionIdentifierType?
        
        // Where do I use the SectionIdentifierType? Can I configure sections to display differently? Where?
        self.init(collectionView: collectionView) { collectionView, indexPath, data in
            collectionView.dequeueConfiguredReusableCell(
                using: UICollectionView.CellRegistration<Cell, ItemIdentifierType>(),
                for: indexPath,
                item: data
            )
        }
    }
}

@available(iOS 14.0, *)
extension UICollectionViewLayout {
    public static func list(usingAppearance appearance: UICollectionLayoutListConfiguration.Appearance) -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout.list(
            using: UICollectionLayoutListConfiguration(appearance: appearance)
        )
    }
}

@available(iOS 14.0, *)
extension UICollectionView {
    public static func list(usingAppearance appearance: UICollectionLayoutListConfiguration.Appearance) -> UICollectionView {
        UICollectionView(
            frame: .zero,
            collectionViewLayout: .list(usingAppearance: appearance)
        )
    }
}

@available(iOS 14.0, *)
extension UICollectionView.CellRegistration where Item: UIContentConfiguration {
    public init() {
        self.init { cell, _, data in
            cell.contentConfiguration = data
        }
    }
}

import Combine

extension UICollectionViewDiffableDataSource {
    public var subscriber: AnySubscriber<NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>, Never> {
        AnySubscriber(DiffableDataSourceSubscriber(self))
    }
    
    private final class DiffableDataSourceSubscriber: Subscriber {
        typealias Input = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>
        typealias Failure = Never

        private var dataSource: UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>?
        init(_ dataSource: UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>) { self.dataSource = dataSource }

        func receive(subscription: Subscription) {
            subscription.request(.unlimited)
        }

        func receive(_ input: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>) -> Subscribers.Demand {
            dataSource?.apply(input)
            return .unlimited
        }

        func receive(completion: Subscribers.Completion<Never>) {
            dataSource = nil
        }
    }
}

extension NSDiffableDataSourceSnapshot {
    public func appending(sections: [SectionIdentifierType]) -> Self {
        var snapshot = self
        snapshot.appendSections(sections)
        return snapshot
    }
    
    public func appending(items: [ItemIdentifierType], to section: SectionIdentifierType) -> Self {
        var snapshot = self
        snapshot.appendItems(items, toSection: section)
        return snapshot
    }
    
    public func appending(items: [ItemIdentifierType]) -> Self {
        var snapshot = self
        snapshot.appendItems(items)
        return snapshot
    }
}
