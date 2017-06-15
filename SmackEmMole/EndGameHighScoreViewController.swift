//
//  EndGameViewController.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 6/2/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import UIKit

class EndGameHighScoreViewController: UIViewController {
    
    var player: Player?
    var config: Config = Config.sharedInstance

    @IBOutlet weak var playerNameTextField: UITextField!
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        releaseGameViewController()
        setupView()
    }
    
    private func releaseGameViewController(){
        if let nvc = self.navigationController, nvc.viewControllers.count > 2 {
            nvc.viewControllers.remove(at: nvc.viewControllers.count - 2)
        }
    }
    
    private func setupView(){
        playerNameTextField.placeholder = player?.playerName
    }

}
