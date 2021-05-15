import UIKit

@available(iOS 14.0, *)
public protocol ContentConfiguration: UIContentConfiguration {
    associatedtype ContentView: UIView & ContentConfigurable
}

@available(iOS 14.0, *)
extension ContentConfiguration  {
    public func makeContentView() -> UIView & UIContentView where Self == ContentView.Configuration {
        ContentView(self)
    }
    
    public func updated(for state: UIConfigurationState) -> Self { self }
}

@available(iOS 14.0, *)
public protocol ContentConfigurable: UIContentView {
    associatedtype Configuration: UIContentConfiguration
    init(_ configuration: Configuration)
}
