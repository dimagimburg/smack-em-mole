//
//  Game.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 4/8/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import Foundation

class Game {
    
    // more about delegation https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Protocols.html
    var delegate: SmackEmMoleDelegate?
    var gameBoard: Array<Array<Cell>>!
    var config: Config = Config.sharedInstance
    
    var timerMain: Timer?
    var timeUntilGameEnds: Int
    
    var timerBeforeGameStarted: Timer?
    var timeBeforeGameBegins: Int
    
    init(){
        timeBeforeGameBegins = config.timerBeforeGameStartSeconds
        timeUntilGameEnds = config.timerGameLength
        gameBoard = gameGenerateGameBoard()
    }
    
    fileprivate func gameGenerateGameBoard() -> Array<Array<Cell>>{
        // this function generates a 2d array for representing the game board
        
        var gameBoardCellsGenerated: Array<Array<Cell>> = []
        for _ in 0..<config.numberOfRows {
            // random int in range taken from: https://gist.github.com/adrfer/6dfb7db29a9c5b9a5b3de1f71008e794#file-int-random-swift-L19
            let numberOfColumns = config.numberMinOfColumns + Int(arc4random_uniform(UInt32(config.numberMaxOfColumns - config.numberMinOfColumns + 1)))
            var cells: Array<Cell> = []
            for _ in 0..<numberOfColumns {
                cells.append(Cell())
            }
            gameBoardCellsGenerated.append(cells)
        }
        
        return gameBoardCellsGenerated
    }
    
    fileprivate func gameBeforeTimerStart(){
        timerBeforeGameStarted = Timer()
        timerBeforeGameStarted = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(gameBeforeTimerTick), userInfo: nil, repeats: true)
        delegate?.gameBeforeTimerStarted(secondsToZero: config.timerBeforeGameStartSeconds)
    }
    
    @objc func gameBeforeTimerTick(){
        
        if (timeBeforeGameBegins == 0){
            gameBeforeTimerRelease()
            gameMainTimerStart()
            return
        }
        
        delegate?.gameBeforeTimerSecondTick(second: timeBeforeGameBegins)
        timeBeforeGameBegins -= 1
    }
    
    fileprivate func gameBeforeTimerRelease(){
        timerBeforeGameStarted?.invalidate()
        timerBeforeGameStarted = nil
        delegate?.gameBeforeTimerFinished()
    }
    
    fileprivate func gameMainTimerStart(){
        timerMain = Timer()
        timerMain = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(gameMainTimerTick), userInfo: nil, repeats: true)
        delegate?.gameStarted()
    }
    
    @objc fileprivate func gameMainTimerTick(){
        if(timeUntilGameEnds == 0){
            gameMainTimerFinished()
            return
        }
        
        delegate?.gameMainTimerTick(second: timeUntilGameEnds)
        timeUntilGameEnds -= 1
    }
    
    fileprivate func gameMainTimerRelease(){
        timerMain?.invalidate()
        timerMain = nil
    }
    
    fileprivate func gameMainTimerFinished(){
        gameStop()
        gameFinished()
    }
    
    fileprivate func gameFinished(){
        delegate?.gameFinished()
    }
    
    public func gameStart(){
        gameBeforeTimerStart()
    }
    
    public func gamePause(){
    
    }
    
    public func gameStop(){
        gameMainTimerRelease()
        delegate?.gameStopped()
    }
    
    public func gameBeginSpecialMode(){
    
    }
    
    public func gameEndSpecialMode(){
    
    }
    
    public func molePop(){
    
    }
    
    public func moleHide(){
    
    }
    
    public func molePopSpecial(){
    
    }
    
    public func moleHideSpecial(){
    
    }
    
    public func moleHit(){
    
    }
    
    public func moleHitSpecial(){
    
    }
    
    public func scroeIncrease(){
    
    }
    
    public func scoreDecrease(){
    
    }
}

protocol SmackEmMoleDelegate {
    func gameBeforeTimerStarted(secondsToZero: Int)
    func gameBeforeTimerSecondTick(second: Int)
    func gameBeforeTimerFinished()
    func gameMainTimerTick(second: Int)
    func gameStarted()
    func gamePaused()
    func gameStopped()
    func gameFinished()
}
