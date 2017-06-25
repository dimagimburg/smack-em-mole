//
//  HighScoresViewController.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 6/24/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import UIKit
import MapKit

class HighScoresViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var mapPlayerScore: UILabel!
    @IBOutlet weak var mapPlayerName: UILabel!
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var map: MKMapView!
    let dataManager = SmackEmMoleDataManager()
    
    @IBOutlet weak var highScoresTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        highScoresTableView.delegate = self
        highScoresTableView.dataSource = self
        
        highScoresTableView.isScrollEnabled = false
        highScoresTableView.separatorColor = UIColor.clear
        mapViewContainer.isHidden = true
    }
    
    @IBAction func mapViewBackButtonPressed(_ sender: Any) {
        mapViewContainer.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HighScoreTableViewCell", for: indexPath) as! HighScoreTableViewCell
        
        cell.playerNameLabel.text = dataManager.highscorePersistablePlayers[indexPath.item].name
        cell.playerScoreLabel.text = dataManager.highscorePersistablePlayers[indexPath.item].score
        
        return cell
    }
    
    func  tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.maxHighScores
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var h : CGFloat = CGFloat()
        
        h = highScoresTableView.frame.height / CGFloat(dataManager.maxHighScores)
        
        return h
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected: \(dataManager.highscorePersistablePlayers[indexPath.item].name), score=\(dataManager.highscorePersistablePlayers[indexPath.item].score), lat=\(dataManager.highscorePersistablePlayers[indexPath.item].lat), lng=\(dataManager.highscorePersistablePlayers[indexPath.item].lng)")
        
        mapPlayerName.text = dataManager.highscorePersistablePlayers[indexPath.item].name
        
        mapPlayerScore.text = dataManager.highscorePersistablePlayers[indexPath.item].score
        
        let allAnnotations = map.annotations
        map.removeAnnotations(allAnnotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(
            latitude: CLLocationDegrees(Double(dataManager.highscorePersistablePlayers[indexPath.item].lat)!),
            longitude: CLLocationDegrees(Double(dataManager.highscorePersistablePlayers[indexPath.item].lng)!)
        )
        map.addAnnotation(annotation)
        
        map.setCenter(annotation.coordinate, animated: true)
        
        mapViewContainer.isHidden = false
        
    }
    
    
    
}
