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
    var regularTimers = [String: DelayedIntervalTimer]()
    
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
        
        let delayedIntervalTimer = DelayedIntervalTimer(key: key, date: Date(), delay: delay, loopsToRun: loopsToRun, interval: interval, loopFunction: loopFunction, callback: callback)
        
        delayedIntervalTimer.start()
        
        regularTimers[key] = delayedIntervalTimer
    }
    
    func pauseRegularTimer(forKey key: String){
        regularTimers[key]?.pause()
    }
    
    func resumeRegularTimer(forKey key: String){
        regularTimers[key]?.resume()
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
        for (cellIndex, _) in hideCellTimers {
            if let removedTimer = hideCellTimers.removeValue(forKey: cellIndex){
                removedTimer.invalidate()
            }
            delegate?.listedCellTimerInvalidated(forCellIndex: cellIndex)
        }
    }
    
}

protocol DelayedTimerProtocol {
    func start()
    func pause()
    func resume()
}


class DelayedTimer: DelayedTimerProtocol {
    /*
     DelayedTimer class lets you control your timer before it gets fired, so you can pause it and resume
     checked to be free of retain cycles by default: https://gist.github.com/dimagimburg/e554bcc3a2f21b6f50f5ecce30169a99 (run on playground)
     */
    
    var key: String?    // possible of giving a key to identify the timer
    var date: Date
    let delay: Double
    let callback: () -> ()
    var isPaused: Bool = false
    var timer: Timer?
    var afterPauseNewDelay: Double?
    
    init(date: Date = Date(), delay: Double = 0, callback: @escaping () -> ()){
        self.date = date
        self.delay = delay
        self.callback = callback
    }
    
    convenience init(key: String?, date: Date = Date(), delay: Double = 0, callback: @escaping () -> ()){
        self.init(date: date, delay: delay, callback: callback)
        self.key = key
    }
    
    deinit {
        
    }
    
    func start(){
        date.addTimeInterval(delay)
        timer = Timer(fire: date, interval: 0, repeats: false, block: { [weak self] (timer) in
            self!.callback()
            timer.invalidate()
        })
        
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    func pause(){
        if(!isPaused){
            afterPauseNewDelay = Date().timeIntervalSince(date) * -1 // multiply by minus because difference is negative
            timer?.invalidate()
            isPaused = true
        }
    }
    
    func resume(){
        if(isPaused){
            date = Date()
            timer = Timer(fire: date.addingTimeInterval(afterPauseNewDelay!), interval: 0, repeats: false, block: { [weak self] (timer) in
                self!.callback()
                timer.invalidate()
            })
            
            RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
        }
    }
}

class DelayedIntervalTimer: DelayedTimer {
    /*
     This class is for delayed timers who have to perform a task in a loop at some interval
     */
    
    var loops: Int                              // number of times to perform a task (could change inside the app)
    var interval: Double
    let loopFunction: (_ remaining: Int) -> ()  // a function to be performed on each interval given the remaining loops parameter
    
    init(date: Date, delay: Double, loopsToRun loops: Int, interval: Double, loopFunction: @escaping (_ remaining: Int) -> (), callback: @escaping () -> ()){
        self.loops = loops
        self.interval = interval
        self.loopFunction = loopFunction
        super.init(date: date, delay: delay, callback: callback)
    }
    
    convenience init(key: String?, date: Date, delay: Double, loopsToRun loops: Int, interval: Double, loopFunction: @escaping (_ remaining: Int) -> (), callback: @escaping () -> ()){
        self.init(date: date, delay: delay, loopsToRun: loops, interval: interval, loopFunction: loopFunction, callback: callback)
        self.key = key
    }
    
    override func start(){
        date.addTimeInterval(delay)
        
        timer = Timer(fire: date, interval: interval, repeats: true, block: { [weak self] (timer) in
            // TODO: move to separate function - code duplication
            self?.loopFunction((self?.loops)!)
            self?.loops -= 1
            if((self?.loops)! < 0){
                timer.invalidate()
                self?.callback()
            }
        })
        
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    override func resume() {
        if(isPaused){
            let customDelay: Double = 0.5
            timer = Timer(fire: Date().addingTimeInterval(customDelay), interval: interval, repeats: true, block: { [weak self] (timer) in
                // TODO: move to separate function - code duplication
                self?.loopFunction((self?.loops)!)
                self?.loops -= 1
                if((self?.loops)! < 0){
                    timer.invalidate()
                    self?.callback()
                }
            })
            
            RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
        }
    }
    
    func addLoops(moreLoops: Int){
        loops += moreLoops
    }
    
}

/*
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
            // TODO: move to separate function - code duplication
            self?.loopFunction((self?.loops)!)
            self?.loops -= 1
            if((self?.loops)! < 0){
                timer.invalidate()
                self?.callback()
            }
        })
        
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    func pause(){
        timer?.invalidate()
    }
    
    func resume(){
        timer = Timer(fire: Date().addingTimeInterval(0.5), interval: interval, repeats: true, block: { [weak self] (timer) in
            // TODO: move to separate function - code duplication
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
*/

protocol GameTimersManagerDelegate {
    func listedCellTimerInvalidated(forCellIndex cellIndex: CellIndex)
}
