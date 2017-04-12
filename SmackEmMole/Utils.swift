//
//  Utils.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 4/12/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import Foundation

class Utils {

    func randomInRange(min: Int, max: Int) -> Int {
        // random int in range taken from: https://gist.github.com/adrfer/6dfb7db29a9c5b9a5b3de1f71008e794#file-int-random-swift-L19
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    func randomInRange(min: Double, max: Double) -> Double {
        // based on: http://stackoverflow.com/a/26029530/2698072
        return Double(arc4random()) / Double(UINT32_MAX) * abs(min - max) + (min < max ? min : max)
    }
    
}
