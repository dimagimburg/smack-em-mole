//
//  Game.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 4/8/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import Foundation

class Game {
    
    var gameBoard: Array<Array<Cell>>!
    var config: Config = Config.sharedInstance
    
    init(){
        gameBoard = gameGenerateGameBoard()
    }
    
    private func gameGenerateGameBoard() -> Array<Array<Cell>>{
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
    
    public func gameBeforeTimer(){
    
    }
    
    public func gameBeforeTimerRelease(){
    
    }
    
    public func gameStart(){
    
    }
    
    public func gamePause(){
    
    }
    
    public func gameStop(){
    
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
