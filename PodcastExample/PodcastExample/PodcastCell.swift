import UIKit
import SnapKit
import Cider

final class PodcastCell: UIStackView, ContentConfigurable {
    private let nameLabel = UILabel().configure {
        $0.lineBreakMode = .byTruncatingTail
        $0.numberOfLines = 2
        $0.font = .boldSystemFont(ofSize: $0.font.pointSize)
    }
    
    private let creatorLabel = UILabel().configure {
        $0.textColor = .secondaryLabel
    }
    
    private let labelStack = UIStackView().configure {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.distribution = .equalSpacing
        $0.isLayoutMarginsRelativeArrangement = true
        $0.spacing = 5
    }
    
    private let artworkImage = UIImageView().configure {
        $0.contentMode = .scaleAspectFit
        $0.layout.frame(88)
    }
    
    init(_ configuration: Podcast) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        self.axis = .horizontal
        self.alignment = .center
        self.spacing = 15
        self.backgroundColor = UIColor(
            light: .systemBackground,
            dark: .secondarySystemBackground
        )
        
        labelStack.addArrangedSubview(nameLabel)
        labelStack.addArrangedSubview(creatorLabel)
        
        self.addArrangedSubview(artworkImage)
        self.addArrangedSubview(labelStack)
        
        nameLabel.layout.constraints {
            $0.trailing == labelStack - 15
        }
        
        creatorLabel.layout.constraints {
            $0.trailing == nameLabel
        }
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
