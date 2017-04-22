//
//  Game.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 4/8/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import Foundation

class Game: CellTimersManagerDelegate {
    
    // TODO:
    // 1. naming conventions for functions
    // 2. before game timer move to ui and not bl
    // 3. make order with x and y and use row and column instead or section and row
    // 4. consider moving - all - game timers of all kinds to a special service (2)
    
    // more about delegation https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Protocols.html
    
    var delegate: SmackEmMoleDelegate?
    var gameBoard: Array<Array<Cell>>!
    var freeCells: [Cell] = [Cell]()
    var config: Config = Config.sharedInstance
    var utils = Utils()
    var player = Player(withName: "Player (default)")
    var currentOngoingGameMode = Config.GameOngoingMode.REGULAR
    var cellTimersManager = CellTimersManager()
    
    var timerMain: Timer?
    var dateGameBegins: Date?
    var timeUntilGameEnds: Int
    
    var timerBeforeGameStarted: Timer?
    var timeBeforeGameBegins: Int
    
    var popTimes: [Double]!
    
    // counts the number of times the special time mole hit in order to know when to add more mole pops when time is added
    var specialTimeMoleHit: Int = 0
    
    init(){
        timeBeforeGameBegins = config.timerBeforeGameStartSeconds
        timeUntilGameEnds = config.timerGameLength
        gameBoard = gameGenerateGameBoard()
        popTimes = generateMolePopsTimes()
        
        // delegation
        cellTimersManager.delegate = self
    }
    
    fileprivate func gameGenerateGameBoard() -> Array<Array<Cell>>{
        // this function generates a 2d array for representing the game board
        
        var gameBoardCellsGenerated: Array<Array<Cell>> = []
        for row in 0..<config.numberOfRows {
            let numberOfColumns: Int = utils.randomInRange(min: config.numberMinOfColumns, max: config.numberMaxOfColumns)
            var cells: Array<Cell> = []
            for column in 0..<numberOfColumns {
                let cellIndex: CellIndex = CellIndex(x: column, y: row)
                let cell = Cell(cellIndex: cellIndex)
                freeCells.append(cell)
                cells.append(cell)
            }
            gameBoardCellsGenerated.append(cells)
        }
        
        return gameBoardCellsGenerated
    }
    
    fileprivate func generateMolePopsTimes() -> [Double]{
        // function to generate mole pops with the configuration in config.numberOfMolePopsInEachLevel
        var popTimes: [Double] = []
        let numberOfLevelsInOneGame = config.numberOfMolePopsInEachLevel.count
        
        for gameLevel in 0 ... numberOfLevelsInOneGame - 1 {
            for _ in 0 ... config.numberOfMolePopsInEachLevel[gameLevel] - 1 {
                let min: Double = Double(Double(gameLevel) * (Double(config.timerGameLength) / Double(numberOfLevelsInOneGame))) + (gameLevel == 0 ? 1 : 0)
                let max: Double = Double(Double(gameLevel + 1) * (Double(config.timerGameLength) / Double(numberOfLevelsInOneGame)))
                popTimes.append(utils.randomInRange(min: Double(min), max: Double(max)))
            }
        }
        
        return popTimes
    }
    
    fileprivate func addMolePopTimers(){
        for i in 0...popTimes.count-1 {
            setRandomMolePopAndHide(withDelay: popTimes[i])
        }
    }
    
    fileprivate func setRandomMolePopAndHide(withDelay delay: Double){
        cellTimersManager.addTimer(withDelay: delay, withCallback: {
            let cell = self.getRandomCell()
            self.delegate?.molePopped(x: cell.cellIndex.x, y: cell.cellIndex.y, moleType: (cell.mole?.type)!)
            let timeMoleToBeShown = self.utils.randomInRange(min: self.config.timeMinimumMoleShow, max: self.config.timeMaximumMoleShow)
            
            return (cell.cellIndex, timeMoleToBeShown, {
                cell.setMole(moleType: nil)
                self.freeCells.append(cell)
                self.moleHide(cell: cell)
            })
        })
    }
    
    fileprivate func getRandomCell() -> Cell {
        let randomCellIndex = self.utils.randomInRange(min: 0, max: self.freeCells.count - 1)
        let cell = self.freeCells.remove(at: randomCellIndex)
        
        let randomMoleType = self.config.arrayMoleTypeProbabilities[self.utils.randomInRange(min: 0, max: self.config.arrayMoleTypeProbabilities.count - 1)]
        
        cell.setMole(moleType: randomMoleType)
        return cell
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
        cellTimersManager.setAnchorDate(withDate: dateGameBegins!)
        timerMain = Timer(fireAt: dateGameBegins!, interval: 1.0, target: self, selector: #selector(gameMainTimerTick), userInfo: nil, repeats: true)
        RunLoop.main.add(timerMain!, forMode: RunLoopMode.commonModes)
        addMolePopTimers()
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
    
    public func moleHide(cell: Cell){
        delegate?.moleHid(x: cell.cellIndex.x, y: cell.cellIndex.y)
    }
    
    public func moleHide(forCellIndex cellIndex: CellIndex){
        delegate?.moleHid(x: cellIndex.x, y: cellIndex.y)
    }
    
    public func cellPressed(x: Int, y: Int){
        let cellPressed = gameBoard[y][x]
        if(cellPressed.mole != nil){
            moleHit(moleType: (cellPressed.mole?.type)!)
        }
        
        // this is not right, only for debug purposes, the right handle should be in the if statement above
        // and releasing the timer properly.
        moleHide(cell: cellPressed)
    }
    
    public func moleHit(moleType: MoleType){
        switch moleType {
        case MoleType.MALICIOUS:
            if(player.score.score > 0){
                moleHitMalicious()
            }
            // TODO: here make a release to all timers running right now, sort of board clearance as a penalty for hitting malicious mole
            
            cellTimersManager.releaseAllTimers()
            break
        case MoleType.REGULAR:
            moleHitRegular()
            break
        default:
            moleHitSpecial(moleType: moleType)
            break
        }
        
        delegate?.scoreChanged(score: player.score)
    }
    
    public func moleHitMalicious(){
        player.score.hitMaliciousMole()
    }
    
    public func moleHitRegular(){
        player.score.hitRegularMole()
    }
    
    public func moleHitSpecial(moleType: MoleType){
        switch moleType {
        case MoleType.SPECIAL_TIME:
            // TODO: MAKE THIS MORE GENERALIZED AND DECOUPLED.
            
            // timer clock increase
            timeUntilGameEnds += config.numberSecondsAddSpecialTime
            gameMainTimerTick()
            
            // pop random moles accordingly
            for _ in 0 ... config.numberMolesPopSpecialTime {
                let delay = Double(config.timerGameLength) + utils.randomInRange(min: 0.0, max: Double(config.numberSecondsAddSpecialTime))
                setRandomMolePopAndHide(withDelay: delay)
            }
            break;
        default:
            moleHitRegular()
            break;
        }
    }
    
    // CellTimersManager delegate
    
    func timerInvalidated(forCellIndex cellIndex: CellIndex){
        moleHide(forCellIndex: cellIndex)
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
    func molePopped(x: Int, y: Int, moleType: MoleType)
    func moleHid(x: Int, y: Int)
    func scoreChanged(score: Score)
    func ongoingGameModeChanged(newMode: Config.GameOngoingMode)
}
