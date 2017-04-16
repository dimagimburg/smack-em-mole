//
//  Score.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 4/16/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import Foundation

class Score {
    let config = Config.sharedInstance
    
    var score: Int = 0
    var doubleMode: Bool = false
    
    func hitRegularMole(){
        score += config.scoreHitMole
        if(doubleMode){
            score += config.scoreHitMole
        }
    }
    
    func hitMaliciousMole(){
        score += config.scoreHitMaliciousMole
    }
    
    func setDoubleMode(isDoubleMode: Bool){
        doubleMode = isDoubleMode
    }
}
