//
//  PopTimersManager.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 4/19/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import Foundation

class GameTimersManager {

    weak var delegate: GameTimersManagerDelegate?
    var anchorDate = Date()
    let utils = Utils()
    var popCellTimers = [String: DelayedTimer]()
    var hideCellTimers = [Cell: DelayedTimer]()
    var regularTimers = [String: DelayedIntervalTimer]()
    
    deinit {
        print("deinit gametimersmanager")
    }
    
    func setAnchorDate(withDate date: Date){
        self.anchorDate = date
    }
    
    func addPopCellTimer(withKey key: String, withDelay delay: Double){
        let popTimer = DelayedTimer(key: key, date: anchorDate, delay: delay, callback: { [weak self] in
            self?.delegate?.cellPrepare()
            self?.popCellTimers.removeValue(forKey: key)
        })
        popTimer.start()
        popCellTimers[key] = popTimer
    }
    
    func addHideCellTimer(forCell cell: Cell, withDelay delay: Double){
        let hideTimer = DelayedTimer(key: cell.cellIndex, date: Date(), delay: delay, callback: { [weak self] in
            self?.delegate?.cellHid(forCell: cell)
            self?.hideCellTimers.removeValue(forKey: cell)
        })
        hideTimer.start()
        hideCellTimers[cell] = hideTimer
    }
    
    func flushAllHideTimers(){
        for(cell, timer) in hideCellTimers {
            timer.stop()
            self.delegate?.cellHid(forCell: cell)
            hideCellTimers.removeValue(forKey: cell)
        }
    }
    
    func pausePopAndHideTimers(){
        
        for (_, timer) in hideCellTimers {
            timer.pause()
        }
        
        for (_, timer) in popCellTimers {
            timer.pause()
        }
 
    }

    func resumePopAndHideTimers(){
        
        for (_, timer) in hideCellTimers {
            timer.resume()
        }
        
        
        for (_, timer) in popCellTimers {
            timer.resume()
        }
    }

    func addDelayedTimer(widthDelay delay: Double, withCallback callback: @escaping () -> ()){
        // regular timer is a regular delayed timer
        let delayedTimer = DelayedTimer(date: Date(), delay: delay, callback: callback)
        delayedTimer.start()
    }
    
    func addDelayedIntervalTimer(forKey key: String, withDelay delay: Double, loops loopsToRun: Int, withInterval interval: Double, forEachIntervalDo loopFunction: @escaping (_ remaining: Int) -> (), withCallback callback: @escaping () -> ()){
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
    
    func addHideSecondsToAllCells(seconds: Double){
        for (_, timer) in hideCellTimers {
            timer.pause()
        }
        
        let t = DelayedTimer(date: Date(), delay: seconds, callback: { [weak self] in
            for (_, timer) in (self?.hideCellTimers)! {
                timer.resume()
            }
        })
        
        t.start()
        
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
    
    var key: Any?    // possible of giving a key to identify the timer
    var date: Date
    let delay: Double
    let callback: (() -> ())?
    var isPaused: Bool = false
    var isStopped: Bool = false
    var timer: Timer?
    var afterPauseNewDelay: Double?
    
    init(date: Date = Date(), delay: Double = 0, callback: (() -> ())?){
        self.date = date
        self.delay = delay
        self.callback = callback
    }
    
    convenience init(key: Any?, date: Date = Date(), delay: Double = 0, callback: (() -> ())?){
        self.init(date: date, delay: delay, callback: callback)
        self.key = key
    }
    
    deinit {
        print("delayed timer deinit")
    }
    
    func start(){
        isStopped = false
        date.addTimeInterval(delay)
        timer = Timer(fire: date, interval: 0, repeats: false, block: { (timer) in
            if let cb = self.callback {
                cb()
            }
            timer.invalidate()
        })
        
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    func pause(){
        if(!isPaused && !isStopped){
            afterPauseNewDelay = Date().timeIntervalSince(date) * -1 // multiply by minus because difference is negative
            timer?.invalidate()
            isPaused = true
        }
    }
    
    func stop(){
        if(!isStopped){
            timer?.invalidate()
            isStopped = true
        }
    }
    
    func resume(){
        if(isPaused && !isStopped){
            date = Date().addingTimeInterval(afterPauseNewDelay!)
            timer = Timer(fire: date, interval: 0, repeats: false, block: { (timer) in
                if let cb = self.callback {
                    cb()
                }
                timer.invalidate()
            })
            
            RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
            isPaused = false
        }
    }
}

class DelayedIntervalTimer: DelayedTimer {
    /*
     This class is for delayed timers who have to perform a task in a loop at some interval
     */
    
    var loops: Int // number of times to perform a task (could change inside the app)
    var interval: Double
    let loopFunction: (_ remaining: Int) -> () // a function to be performed on each interval given the remaining loops parameter
    
    init(date: Date, delay: Double, loopsToRun loops: Int, interval: Double, loopFunction: @escaping (_ remaining: Int) -> (), callback: @escaping () -> ()){
        self.loops = loops
        self.interval = interval
        self.loopFunction = loopFunction
        super.init(date: date, delay: delay, callback: callback)
    }
    
    convenience init(key: Any?, date: Date, delay: Double, loopsToRun loops: Int, interval: Double, loopFunction: @escaping (_ remaining: Int) -> (), callback: @escaping () -> ()){
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
                if let cb = self?.callback {
                    cb()
                }
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
                    if let cb = self?.callback {
                        cb()
                    }
                }
            })
            
            RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
            isPaused = false
        }
    }
    
    func addLoops(moreLoops: Int){
        loops += moreLoops
    }
    
}

protocol GameTimersManagerDelegate: class {
    func cellPrepare()
    func cellHid(forCell cell: Cell)
}
