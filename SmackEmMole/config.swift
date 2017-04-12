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
    var timerBeforeGameStartSeconds = 3
    var timerGameLength = 60
    
    // Board
    var numberOfRows = 7;
    var numberMaxOfColumns: Int = 5;
    var numberMinOfColumns: Int = 4;
    
    // Game
    var numberOfMolePopsInEachLevel: Array<Int> = [
        5, 6, 8, 10, 12, 15
    ]
    
}
