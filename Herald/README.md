# Herald

A collection of convinence methods and extensions, helpers, and DSLs for common UIKit tasks to make them less verbose and more declarative. Just `import Herald` to get started.

Initialize a UIButton with a closure:

```swift
UIButton("My Button") {
    doSomething()
}
```

Subscribe your UICollectionView diffable data source to another publisher: 

```swift
let dataSource: UICollectionViewDiffableDataSource<Section, [Model]>

NetworkManager
    .getDataPublisher()
    .map { models in
        NSDiffableDataSourceSnapshot<Section, [Model]>()
            .appending(sections: [Section.main])
            .appending(items: models)
    }
    .subscribe(dataSource.subscriber)
```

Easy and declarative `UICollectionView.CellRegistration`, with the default content view:

```swift
UICollectionView.CellRegistration<UICollectionViewListCell, Model> { cell, _, model in
    cell.configure {
        $0.text = model.name
        $0.secondaryText = model.price
        $0.image = model.thumbnailImage
        $0.imageProperties.maximumSize = CGSize(width: 60, height: 60)
        $0.imageProperties.reservedLayoutSize = CGSize(width: 60, height: 60)
    }
}
```

Or with a custom content view, via the `UIModelViewable` and `UIContentConfigurable` protocols:

```swift
UICollectionView.CellRegistration<UICollectionViewListCell, Podcast> { cell, _, podcast in
    cell.contentConfiguration = PodcastCell.ViewModel(
        name: podcast.name,
        creator: podcast.creator,
        image: podcast.image
    )
}
```

Configure any (`NS`)object with the `Configurable` protocol and conform any value types to the `ValueConfigurable` protocol for the same behavior:

```swift
public protocol Configurable {
    associatedtype T
    @discardableResult func configure(_ closure: (_ instance: T) -> Void) -> T
}
```

Before `Configurable`:

```swift
let button: UIButton = {
    let button = UIButton() 
    button.setTitle("Buy Now", for: .normal)
    button.tintColor = .white
    button.backgroundColor = .systemBlue
    button.layer.cornerRadius = 10
    button.layer.cornerCurve = .continuous
    button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    return button
}()
```

After `Configurable`:

```swift
let button = UIButton().configure {
    $0.setTitle("Buy Now", for: .normal)
    $0.tintColor = .white
    $0.backgroundColor = .systemBlue
    $0.layer.cornerRadius = 10
    $0.layer.cornerCurve = .continuous
    $0.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
}
```

Declaratively compose a UILabel:

```swift
UILabel(name)
    .italic()
    .textColor(.secondaryLabel)
    .lineBreak(.byWordWrapping)
    .lines(3)
```

Feed strings into a UILabel's text via a Combine Publisher:

```swift
let titleLabel = UILabel("Hello")
// Every time a new title is published, titleLabel will be updated
NetworkManager.getTitlePublisher().subscribe(titleLabel.subscriber)
```

Declarative Auto Layout constraint building with `@resultBuilder`s and operator overloading:

```swift
button.layout {
    $0.topAnchor == safeAreaLayoutGuide.topAnchor - 16
    $0.bottomAnchor == view.bottomAnchor - 16
    $0.leftAnchor == view.leftAnchor - 16
    $0.rightAnchor == view.rightAnchor - 16
    $0.widthAnchor <= view.widthAnchor
    $0.centerXAnchor == view.centerXAnchor
}
```

Declarative `@resultBuilder` UIStackView initializer:

```swift
UIStackView(
    axis: .vertical, 
    alignment: .leading, 
    spacing: 5
) {
    UILabel(name)
        .lineBreak(.byWordWrapping)
        .lines(2)
        .bold()

    if let author = creator.author {
        UILabel(author)
            .textColor(.secondaryLabel)
    }
}
.margins(top: 10)
```

A reactive rendering method for UIStackView which is updated with a Combine Publisher.

Every time the `viewModel` changes, the stack view will be rerendered with the new data.

```swift
@Published var viewModel: ViewModel
let stackView = UIStackView()

override func viewDidLoad() {
    stackView.render(onValue: self.$viewModel) { vm in
        UIImageView(image: vm.image)
            .contentMode(.scaleAspectFit)
            .frame(80)

        UIView.spacer()

        UIStackView(
            axis: .vertical, 
            alignment: .leading, 
            spacing: 10
        ) {
            UILabel(vm.name)
                .lineBreak(.byWordWrapping)
                .lines(2)
                .bold()

            if let author = vm.creator.author {
                UILabel(author)
                    .textColor(.secondaryLabel)
            }
        }
        .margins(10)
    }
    .store(in: &cancellables)
}
```

Additionally, you can render like this with any UIView.

Finally, UIView has a `@resultBuilder` closure argument for `addSubviews` now:

```swift
containerView.addSubview {
    if model.demo {
        demoView
    } else {
        UIStackView(axis: .vertical) {
            stackView

            titleLabel

            if let price = model.price {
                UIButton("\(price)") {
                    ApplePay.charge(price)
                }
            }
        }
    }
}