//
//  PopTimersManager.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 4/19/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import Foundation

class GameTimersManager: DelayedCellTimerDelegate {

    var delegate: GameTimersManagerDelegate?
    var anchorDate = Date()
    let utils = Utils()
    var popCellTimers = [DelayedCellTimer]()
    var hideCellTimers = [CellIndex: DelayedCellTimer]()
    var regularTimers = [String: DelayedIntervalTimer]()
    
    func setAnchorDate(withDate date: Date){
        self.anchorDate = date
    }

    func addListedCellTimer(withDelay delay: Double, withCallback callback: @escaping () -> (hideCellIndex: CellIndex, withDelay: Double, withCallback: () -> Void)){
        let cellTimer = DelayedCellTimer(key: utils.randomString(length: 16), date: anchorDate, delay: delay, callback: callback)
        popCellTimers.append(cellTimer)
        cellTimer.delegate = self
        cellTimer.start()
    }
    
    func pauseAllPopCellTimers(){
        for timer in popCellTimers {
            timer.pause()
        }
    }
    
    func resumeAllPopCellTimers(){
        for timer in popCellTimers {
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
    
    func releaseListedCellTimer(releaseFor cellIndex: CellIndex){
        // TODO: see if the release could be implemented inside this manager class with the help of the delegates
        
        if let timer = hideCellTimers[cellIndex] {
            timer.pause()
            hideCellTimers.removeValue(forKey: cellIndex)
            delegate?.listedCellTimerInvalidated(forCellIndex: cellIndex)
        }
    }
    
    func releaseAllListedCellTimers(){
        for (cellIndex, _) in hideCellTimers {
            if let removedTimer = hideCellTimers.removeValue(forKey: cellIndex){
                removedTimer.pause()
            }
            delegate?.listedCellTimerInvalidated(forCellIndex: cellIndex)
        }
    }
    
    func pauseAllCellTimers(){
        for (_, timer) in hideCellTimers {
            timer.pause()
        }
    }
    
    func resumeAllCellTimers(){
        for (_, timer) in hideCellTimers {
            timer.resume()
        }
    }
    
    // delegate DelayedCellTimerDelegate
    
    func popCellTimerBegan(forKey: String?){
        print("pop cell began: \(String(describing: forKey))")
    }
    
    func popCellTimerFinished(forKey: String?){
        print("pop cell began: \(String(describing: forKey))")
    }
    
    func hideCellTimerBegan(forCellIndex: CellIndex, forTimer: DelayedCellTimer){
        self.hideCellTimers[forCellIndex] = forTimer
    }
    
    func hideCellTimerFinished(forCellIndex: CellIndex){
        self.hideCellTimers.removeValue(forKey: forCellIndex)
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
        print("delayed timer deinit")
    }
    
    func start(){
        date.addTimeInterval(delay)
        timer = Timer(fire: date, interval: 0, repeats: false, block: { (timer) in
            self.callback()
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
            timer = Timer(fire: date.addingTimeInterval(afterPauseNewDelay!), interval: 0, repeats: false, block: { (timer) in
                self.callback()
                timer.invalidate()
            })
            
            RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
            isPaused = false
        }
    }
}

class DelayedCellTimer: DelayedTimer {
    
    var delegate: DelayedCellTimerDelegate?
    var hideCellIndex: CellIndex?
    var _callback: () -> (hideCellIndex: CellIndex, withDelay: Double, withCallback: () -> Void)
    var isInHideTimer: Bool = false
    var popDelayedTimer: DelayedTimer?
    var hideDelayedTimer: DelayedTimer?
    
    init(date: Date = Date(), delay: Double = 0, callback: @escaping () -> (hideCellIndex: CellIndex, withDelay: Double, withCallback: () -> Void)){
        self._callback = callback
        super.init(date: date, delay: delay, callback: {})
    }
    
    convenience init(key: String?, date: Date = Date(), delay: Double = 0, callback: @escaping () -> (hideCellIndex: CellIndex, withDelay: Double, withCallback: () -> Void)){
        self.init(date: date, delay: delay, callback: callback)
        self.key = key
    }

    
    override func start(){
        popDelayedTimer = DelayedTimer(date: date, delay: delay, callback: {
            let (cellIndex, hideTime, hideCallback) = self._callback() // tuple got from game
            self.hideCellIndex = cellIndex
            self.hideDelayedTimer = DelayedTimer(date: Date(), delay: hideTime, callback: { [weak self] in
                hideCallback()
                self?.delegate?.hideCellTimerFinished(forCellIndex: (self?.hideCellIndex)!)
            })
            self.hideDelayedTimer?.start()
            self.isInHideTimer = true
            self.delegate?.hideCellTimerBegan(forCellIndex: (self.hideCellIndex)!, forTimer: self)
            self.delegate?.popCellTimerFinished(forKey: self.key)
        })
        popDelayedTimer?.start()
        delegate?.popCellTimerBegan(forKey: self.key)
    }
    
    override func pause(){
        if(!isPaused){
            hideDelayedTimer?.pause()
            if(!isInHideTimer){
                popDelayedTimer?.pause()
            }
            isPaused = true
        }
    }
    
    override func resume(){
        if(isPaused){
            if(!isInHideTimer){
                popDelayedTimer?.resume()
            }
            hideDelayedTimer?.resume()
            isPaused = false
        }
    }
    
}

protocol DelayedCellTimerDelegate {
    func popCellTimerBegan(forKey: String?)
    func popCellTimerFinished(forKey: String?)
    func hideCellTimerBegan(forCellIndex: CellIndex, forTimer: DelayedCellTimer)
    func hideCellTimerFinished(forCellIndex: CellIndex)
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
            isPaused = false
        }
    }
    
    func addLoops(moreLoops: Int){
        loops += moreLoops
    }
    
}

protocol GameTimersManagerDelegate {
    func listedCellTimerInvalidated(forCellIndex cellIndex: CellIndex)
}
