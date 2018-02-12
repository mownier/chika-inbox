//
//  AppDelegate.swift
//  ChikaInbox
//
//  Created by Mounir Ybanez on 2/6/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import UIKit
import ChikaCore
import ChikaFirebase
import FirebaseCommunity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var onlineOperator: OnlinePresenceSwitcherOperator!
    var offlineOperator: OfflinePresenceSwitcherOperator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        onlineOperator = OnlinePresenceSwitcherOperation()
        offlineOperator = OfflinePresenceSwitcherOperation()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        let switcher = OnlinePresenceSwitcher()
        let completion: (Result<OK>) -> Void = { result in
            print(result)
        }
        let _ = onlineOperator.withCompletion(completion).switchToOnline(using: switcher)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        let switcher = OfflinePresenceSwitcher()
        let completion: (Result<OK>) -> Void = { result in
            print(result)
        }
        let _ = offlineOperator.withCompletion(completion).switchToOffline(using: switcher)
    }

}

func showAlert(withTitle title: String, message: String, from parent: UIViewController) {
    DispatchQueue.main.async {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        parent.present(alert, animated: true, completion: nil)
    }
}

