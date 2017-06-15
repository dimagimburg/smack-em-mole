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
    // 2. make order with x and y and use row and column instead or section and row
    // 3. make the random choise of mole type better
    // 4. set the penalty mode also on the delegate so we can catch it in the view controller
    // 5. game state enum (gameIsOn, gameIsFinished)

    // more about delegation https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Protocols.html
    
    weak var delegate: SmackEmMoleDelegate?
    var gameBoard: Array<Array<Cell>>!
    var freeCells: [Cell] = [Cell]()
    var config: Config = Config.sharedInstance
    var utils = Utils()
    var player = Player(withName: "Player (default)")
    var currentOngoingGameMode = Config.GameOngoingMode.REGULAR
    var gameTimersManager = GameTimersManager()
    var gameIsOn: Bool = false
    var gameIsFinished: Bool = false
    var isPenaltyMode = false
    
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
    
    deinit {
        print("game deinit")
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
            addPopTimer(withDelay: popTimes[i])
        }
    }
    
    fileprivate func addPopTimer(withDelay delay: Double){
        gameTimersManager.addPopCellTimer(withKey: utils.randomString(length: 16), withDelay: delay)
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
        
        gameTimersManager.addDelayedIntervalTimer(forKey: timerMainUniqueKey, withDelay: beginGameDelay, loops: timeUntilGameEnds, withInterval: 1.0, forEachIntervalDo: { [weak self] (secondsLeft) in
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
        gameTimersManager.flushAllHideTimers() // when main timer finished clear all moles popped
        gameIsOn = false
        gameIsFinished = true
        
        let dataManager = SmackEmMoleDataManager()
        dataManager.addHighScore(player: player)
        dataManager.save()
        
        delegate?.gameFinished()
    }
    
    public func gameStart(){
        gameBeforeTimerStart()
    }
    
    public func gamePause(){
        print("game is going to be paused")
        // TODO: Pause all task in the game, timers, etc
        gameTimersPause()
        delegate?.gamePaused()
    }
    
    public func gameResume(){
        gameTimersResume()
        delegate?.gameResumed()
    }
    
    public func gameTimersResume(){
        // resume main timer
        gameTimersManager.resumeRegularTimer(forKey: timerMainUniqueKey)
        print("timer main resumed")
        
        // resume moles timers
        gameTimersManager.resumePopAndHideTimers()
    }
    
    public func gameTimersPause(){
        // pause main timer
        gameTimersManager.pauseRegularTimer(forKey: timerMainUniqueKey)
        print("timer main is paused")
        
        // pause mole timers
        gameTimersManager.pausePopAndHideTimers()
        
    }
    
    public func gameStop(){
        delegate?.gameStopped()
    }
    
    public func gameBeginSpecialMode(){
    
    }
    
    public func gameEndSpecialMode(){
    
    }
    
    public func moleHide(cell: Cell, isHit: Bool, moleType: MoleType?){
        delegate?.moleHid(
            x: cell.cellIndex.x,
            y: cell.cellIndex.y,
            isHit: isHit,
            moleType: moleType
        )
        
    }
    
    public func cellPressed(x: Int, y: Int){
        let cellPressed = gameBoard[y][x]
        if(cellPressed.mole != nil){
            moleHit(cellPressed: cellPressed)
        } else {
            cellPressed.mole = nil
            moleHide(cell: cellPressed, isHit: false, moleType: nil)
        }
    }
    
    public func moleHit(cellPressed: Cell){
        // TODO: check if cellPressed.mole = nil even needed....
        
        switch cellPressed.mole!.type {
            
        case MoleType.MALICIOUS:
            if(player.score.score > 0){
                moleHitMalicious()
            }
            
            isPenaltyMode = true
            
            gameTimersManager.addDelayedTimer(widthDelay: config.timePenaltyMode, withCallback: { [weak self] in
                self?.isPenaltyMode = false
            })
            
            // flush all timers running right now, sort of board clearance as a penalty for hitting malicious mole
            gameTimersManager.flushAllHideTimers()
            cellPressed.mole = nil
            moleHide(cell: cellPressed, isHit: true, moleType: MoleType.MALICIOUS)
            break
            
        case MoleType.REGULAR:
            moleHitRegular()
            cellPressed.mole = nil
            moleHide(cell: cellPressed, isHit: true, moleType: MoleType.REGULAR)
            break
            
        default:
            moleHitSpecial(cellPressed: cellPressed)
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
    
    public func moleHitSpecial(cellPressed: Cell){
        switch cellPressed.mole!.type {
            
        case MoleType.SPECIAL_TIME:
            // timer clock increase
            
            gameTimersManager.addLoops(
                forTimerKey: timerMainUniqueKey,
                loopsAmount: config.numberSecondsAddSpecialTime
            )
            
            // pop random moles accordingly
            for _ in 0 ... config.numberMolesPopSpecialTime {
                let delay =
                    Double(config.timerGameLength) + // end of game time
                    Double(specialTimeMoleHit * config.numberSecondsAddSpecialTime) + // time special hit
                    utils.randomInRange(min: 0.0, max: Double(config.numberSecondsAddSpecialTime)) // random range
                
                gameTimersManager.addPopCellTimer(withKey: utils.randomString(length: 16), withDelay: delay)
            }
            
            specialTimeMoleHit += 1
            
            cellPressed.mole = nil
            moleHide(cell: cellPressed, isHit: true, moleType: MoleType.SPECIAL_TIME)
            break
            
        case MoleType.SPECIAL_DOUBLE:
            player.score.setDoubleMode(isDoubleMode: true)
            delegate?.ongoingGameModeChanged(newMode: Config.GameOngoingMode.SPECIAL_DOUBLE)
            
            gameTimersManager.addDelayedTimer(
                widthDelay: config.timeDoubleMode,
                withCallback: { [weak self] in
                    self?.delegate?.ongoingGameModeChanged(newMode: Config.GameOngoingMode.REGULAR)
                    self?.player.score.setDoubleMode(isDoubleMode: false)
                }
            )
            
            cellPressed.mole = nil
            moleHide(cell: cellPressed, isHit: true, moleType: MoleType.SPECIAL_DOUBLE)
            break
            
        case MoleType.SPECIAL_QUANTITY:
            
            let delayStartDate = Date().timeIntervalSince(dateGameBegins!).nextUp + 0.5
            
            for _ in 0 ... config.numberMolesPopSpecialQuantity - 1 {
                
                gameTimersManager.addPopCellTimer(
                    withKey: utils.randomString(length: 16),
                    withDelay: utils.randomInRange(
                        min: delayStartDate,
                        max: delayStartDate + config.timeQuantityMode
                    )
                )
                
            }
            
            cellPressed.mole = nil
            moleHide(cell: cellPressed, isHit: true, moleType: MoleType.SPECIAL_QUANTITY)
            break
            
        default:
            moleHitRegular()
            cellPressed.mole = nil
            moleHide(cell: cellPressed, isHit: true, moleType: MoleType.REGULAR)
            break;
        }
        
    }
    
    // CellTimersManager delegate
    
    func cellPrepare(){
        if(!isPenaltyMode && gameIsOn){
            
            let cell = self.getRandomCell()
            
            let timeMoleToBeShown = self.utils.randomInRange(
                min: self.config.timeMinimumMoleShow,
                max: self.config.timeMaximumMoleShow
            )
            
            gameTimersManager.addHideCellTimer(
                forCell: cell,
                withDelay: timeMoleToBeShown
            )
            
            self.delegate?.molePopped(
                x: cell.cellIndex.x,
                y: cell.cellIndex.y,
                moleType: (cell.mole?.type)!
            )

        }
    }
    
    func cellHid(forCell cell: Cell){
        cell.setMole(moleType: nil)
        self.freeCells.append(cell)
        self.moleHide(cell: cell, isHit: false, moleType: nil)
    }
    
}

protocol SmackEmMoleDelegate: class {
    func gameBeforeTimerStarted(secondsToZero: Int)
    func gameBeforeTimerSecondTick(second: Int)
    func gameBeforeTimerFinished()
    func gameMainTimerTick(second: Int)
    func gameStarted()
    func gamePaused()
    func gameResumed()
    func gameStopped()
    func gameFinished()
    func molePopped(x: Int, y: Int, moleType: MoleType)
    func moleHid(x: Int, y: Int, isHit: Bool, moleType: MoleType?)
    func scoreChanged(score: Score)
    func ongoingGameModeChanged(newMode: Config.GameOngoingMode)
}
