//
//  GameViewController.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 4/3/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import Foundation
import UIKit

class GameViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, SmackEmMoleDelegate{
    
    @IBOutlet weak var gameBoardContainerView: UIView!
    @IBOutlet weak var gameBoardCollectionView: UICollectionView!
    
    
    @IBOutlet weak var timerBeforeGameStartedView: UIView!
    @IBOutlet weak var timerBeforeGameStartedLabel: UILabel!
    
    @IBOutlet weak var timerMainTop: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var optionsPauseMenuView: UIView!
    
    let game: Game = Game()
    var config: Config = Config.sharedInstance
    let tileMargin = CGFloat(4.0)
    var cellWidth: CGFloat?
    var cellHeight: CGFloat?
    var isPaused: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        optionsPauseMenuView?.isHidden = true
        setupGameBoard()
        
        // game config
        game.delegate = self
        game.gameStart()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pauseButtonPressed(_ sender: Any) {
        // TODO: implement game pause
        if(!isPaused){
            optionsPauseMenuView?.isHidden = true
            game.gamePause()
        } else {
            game.gameResume()
        }
        isPaused = !isPaused
        
    }
    
    @IBAction func optionsPauseMenuResumeButtonPressed(_ sender: Any) {
        // TODO: implement game resume
        optionsPauseMenuView?.isHidden = true
        game.gameResume()
    }
    
    
    func setupGameBoard(){
        self.gameBoardCollectionView.delegate = self
        self.gameBoardCollectionView.dataSource = self
        calculateCellParameters()
    }
    
    func calculateCellParameters(){
        let rowsCount = CGFloat(config.numberOfRows)
        self.cellHeight = (gameBoardCollectionView.frame.height / rowsCount) - (((rowsCount + 1) * tileMargin) / rowsCount)
        self.cellWidth = (gameBoardCollectionView.frame.width / CGFloat(config.numberMaxOfColumns)) - (CGFloat(config.numberMaxOfColumns) * tileMargin)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return game.gameBoard[section].count;
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return game.gameBoard.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MoleCollectionViewCell.self), for: indexPath) as! MoleCollectionViewCell
        cell.configCell()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth!, height: cellHeight!)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        game.cellPressed(x: indexPath.row, y: indexPath.section)
    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // UIEdgeInsetsMake (top, left, bottom, right)
        let leftRight = CGFloat((gameBoardCollectionView.frame.width - (CGFloat(game.gameBoard[section].count - 1) * tileMargin) - (cellWidth! * CGFloat(game.gameBoard[section].count))) / 2)
        if(section == 0){
            return UIEdgeInsetsMake(tileMargin, leftRight, tileMargin / 2, leftRight)
        } else if(section == config.numberOfRows - 1){
            return UIEdgeInsetsMake(tileMargin / 2, leftRight, tileMargin, leftRight)
        } else {
            return UIEdgeInsetsMake(tileMargin / 2, leftRight, tileMargin / 2, leftRight)
        }
    }
    
    // SmackEmMole delegation
    
    func gameBeforeTimerStarted(secondsToZero: Int){
        timerBeforeGameStartedLabel.text = String(secondsToZero)
    }
    
    func gameBeforeTimerSecondTick(second: Int){
        timerBeforeGameStartedLabel.text = String(second)
    }
    
    func gameBeforeTimerFinished(){
        timerBeforeGameStartedView.removeFromSuperview()
    }
    
    func gameMainTimerTick(second: Int){
        print("second self: \(second)")
        timerMainTop.text = String(second)
    }
    
    func gameStarted(){
        print("game started")
    }
    
    func gamePaused(){
        print("game paused")
    }
    
    func gameResumed(){
    
    }
    
    func gameStopped(){
        print("game stopped")
    }
    
    func gameFinished(){
        print("game finished")
        timerMainTop.text = "Game Finished"
    }
    
    func molePopped(x: Int, y: Int, moleType: MoleType){
        let index = IndexPath(row: x, section: y)
        let moleView = gameBoardCollectionView.cellForItem(at: index) as! MoleCollectionViewCell
        switch moleType {
        case MoleType.REGULAR:
            moleView.cellImageView.image = UIImage(named: "mole_regular")
            break;
        case MoleType.MALICIOUS:
            moleView.cellImageView.image = UIImage(named: "mole_malicious")
            break;
        case MoleType.SPECIAL_DOUBLE:
            moleView.cellImageView.image = UIImage(named: "mole_special_double")
            break;
        case MoleType.SPECIAL_QUANTITY:
            moleView.cellImageView.image = UIImage(named: "mole_special_extra")
            break;
        case MoleType.SPECIAL_TIME:
            moleView.cellImageView.image = UIImage(named: "mole_special_time")
            break;
        }
        
    }

    func moleHid(x: Int, y: Int) {
        let index = IndexPath(row: x, section: y)
        let moleView = gameBoardCollectionView.cellForItem(at: index) as! MoleCollectionViewCell
        moleView.cellImageView.image = UIImage(named: "mole_sand")
    }
    
    func scoreChanged(score: Score){
        scoreLabel.text = "Score: \(score.score)"
    }
    
    func ongoingGameModeChanged(newMode: Config.GameOngoingMode) {
    
    }

}
