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
    
    init(cellIndex: CellIndex){
        self.cellIndex = cellIndex
    }
    
    func setMole(moleType: MoleType?){
        if let type = moleType {
            mole = Mole(type: type)
            return
        }
        
        mole = nil
    }
}
