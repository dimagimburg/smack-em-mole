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
    
    // Board
    var numberOfRows = 7;
    var numberMaxOfColumns = 5;
    var numberMinOfColumns = 4;
}
