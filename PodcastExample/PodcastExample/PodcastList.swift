import UIKit
import Combine
import CombineCocoa
import Cider

final class PodcastList: UICollectionViewController {
    typealias Section = UICollectionViewController.SingleSection
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Podcast>
    
    private let searchController = UISearchController()
    
    private let podcasts = PodcastManager()
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var dataSource = DataSource(
        collectionView: collectionView,
        cellType: UICollectionViewListCell.self
    )
    
    convenience init() {
        self.init(collectionViewLayout: .list(usingAppearance: .insetGrouped))
        self.title = "Podcasts"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = dataSource
        
        searchController.searchBar
            .textDidChangePublisher
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .flatMap { self.podcasts.search(for: $0) }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: update(with:))
            .store(in: &cancellables)
    }
}
