import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        let podcastList = PodcastList()
        let navigationController = UINavigationController()
        navigationController.setViewControllers([podcastList], animated: false)
        navigationController.view.backgroundColor = .white
        navigationController.navigationBar.prefersLargeTitles = true
        
        let window = UIWindow(windowScene: scene as! UIWindowScene)
        window.rootViewController = navigationController
        
        self.window = window
        window.makeKeyAndVisible()
    }
}
