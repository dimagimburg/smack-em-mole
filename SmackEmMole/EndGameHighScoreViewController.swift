//
//  EndGameViewController.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 6/2/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import UIKit
import CoreLocation

class EndGameHighScoreViewController: UIViewController, CLLocationManagerDelegate {
    
    var player: Player?
    var config: Config = Config.sharedInstance
    let dataManager = SmackEmMoleDataManager()
    let locationManager = CLLocationManager()

    @IBOutlet weak var playerNameTextField: UITextField!
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        if let player = player {
            if let nameFromTextField = playerNameTextField.text {
                player.playerName = nameFromTextField
            }
            dataManager.addHighScore(player: player)
        }
        
        self.performSegue(withIdentifier: "highScoresSegue", sender: nil)

    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        releaseGameViewController()
        setupView()
        setupLocation()
    }
    
    func setupLocation(){
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let player = player {
            let locValue:CLLocationCoordinate2D = manager.location!.coordinate
            player.setLocation(lat: locValue.latitude, lng: locValue.longitude)
            print("getting new location: lat=\(locValue.latitude) lng=\(locValue.longitude)")
        }
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
