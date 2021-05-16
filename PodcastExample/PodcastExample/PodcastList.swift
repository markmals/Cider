import UIKit
import Combine
import Cider

final class PodcastList: UICollectionViewController {
    typealias Section = UICollectionViewController.SingleSection
    final class SearchCoordinator: NSObject, UISearchResultsUpdating {
        @Published var text: String = ""
        private var updatedText: String?
        
        func updateSearchResults(for searchController: UISearchController) {
            guard let text = searchController.searchBar.text else { return }
            guard updatedText != text else { return }
            
            DispatchQueue.main.async {
                self.updatedText = text
                self.text = text
            }
        }
    }
    
    private let searchController = UISearchController()
    private let searchCoordinator = SearchCoordinator()
    
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
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = searchCoordinator
        
        navigationItem.searchController = searchController
        collectionView.dataSource = dataSource
        
        searchCoordinator.$text
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .flatMap { PodcastManager().search(for: $0) }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: update(with:))
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
}
