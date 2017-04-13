//
//  Cell.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 4/8/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import Foundation

struct CellIndex: Hashable {
    var x: Int
    var y: Int
    
    var hashValue: Int {
        // taken from: https://math.stackexchange.com/a/23506/349381
        return /*Int((0.5 * Double(x + y) * Double(x + y + 1)) + y)*/ Int(0.5*Double(x+y)*Double(x+y+1)) + y
    }
    
    static func ==(lhs: CellIndex, rhs: CellIndex) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

class Cell {
    var mole: Mole? = nil
    var cellIndex: CellIndex
    
    init(x: Int, y: Int){
        self.cellIndex = CellIndex(x: x, y: y)
    }
    
    func setRandomMole(){
        let moleTypeIndex = Utils().randomInRange(min: 0, max: MoleType.count)
        mole = Mole(type: MoleType(rawValue: moleTypeIndex)!)
    }
}
