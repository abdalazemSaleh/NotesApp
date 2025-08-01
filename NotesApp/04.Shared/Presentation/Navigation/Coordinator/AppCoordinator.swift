import UIKit
import SwiftUI

class AppCoordinator {
    
    var windo: UIWindow?
    var isLogin = false
    
    let router: Router
    
    static let shared = AppCoordinator()
    
    init() {
        self.router = AppRouter(navigationController: .init())
    }
}

// MARK: - Main Coordinatot
extension AppCoordinator: Coordinator {
    func makeWindow(from windoScene: UIWindowScene) {
        let windo = UIWindow(windowScene: windoScene)
        windo.rootViewController = self.router.navigationController
        windo.makeKeyAndVisible()
        self.windo = windo
    }
    
    func resetWindo() {
        guard let window = windo else { return }
        window.rootViewController = self.router.navigationController
        window.makeKeyAndVisible()
        self.windo = window
    }
    
    func start() {
        showHome()
    }
}

extension AppCoordinator {
    func showHome() {
        guard let window = windo else { return }
        UIView.transition(with: window, duration: 1, options: .transitionFlipFromRight) {
            self.resetWindo()
        }
        let vc = NotesListVC()
        router.push(vc)
    }
}
