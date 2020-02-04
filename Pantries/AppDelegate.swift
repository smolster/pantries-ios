//
//  AppDelegate.swift
//  Pantries    
//
//  Created by Josh Johnson on 6/9/18.
//  Copyright © 2018 End Hunger Durham. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let window = UIWindow()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let rootTabVC = UITabBarController(nibName: nil, bundle: nil)
        
        let mapVC = PantryMapViewController(pantryLoadingFunction: loadPantriesFromGitHub)
        mapVC.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "icon_map_tab"), selectedImage: nil)
        
        let listVC = PantryListViewController(
            pantryLoadingFunction: loadPantriesFromGitHub,
            pantryImageProvider: MapViewPantryImageProvider(size: CGSize(width: 50, height: 50))
        )
        listVC.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "icon_list_tab"), selectedImage: nil)
        rootTabVC.viewControllers = [mapVC, listVC].map { UINavigationController(rootViewController: $0) }
        
        window.rootViewController = rootTabVC
        window.makeKeyAndVisible()
        
        return true
    }

}

