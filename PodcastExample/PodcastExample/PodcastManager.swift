import UIKit
import Combine
import Resty
import Nuke

struct PodcastManager: API {
    let baseURL = URL(string: "https://itunes.apple.com")!
    
    func search(for query: String) -> AnyPublisher<[Podcast], Error> {
        struct SearchResults: Decodable {
            let results: [Result]
        }
        
        struct Result: Decodable {
            let artistName: String
            let collectionName: String
            let artworkUrl600: URL
        }
        
        return get(path: "search")
            .queryItems([
                "term": query,
                "media": "podcast"
            ])
            .publisher()
            .decode(type: SearchResults.self, decoder: decoder)
            .map(\.results)
            .flatMap { results in
                Publishers.MergeMany(
                    results.map { result in
                        ImagePipeline.shared
                            .imagePublisher(with: result.artworkUrl600)
                            .assertNoFailure()
                            .map(\.image)
                            .map { (result, $0) }
                    }
                )
            }
            .collect()
            .map { results in
                results.map { (result, image) in
                    Podcast(
                        image: image,
                        name: result.collectionName,
                        creator: result.artistName
                    )
                }
            }
            .eraseToAnyPublisher()
    }
}
