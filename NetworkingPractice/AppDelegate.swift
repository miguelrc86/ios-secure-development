//
//  AppDelegate.swift
//  ATSPractice
//
//  Created by Miguel D Rojas Cortés on 4/20/19.
//  Copyright © 2019 MRC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true), let items = components.queryItems else { return false }
        
        window?.rootViewController?.dismiss(animated: true, completion: nil)
        
        if let code = items.first, code.name == "code", let value = code.value {
            authCode = value
            NotificationCenter.default.post(name: NSNotification.Name("OAuthAuthorizationCode"), object: nil)
            print("Retrieved code value: \(value)")
            return true
        }
        
        return false
    }
    
    
}

