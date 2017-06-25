//
//  Player.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 4/16/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import Foundation

class Player {
    var playerName = "Player Name"
    var score = Score()
    var lng: Double?
    var lat: Double?
    
    init(withName playerName: String){
        self.playerName = playerName
    }
    
    func setLocation(lat: Double?, lng: Double?){
        if let lat = lat, let lng = lng {
            self.lat = lat
            self.lng = lng
        }
    }
}
