//
//  Player.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 4/16/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import Foundation

class Player {
    var playerName = ""
    var score = Score()
    
    init(withName playerName: String){
        self.playerName = playerName
    }
}
