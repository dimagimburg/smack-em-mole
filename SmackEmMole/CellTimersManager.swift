//
//  PopTimersManager.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 4/19/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import Foundation

class CellTimersManager {

    var anchorDate = Date()
    var hideTimers = [CellIndex: Timer]()
    
    func setAnchorDate(withDate date: Date){
        self.anchorDate = date
    }

    func addTimer(withDelay delay: Double, withCallback callback: @escaping () -> (hideCellIndex: CellIndex, withDelay: Double, withCallback: () -> Void)){
        let delayedDate = anchorDate.addingTimeInterval(delay)
        let timer = Timer(fire: delayedDate, interval: 0, repeats: false, block: { (timer) in
            // TODO: weak reference to self here
            let (cellIndex, hideTime, hideCallback) = callback()
            let dateMoleToHide = delayedDate.addingTimeInterval(hideTime)
            let timerMoleHide = Timer(fire: dateMoleToHide, interval: 0, repeats: false, block: { (timer) in
                // TODO: weak reference to self here
                hideCallback()
                self.hideTimers.removeValue(forKey: cellIndex)
            })
            self.hideTimers[cellIndex] = timerMoleHide
            RunLoop.main.add(timerMoleHide, forMode: RunLoopMode.commonModes)
        })
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }
    
}
