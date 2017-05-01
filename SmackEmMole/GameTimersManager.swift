//
//  PopTimersManager.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 4/19/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import Foundation

class GameTimersManager {

    var delegate: GameTimersManagerDelegate?
    var anchorDate = Date()
    var hideCellTimers = [CellIndex: Timer]()
    var regularTimers = [String: RegularDelayedIntervalTimer]()
    
    func setAnchorDate(withDate date: Date){
        self.anchorDate = date
    }

    func addListedCellTimer(withDelay delay: Double, withCallback callback: @escaping () -> (hideCellIndex: CellIndex, withDelay: Double, withCallback: () -> Void)){
        // listed timer is a timer that we can invalidate and we keep it in the hideTimers list
        let delayedDate = anchorDate.addingTimeInterval(delay)
        let timer = Timer(fire: delayedDate, interval: 0, repeats: false, block: { [weak self] (timer) in
            let (cellIndex, hideTime, hideCallback) = callback() // tuple got from game
            let dateMoleToHide = delayedDate.addingTimeInterval(hideTime)
            let timerMoleHide = Timer(fire: dateMoleToHide, interval: 0, repeats: false, block: { [weak self] (timer) in
                hideCallback()
                self?.hideCellTimers.removeValue(forKey: cellIndex)
            })
            self?.hideCellTimers[cellIndex] = timerMoleHide
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
    
    func addRegularTimer(forKey key: String, withDelay delay: Double, loops loopsToRun: Int, withInterval interval: Double, forEachIntervalDo loopFunction: @escaping (_ remaining: Int) -> (), withCallback callback: @escaping () -> ()){
        if loopsToRun < 1 {
            return
        }
        
        let regularDelayedIntervalTimer = RegularDelayedIntervalTimer(key: key, date: Date(), delay: delay, loopsToRun: loopsToRun, interval: interval, loopFunction: loopFunction, callback: callback)
        
        regularDelayedIntervalTimer.start()
        
        regularTimers[key] = regularDelayedIntervalTimer
    }
    
    func addLoops(forTimerKey key: String, loopsAmount loops: Int){
        regularTimers[key]?.addLoops(moreLoops: loops)
    }
    
    func releaseListedCellTimer(releaseFor cellIndex: CellIndex){
        if let timer = hideCellTimers[cellIndex] {
            timer.invalidate()
            hideCellTimers.removeValue(forKey: cellIndex)
            delegate?.listedCellTimerInvalidated(forCellIndex: cellIndex)
        }
    }
    
    func releaseAllListedCellTimers(){
        for (cellIndex, timer) in hideCellTimers {
            timer.invalidate()
            hideCellTimers.removeValue(forKey: cellIndex)
            delegate?.listedCellTimerInvalidated(forCellIndex: cellIndex)
        }
    }
    
}

class RegularDelayedIntervalTimer {
    let key: String
    var date: Date
    let delay: Double
    var loops: Int
    let interval: Double
    let loopFunction: (_ remaining: Int) -> ()
    let callback: () -> ()
    var timer: Timer?
    
    init(key: String, date: Date, delay: Double, loopsToRun: Int, interval: Double, loopFunction: @escaping (_ remaining: Int) -> (), callback: @escaping () -> ()){
        self.key = key
        self.date = date
        self.delay = delay
        self.loops = loopsToRun
        self.interval = interval
        self.loopFunction = loopFunction
        self.callback = callback
    }
    
    func start(){
        date.addTimeInterval(delay)
        
        timer = Timer(fire: date, interval: interval, repeats: true, block: { [weak self] (timer) in
            self?.loopFunction((self?.loops)!)
            self?.loops -= 1
            if((self?.loops)! < 0){
                timer.invalidate()
                self?.callback()
            }
        })
        
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    func addLoops(moreLoops: Int){
        loops += moreLoops
    }

}

protocol GameTimersManagerDelegate {
    func listedCellTimerInvalidated(forCellIndex cellIndex: CellIndex)
}
