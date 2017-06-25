//
//  ViewController.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 4/3/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // release all other view controllers that are not main menu
        if let nvc = self.navigationController, nvc.viewControllers.count > 2 {
            print("cleaning view controllers")
            nvc.viewControllers = [nvc.viewControllers[0]]
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

