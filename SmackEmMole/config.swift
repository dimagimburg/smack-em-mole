//
//  config.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 4/3/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import Foundation

class Config {
    
    private init(){}
    
    static let sharedInstance: Config = Config()
    
    // Timers
    let timerBeforeGameStartSeconds = 3
    let timerGameLength = 60
    let timeMinimumMoleShow = 1.5
    let timeMaximumMoleShow = 3.0
    
    // Board
    let numberOfRows = 5;
    let numberMaxOfColumns: Int = 5;
    let numberMinOfColumns: Int = 4;
    
    // Game
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
    
}
