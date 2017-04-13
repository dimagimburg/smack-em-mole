//
//  mole.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 4/3/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import Foundation

enum MoleType: Int {
    case REGULAR = 0
    case MALICIOUS = 1
    case SPECIAL_TIME = 2
    case SPECIAL_QUANTITY = 3
    case SPECIAL_DOUBLE = 4
    
    // taken from http://stackoverflow.com/a/27094973/2698072
    static var count: Int { return MoleType.SPECIAL_QUANTITY.hashValue + 1 }
}

class Mole {
    var type: MoleType
    
    init(type: MoleType){
        self.type = type
    }
}
