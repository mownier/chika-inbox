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
import ChikaRegistrar

class ViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    var inboxSceneView: UIView!
    
    override func loadView() {
        super.loadView()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        let factory = Factory()
        let scene = factory.onSelect({ print($0) }).build()
        inboxSceneView = scene.view
        containerView.addSubview(inboxSceneView)
        addChildViewController(scene)
        scene.didMove(toParentViewController: self)
    }
    
    override func viewDidLayoutSubviews() {
        inboxSceneView.frame = containerView.bounds
    }
    
    @IBAction func signIn(_ sender: UIBarButtonItem) {
        let factory = ChikaSignIn.Factory()
        let scene = factory.withOutput(signInOutput).build()
        scene.title = "Sign In"
        navigationController?.pushViewController(scene, animated: true)
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
            navigationController?.popViewController(animated: true)
            
        case .err(let error):
            showAlert(withTitle: "Error", message: "\(error)", from: self)
        }
    }

}
