//
//  config.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 4/3/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import Foundation

class Config {
    
    private init(){
        print("init config")
    }
    
    deinit{
        print("deinit config")
    }
    
    static let sharedInstance: Config = Config()
    
    // Timers
    let timerBeforeGameStartSeconds = 3
    let timerGameLength = 60
    let timeMinimumMoleShow = 1.5
    let timeMaximumMoleShow = 3.0
    let timeDoubleMode = 5.0
    let timeQuantityMode = 4.0
    let timePenaltyMode = 3.0
    let timeShakeMode = 3.0
    
    // Board
    let numberOfRows = 5;
    let numberMaxOfColumns: Int = 5
    let numberMinOfColumns: Int = 4
    
    // Score
    let scoreHitMole = 10
    let scoreHitMaliciousMole = -5
    
    // Game
    let numberSecondsAddSpecialTime = 4 // the number of seconds added when special time mole got hit
    let numberMolesPopSpecialTime = 4 // number of moles to pop on the special time
    let numberMolesPopSpecialQuantity = 14 // number of moles to pop on the special of extra quantity
    
    let numberSecondsSpecialExtraOn = 5 // number of seconds special extra is on
    let numberMolePerSecondPopExtra = 3 // number of moles to pop per second when extra mode is active
    
    let numberOfMolePopsInEachLevel: Array<Int> = [
        5, 6, 8, 10, 12, 15
    ]
    let numberChancesToPopMoleType: [MoleType: Double] = [
        // should all numbers be summed to 1
        // should be max 3 digits after point
        MoleType.REGULAR: 0.70,
        MoleType.MALICIOUS: 0.21,
        MoleType.SPECIAL_TIME: 0.03,
        MoleType.SPECIAL_QUANTITY: 0.03,
        MoleType.SPECIAL_DOUBLE: 0.03
    ]
    
    var arrayMoleTypeProbabilities:[MoleType] {
        var spread: [MoleType] = []
        for type in numberChancesToPopMoleType {
            for _ in 0 ... Int(type.value*1000) - 1 {
                spread.append(type.key)
            }
        }
        return spread
    }
    
    enum GameOngoingMode: String {
        case REGULAR
        case SPECIAL_TIME
        case SPECIAL_QUANTITY
        case SPECIAL_DOUBLE
    }
    
    let numberOfShakesAllowed = 3
    
    // Data
    
    enum PersistablePlayerProperties: String {
        case NAME = "name"
        case SCORE = "score"
        case LONGITUDE = "lng"
        case LATITUDE = "lat"
    }
    
    let HIGH_SCORES_FILE_NAME = "highscores_file"
    
}
