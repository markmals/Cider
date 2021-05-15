import UIKit
import Cider

final class PodcastCell: UIStackView, ContentConfigurable {
    private let nameLabel = UILabel()
    private let creatorLabel = UILabel()
    private let labelStack = UIStackView()
    private let artworkImage = UIImageView()
    
    init(_ configuration: Podcast) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        labelStack.addArrangedSubview(nameLabel)
        labelStack.addArrangedSubview(creatorLabel)
        self.addArrangedSubview(artworkImage)
        self.addArrangedSubview(labelStack)
        
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.numberOfLines = 2
        nameLabel.font = .boldSystemFont(ofSize: nameLabel.font.pointSize)
        nameLabel.layout {
            $0.trailingAnchor == labelStack.trailingAnchor - 20
        }
        
        creatorLabel.textColor = .secondaryLabel
        
        labelStack.axis = .vertical
        labelStack.alignment = .leading
        labelStack.distribution = .equalSpacing
        labelStack.isLayoutMarginsRelativeArrangement = true
        labelStack.spacing = 5
        labelStack.layout {
            $0.trailingAnchor == self.trailingAnchor
        }
        
        artworkImage.contentMode = .scaleAspectFit
        artworkImage.layout {
            $0.widthAnchor == 88
            $0.heightAnchor == 88
        }
        
        self.axis = .horizontal
        self.alignment = .center
        self.spacing = 15
        self.backgroundColor = .white
    }
    
    public var configuration: UIContentConfiguration {
        didSet {
            let podcast = configuration as! Podcast
            artworkImage.image = podcast.image
            nameLabel.text = podcast.name
            creatorLabel.text = podcast.creator
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("Unimplemented")
    }
}
