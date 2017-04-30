//
//  PopTimersManager.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 4/19/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import Foundation

class GameTimersManager {

    var delegate: CellTimersManagerDelegate?
    var anchorDate = Date()
    var hideCellTimers = [CellIndex: Timer]()
    
    func setAnchorDate(withDate date: Date){
        self.anchorDate = date
    }

    func addListedCellTimer(withDelay delay: Double, withCallback callback: @escaping () -> (hideCellIndex: CellIndex, withDelay: Double, withCallback: () -> Void)){
        // listed timer is a timer that we can invalidate and we keep it in the hideTimers list
        let delayedDate = anchorDate.addingTimeInterval(delay)
        let timer = Timer(fire: delayedDate, interval: 0, repeats: false, block: { (timer) in
            // TODO: weak reference to self here
            let (cellIndex, hideTime, hideCallback) = callback() // tuple got from game
            let dateMoleToHide = delayedDate.addingTimeInterval(hideTime)
            let timerMoleHide = Timer(fire: dateMoleToHide, interval: 0, repeats: false, block: { (timer) in
                // TODO: weak reference to self here
                hideCallback()
                self.hideCellTimers.removeValue(forKey: cellIndex)
            })
            self.hideCellTimers[cellIndex] = timerMoleHide
            RunLoop.main.add(timerMoleHide, forMode: RunLoopMode.commonModes)
        })
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    func addRegularTimer(widthDelay delay: Double, withCallback callback: @escaping () -> ()){
        // regular timer is a regular delayed timer
        let delayedDate = Date().addingTimeInterval(delay)
        let timer = Timer(fire: delayedDate, interval: 0, repeats: false, block: { (timer) in
            callback()
        })
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    func releaseCellTimer(releaseFor cellIndex: CellIndex){
        if let timer = hideCellTimers[cellIndex] {
            timer.invalidate()
            hideCellTimers.removeValue(forKey: cellIndex)
            delegate?.timerInvalidated(forCellIndex: cellIndex)
        }
    }
    
    func releaseAllCellTimers(){
        for (cellIndex, timer) in hideCellTimers {
            timer.invalidate()
            hideCellTimers.removeValue(forKey: cellIndex)
            delegate?.timerInvalidated(forCellIndex: cellIndex)
        }
    }
    
}

protocol CellTimersManagerDelegate {
    func timerInvalidated(forCellIndex cellIndex: CellIndex)
}
