import UIKit
import Combine
import Cider

final class PodcastList: UICollectionViewController {
    typealias Section = UICollectionViewController.SingleSection
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var dataSource = UICollectionViewDiffableDataSource<Section, Podcast>(
        collectionView: collectionView,
        cellType: UICollectionViewListCell.self
    )
    
    convenience init() {
        self.init(collectionViewLayout: .list(usingAppearance: .insetGrouped))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Podcasts"
        collectionView.dataSource = dataSource
        
        PodcastManager()
            .search(for: "Headgum")
            .assertNoFailure()
            .sink(receiveValue: update(with:))
            .store(in: &cancellables)
    }
}
