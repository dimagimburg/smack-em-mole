//
//  PersistablePlayer.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 6/5/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import Foundation

class PersistablePlayer: NSObject, NSCoding {

    var name: String
    var score: String
    var lng: String
    var lat: String
    
    
    init(name: String, score: String, lng: String, lat: String){
        self.name = name
        self.score = score
        self.lng = lng
        self.lat = lat
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard
            let name = aDecoder.decodeObject(forKey: Config.PersistablePlayerProperties.NAME.rawValue) as? String,
            let score = aDecoder.decodeObject(forKey: Config.PersistablePlayerProperties.SCORE.rawValue) as? String,
            let lng = aDecoder.decodeObject(forKey: Config.PersistablePlayerProperties.LONGITUDE.rawValue) as? String,
            let lat = aDecoder.decodeObject(forKey: Config.PersistablePlayerProperties.LATITUDE.rawValue) as? String
            else { return nil }
        
        self.name = name
        self.score = score
        self.lng = lng
        self.lat = lat
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: Config.PersistablePlayerProperties.NAME.rawValue)
        aCoder.encode(score, forKey: Config.PersistablePlayerProperties.SCORE.rawValue)
        aCoder.encode(lng, forKey: Config.PersistablePlayerProperties.LONGITUDE.rawValue)
        aCoder.encode(lat, forKey: Config.PersistablePlayerProperties.LATITUDE.rawValue)
    }
    
}
