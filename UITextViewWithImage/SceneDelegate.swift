//
//  SceneDelegate.swift
//  UITextViewWithImage
//
//  Created by Emre on 28.04.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()
        
        let rootController = TextViewController()
        window?.rootViewController = UINavigationController(rootViewController: rootController)
    }
    
}

