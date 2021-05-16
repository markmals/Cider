import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        let podcastList = PodcastList()
        let navigationController = UINavigationController().configure {
            $0.navigationBar.prefersLargeTitles = true
            $0.setViewControllers([podcastList], animated: false)
        }
        
        let window = UIWindow(windowScene: scene as! UIWindowScene).configure {
            $0.rootViewController = navigationController
        }
        
        self.window = window
        window.makeKeyAndVisible()
    }
}
