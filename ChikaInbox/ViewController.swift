//
//  ViewController.swift
//  ChikaInbox
//
//  Created by Mounir Ybanez on 2/6/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import UIKit
import ChikaCore
import ChikaSignIn
import ChikaFirebase
import ChikaRegistrar
import FirebaseCommunity

class ViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    var inboxSceneView: UIView!
    
    var hasAuth: Bool {
        guard let uid = FirebaseCommunity.Auth.auth().currentUser?.uid, !uid.isEmpty else {
            return false
        }
        
        return true
    }
    
    override func loadView() {
        super.loadView()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        buildInboxScene()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if hasAuth {
            navigationItem.leftBarButtonItem?.title = "Sign Out"
            
        } else {
            navigationItem.leftBarButtonItem?.title = "Sign In"
        }
    }
    
    override func viewDidLayoutSubviews() {
        inboxSceneView.frame = containerView.bounds
    }
    
    @IBAction func signIn(_ sender: UIBarButtonItem) {
        if hasAuth {
            let presence = OfflinePresenceSwitcher()
            let _ = presence.switchToOffline { result in
                print("switch to offline after sign out:", result)
            }
            
            let action = SignOut()
            let _ = action.signOut { [weak self] result in
                guard let this = self else {
                    return
                }
                
                switch result {
                case .ok(let ok):
                    this.navigationItem.leftBarButtonItem?.title = "Sign In"
                    this.removeInboxScene()
                    showAlert(withTitle: "Success", message: "\(ok)", from: this)
                
                case .err(let error):
                    showAlert(withTitle: "Error", message: "\(error)", from: this)
                }
            }
            
        } else {
            let factory = ChikaSignIn.Factory()
            let scene = factory.withOutput(signInOutput).build()
            scene.title = "Sign In"
            navigationController?.pushViewController(scene, animated: true)
        }

    }
    
    @IBAction func register(_ sender: UIBarButtonItem) {
        let factory = ChikaRegistrar.Factory()
        let scene = factory.withOutput(registerOutput).build()
        scene.title = "Register"
        navigationController?.pushViewController(scene, animated: true)
    }
    
    func signInOutput(_ result: Result<OK>) {
        handleOutput(result)
    }
    
    func registerOutput(_ result: Result<OK>) {
        handleOutput(result)
    }
    
    func handleOutput(_ result: Result<OK>) {
        switch result {
        case .ok:
            let presence = OnlinePresenceSwitcher()
            let _ = presence.switchToOnline { result in
                print("switch to online after sign in:", result)
            }
            
            removeInboxScene()
            buildInboxScene()
            view.setNeedsLayout()
            view.layoutIfNeeded()
            navigationItem.leftBarButtonItem?.title = "Sign Out"
            navigationController?.popViewController(animated: true)
            
        case .err(let error):
            showAlert(withTitle: "Error", message: "\(error)", from: self)
        }
    }
    
    func buildInboxScene() {
        let factory = Factory()
        let scene = factory.withUnreadChatCountTracker({ print($0) }).onSelect({ print($0) }).build()
        inboxSceneView = scene.view
        containerView.addSubview(inboxSceneView)
        addChildViewController(scene)
        scene.didMove(toParentViewController: self)
    }
    
    func removeInboxScene() {
        guard let scene = childViewControllers.filter({ $0 is Scene }).map({ $0 as! Scene }).first,
            inboxSceneView == scene.view else {
            return
        }
        
        view.willRemoveSubview(inboxSceneView)
        inboxSceneView.removeFromSuperview()
        scene.removeFromParentViewController()
        scene.didMove(toParentViewController: nil)
        inboxSceneView = nil
    }

}
