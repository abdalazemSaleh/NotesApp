//
//  AppDelegate.swift
//  FileManagerTest
//
//  Created by Abdel Azim Saleh on 28/07/2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: DidFinishLunch
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AppConfiguration.configure(application)
        return true
    }
}

extension UIApplication {
    func addTapGestureRecognizer() {
        if let window = connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene {
            if let firstWindow = window.windows.first {
                let tapGesture = UITapGestureRecognizer(target: firstWindow, action: #selector(UIView.endEditing))
                tapGesture.requiresExclusiveTouchType = false
                tapGesture.cancelsTouchesInView = false
                firstWindow.addGestureRecognizer(tapGesture)
            }
        }
    }
}
