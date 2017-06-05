//
//  EndGameViewController.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 6/2/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import UIKit

class EndGameViewController: UIViewController {
    
    var player: Player?

    @IBAction func submitButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("endgame view will apear")
    }
    
    override func viewDidLoad() {
        print("endgame view did load")
        super.viewDidLoad()
        
        releaseGameViewController()
        
        // Do any additional setup after loading the view.
    }
    
    func releaseGameViewController(){
        if let nvc = self.navigationController, nvc.viewControllers.count > 2 {
            nvc.viewControllers.remove(at: nvc.viewControllers.count - 2)
        }
    }

}
