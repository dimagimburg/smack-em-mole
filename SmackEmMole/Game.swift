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
    var freeCells: Set<CellIndex> = Set<CellIndex>()
    var config: Config = Config.sharedInstance
    
    var timerMain: Timer?
    var dateGameBegins: Date?
    var timeUntilGameEnds: Int
    
    var timerBeforeGameStarted: Timer?
    var timeBeforeGameBegins: Int
    
    var popTimes: [Double] = []
    
    init(){
        timeBeforeGameBegins = config.timerBeforeGameStartSeconds
        timeUntilGameEnds = config.timerGameLength
        gameBoard = gameGenerateGameBoard()
        generateMolePopsTimes()
    }
    
    fileprivate func gameGenerateGameBoard() -> Array<Array<Cell>>{
        // this function generates a 2d array for representing the game board
        
        var gameBoardCellsGenerated: Array<Array<Cell>> = []
        for row in 0..<config.numberOfRows {
            let numberOfColumns: Int = Utils().randomInRange(min: config.numberMinOfColumns, max: config.numberMaxOfColumns)
            var cells: Array<Cell> = []
            for column in 0..<numberOfColumns {
                cells.append(Cell(x: column, y: row))
                freeCells.insert(CellIndex(x: column, y: row))
            }
            gameBoardCellsGenerated.append(cells)
        }
        
        return gameBoardCellsGenerated
    }
    
    fileprivate func generateMolePopsTimes(){
        // function to generate mole pops with the configuration in config.numberOfMolePopsInEachLevel
        
        let numberOfLevelsInOneGame = config.numberOfMolePopsInEachLevel.count
        
        for gameLevel in 0 ... numberOfLevelsInOneGame - 1 {
            for _ in 0 ... config.numberOfMolePopsInEachLevel[gameLevel] - 1 {
                let min: Double = Double(Double(gameLevel) * (Double(config.timerGameLength) / Double(numberOfLevelsInOneGame))) + (gameLevel == 0 ? 1 : 0)
                let max: Double = Double(Double(gameLevel + 1) * (Double(config.timerGameLength) / Double(numberOfLevelsInOneGame)))
                popTimes.append(Utils().randomInRange(min: Double(min), max: Double(max)))
            }
        }
    }
    
    fileprivate func addPopTasks(){
        for i in 0...popTimes.count-1 {
            let date = dateGameBegins?.addingTimeInterval(popTimes[i])
            let timer = Timer(fire: date!, interval: 0, repeats: false, block: { (timer) in
                // TODO: weak reference to self here
                print("poping mole in: ", self.popTimes[i], Date(), " --- ", 61 - self.popTimes[i])
                self.popRandomMole()
            })
            RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        }
    }
    
    fileprivate func popRandomMole(){
        
    }
    
    fileprivate func gameBeforeTimerStart(){
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
        // had to add 0.5 seconds to the time of the game start so we could prepare all dependencies
        dateGameBegins = Date().addingTimeInterval(0.5)
        timerMain = Timer(fireAt: dateGameBegins!, interval: 1.0, target: self, selector: #selector(gameMainTimerTick), userInfo: nil, repeats: true)
        RunLoop.main.add(timerMain!, forMode: RunLoopMode.commonModes)
        addPopTasks()
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
    func molePopped()
    func moleHid()
}
