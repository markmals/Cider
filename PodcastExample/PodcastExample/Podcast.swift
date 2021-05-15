import UIKit
import Cider

struct Podcast: Hashable, ContentConfiguration {
    typealias ContentView = PodcastCell
    let image: UIImage
    let name: String
    let creator: String
}
