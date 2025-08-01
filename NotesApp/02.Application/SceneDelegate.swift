//
//  SceneDelegate.swift
//  FileManagerTest
//
//  Created by Abdel Azim Saleh on 28/07/2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Properties
    var window: UIWindow?

    // MARK: - WillConnectTo
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        AppCoordinator.shared.makeWindow(from: windowScene)
        AppCoordinator.shared.start()
    }
}

