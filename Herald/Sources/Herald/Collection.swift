import UIKit
import Combine

@available(iOS 14.0, *)
extension UICollectionView.CellRegistration {
    public var cellProvider: (UICollectionView, IndexPath, Item) -> Cell {
        return { collectionView, indexPath, product in
            collectionView.dequeueConfiguredReusableCell(
                using: self,
                for: indexPath,
                item: product
            )
        }
    }
}

@available(iOS 14.0, *)
extension UICollectionViewDiffableDataSource {
    public convenience init<Cell: CellRegistrable>(
        collectionView: UICollectionView,
        cellRegistrable: Cell.Type
    ) where Cell.Item == ItemIdentifierType {
        let provider = cellRegistrable.makeRegistration().cellProvider
        self.init(collectionView: collectionView, cellProvider: provider)
    }
    
    private typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, ItemIdentifierType>
    
    public convenience init(
        collectionView: UICollectionView,
        @UIView.ViewBuilder content: @escaping (ItemIdentifierType) -> UIView
    ) {
        self.init(
            collectionView: collectionView,
            cellProvider: CellRegistration { cell, _, item in
                cell.contentView.addSubview { content(item) }
            }.cellProvider
        )
    }
    
    public var subscriber: AnySubscriber<NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>, Never> {
        AnySubscriber(DiffableDataSourceSubscriber(self))
    }
    
    private class DiffableDataSourceSubscriber: Subscriber {
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

@available(iOS 14.0, *)
public protocol CellRegistrable {
    associatedtype Item
    static func content(_ item: Item) -> UIView
}

@available(iOS 14.0, *)
extension CellRegistrable {
    public typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Item>

    public static func makeRegistration() -> CellRegistration {
        CellRegistration { cell, _, item in
            cell.contentView.addSubview { content(item) }
        }
    }
}

extension NSDiffableDataSourceSnapshot: ValueConfigurable {
    public func appending(sections: [SectionIdentifierType]) -> Self {
        configure { $0.appendSections(sections) }
    }
    
    public func appending(items: [ItemIdentifierType], to section: SectionIdentifierType) -> Self {
        configure { $0.appendItems(items, toSection: section) }
    }
    
    public func appending(items: [ItemIdentifierType]) -> Self {
        configure { $0.appendItems(items) }
    }
    
    public func apply(to dataSource: UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>?, animatingDifferences: Bool = true) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            dataSource?.apply(self, animatingDifferences: animatingDifferences) { promise(.success(())) }
        }
        .assertNoFailure()
        .eraseToAnyPublisher()
    }
}

extension NSCollectionLayoutItem {
    public convenience init(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension) {
        self.init(layoutSize: NSCollectionLayoutSize(widthDimension: width, heightDimension: height))
    }
}

extension NSCollectionLayoutGroup {
    public class func horizontal(
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension,
        item: NSCollectionLayoutItem,
        count: Int
    ) -> Self {
        horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: width,
                heightDimension: height
            ),
            subitem: item,
            count: count
        )
    }
    
    public class func horizontal(
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension,
        items: [NSCollectionLayoutItem]
    ) -> Self {
        horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: width,
                heightDimension: height
            ),
            subitems: items
        )
    }
    
    public class func vertical(
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension,
        item: NSCollectionLayoutItem,
        count: Int
    ) -> Self {
        vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: width,
                heightDimension: height
            ),
            subitem: item,
            count: count
        )
    }
    
    public class func vertical(
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension,
        items: [NSCollectionLayoutItem]
    ) -> Self {
        vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: width,
                heightDimension: height
            ),
            subitems: items
        )
    }
}

extension UICollectionViewCompositionalLayout {
    @_functionBuilder
    public struct LayoutBuilder {
        public static func buildBlock(_ section: NSCollectionLayoutSection) -> NSCollectionLayoutSection? {
            section
        }
        
        public static func buildExpression(_ section: NSCollectionLayoutSection) -> NSCollectionLayoutSection? {
            section
        }
        
        public static func buildOptional(_ section: NSCollectionLayoutSection?) -> NSCollectionLayoutSection? {
            section
        }
        
        public static func buildEither(first section: NSCollectionLayoutSection) -> NSCollectionLayoutSection? {
            section
        }

        public static func buildEither(second section: NSCollectionLayoutSection) -> NSCollectionLayoutSection? {
            section
        }
        
        public static func buildBlock(_ section: NSCollectionLayoutSection?) -> NSCollectionLayoutSection? {
            section
        }
        
        public static func buildExpression(_ section: NSCollectionLayoutSection?) -> NSCollectionLayoutSection? {
            section
        }
        
        public static func buildEither(first section: NSCollectionLayoutSection?) -> NSCollectionLayoutSection? {
            section
        }

        public static func buildEither(second section: NSCollectionLayoutSection?) -> NSCollectionLayoutSection? {
            section
        }        
    }
    
    public typealias IndexConfigurable = (Int) -> NSCollectionLayoutSection?
    
    public class func indexBuilder(@LayoutBuilder _ sectionProvider: @escaping IndexConfigurable) -> Self {
        Self(sectionProvider: { index, _ in
            sectionProvider(index)
        })
    }
    
    public typealias IndexEnvironmentConfigurable = (Int, NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection?
    
    public class func indexEnvironmentBuilder(@LayoutBuilder _ sectionProvider: @escaping IndexEnvironmentConfigurable) -> Self {
        Self(sectionProvider: { index, environment in
            sectionProvider(index, environment)
        })
    }
}

extension UICollectionView {
    @available(iOS 14.0, *)
    public static func list(_ appearance: UICollectionLayoutListConfiguration.Appearance) -> UICollectionView {
        UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout.list(
                using: UICollectionLayoutListConfiguration(
                    appearance: appearance
                )
            )
        )
    }
}

@available(iOS 14.0, *)
extension UICollectionViewListCell {
    public func configure(cellProvider: (inout UIListContentConfiguration) -> Void) {
        contentConfiguration = defaultContentConfiguration()
            .configure { configuration in
                cellProvider(&configuration)
            }
    }
}

extension UICollectionViewLayout {
    @available(iOS 14.0, *)
    public static func list(_ appearance: UICollectionLayoutListConfiguration.Appearance) -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout.list(
            using: UICollectionLayoutListConfiguration(
                appearance: appearance
            )
        )
    }
}

@available(iOS 14.0, *)
public protocol UIContentConfigurable {
    associatedtype ContentConfiguration: UIContentConfiguration
    init(_ configuration: ContentConfiguration)
}

@available(iOS 14.0, *)
public protocol UIModelViewable: UIContentConfiguration {
    associatedtype ContentView: UIView & UIContentView & UIContentConfigurable
}

@available(iOS 14.0, *)
public extension UIModelViewable  {
    func makeContentView() -> UIView & UIContentView where Self == ContentView.ContentConfiguration {
        ContentView(self)
    }
    
    func updated(for state: UIConfigurationState) -> Self { self }
}
