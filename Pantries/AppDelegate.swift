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
        mapVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tab_item_map", comment: "The tab title of the map view."),
            image: #imageLiteral(resourceName: "icon_map_tab"),
            selectedImage: nil
        )
        
        let listVC = PantryListViewController(pantryLoadingFunction: loadPantriesFromGitHub)
        listVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tab_item_list", comment: "The tab title of the list view."),
            image: #imageLiteral(resourceName: "icon_list_tab"),
            selectedImage: nil
        )
        rootTabVC.viewControllers = [mapVC, listVC].map { UINavigationController(rootViewController: $0) }
        
        window.rootViewController = rootTabVC
        window.makeKeyAndVisible()
        
        return true
    }

}

