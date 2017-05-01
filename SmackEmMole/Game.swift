//
//  Game.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 4/8/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import Foundation

class Game: GameTimersManagerDelegate {
    
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
    var gameTimersManager = GameTimersManager()
    var gameIsOn: Bool = false
    
    var dateGameBegins: Date?
    var timeUntilGameEnds: Int
    
    var timerBeforeGameStarted: Timer?
    var timeBeforeGameBegins: Int
    var timerMainUniqueKey = "timer_game_main"
    // TODO: make timer_before_game work with the timers manager
    var timerBeforeGameUniqueKey = "timer_before_game"
    
    var popTimes: [Double]!
    
    // counts the number of times the special time mole hit in order to know when to add more mole pops when time is added
    var specialTimeMoleHit: Int = 0
    
    init(){
        timeBeforeGameBegins = config.timerBeforeGameStartSeconds
        timeUntilGameEnds = config.timerGameLength
        gameBoard = gameGenerateGameBoard()
        popTimes = generateMolePopsTimes()
        
        // delegation
        gameTimersManager.delegate = self
    }
    
    fileprivate func gameGenerateGameBoard() -> Array<Array<Cell>>{
        // this function generates a 2d array for representing the game board
        
        var gameBoardCellsGenerated: Array<Array<Cell>> = []
        for row in 0..<config.numberOfRows {
            let numberOfColumns: Int = utils.randomInRange(min: config.numberMinOfColumns, max: config.numberMaxOfColumns)
            var cells: Array<Cell> = []
            for column in 0 ..< numberOfColumns {
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
        gameTimersManager.addListedCellTimer(withDelay: delay, withCallback: {
            let cell = self.getRandomCell()
            self.delegate?.molePopped(x: cell.cellIndex.x, y: cell.cellIndex.y, moleType: (cell.mole?.type)!)
            let timeMoleToBeShown = self.utils.randomInRange(min: self.config.timeMinimumMoleShow, max: self.config.timeMaximumMoleShow)
            
            return (cell.cellIndex, timeMoleToBeShown, { [weak self] in
                cell.setMole(moleType: nil)
                self?.freeCells.append(cell)
                self?.moleHide(cell: cell)
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
        let beginGameDelay = 0.5
        dateGameBegins = Date().addingTimeInterval(beginGameDelay)
        gameTimersManager.setAnchorDate(withDate: dateGameBegins!)
        timeUntilGameEnds = config.timerGameLength
        gameIsOn = true
        
        gameTimersManager.addRegularTimer(forKey: timerMainUniqueKey, withDelay: beginGameDelay, loops: timeUntilGameEnds, withInterval: 1.0, forEachIntervalDo: { [weak self] (secondsLeft) in
            self?.delegate?.gameMainTimerTick(second: secondsLeft)
            self?.timeUntilGameEnds = secondsLeft
        }, withCallback: { [weak self] in
            self?.gameMainTimerFinished()
        })
        
        addMolePopTimers()
        delegate?.gameStarted()
    }
    
    fileprivate func gameMainTimerFinished(){
        gameStop()
        gameFinished()
    }
    
    fileprivate func gameFinished(){
        gameTimersManager.releaseAllListedCellTimers() // when main timer finished clear all moles popped
        gameIsOn = false
        delegate?.gameFinished()
    }
    
    public func gameStart(){
        gameBeforeTimerStart()
    }
    
    public func gamePause(){
    
    }
    
    public func gameStop(){
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
        cellPressed.mole = nil
        
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
            
            // release to all timers running right now, sort of board clearance as a penalty for hitting malicious mole
            gameTimersManager.releaseAllListedCellTimers()
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
            // timer clock increase
            gameTimersManager.addLoops(forTimerKey: timerMainUniqueKey, loopsAmount: config.numberSecondsAddSpecialTime)
            
            // pop random moles accordingly
            for _ in 0 ... config.numberMolesPopSpecialTime {
                let delay =
                    Double(config.timerGameLength) + // end of game time
                    Double(specialTimeMoleHit * config.numberSecondsAddSpecialTime) + // time special hit
                    utils.randomInRange(min: 0.0, max: Double(config.numberSecondsAddSpecialTime)) // random range
                
                setRandomMolePopAndHide(withDelay: delay)
            }
            
            specialTimeMoleHit += 1
            break;
        case MoleType.SPECIAL_DOUBLE:
            player.score.setDoubleMode(isDoubleMode: true)
            delegate?.ongoingGameModeChanged(newMode: Config.GameOngoingMode.SPECIAL_DOUBLE)
            gameTimersManager.addRegularTimer(widthDelay: config.timeDoubleMode, withCallback: { [weak self] in
                self?.delegate?.ongoingGameModeChanged(newMode: Config.GameOngoingMode.REGULAR)
                self?.player.score.setDoubleMode(isDoubleMode: false)
            })
            break;
        default:
            moleHitRegular()
            break;
        }
    }
    
    // CellTimersManager delegate
    
    func listedCellTimerInvalidated(forCellIndex cellIndex: CellIndex){
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
