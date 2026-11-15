import UIKit

public protocol UIApp {
    init()
    func sceneConfiguration(for connectingSceneSession: UISceneSession) -> UISceneConfiguration
    func finishedLaunching(with options: [UIApplication.LaunchOptionsKey: Any]?)
}

private class AppDelegate: UIResponder, UIApplicationDelegate {
    static var sceneConfiguration: ((UISceneSession) -> UISceneConfiguration)? = nil
    static var finishedLaunching: ([UIApplication.LaunchOptionsKey: Any]?) -> Void = { _ in }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AppDelegate.finishedLaunching(launchOptions)
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        AppDelegate.sceneConfiguration!(connectingSceneSession)
    }
}

extension UIApp {
    public init() { self.init() }
    
    public static func main() {
        let app = Self()
        AppDelegate.sceneConfiguration = app.sceneConfiguration
        AppDelegate.finishedLaunching = app.finishedLaunching
        AppDelegate.main()
    }
    
    public func finishedLaunching(with options: [UIApplication.LaunchOptionsKey: Any]?) {}
}
