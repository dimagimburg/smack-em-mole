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
            animateOptionsMenuOpen()
            game.gamePause()
            isPaused = true
        }
    }
    
    @IBAction func optionsPauseMenuResumeButtonPressed(_ sender: Any) {
        // TODO: implement game resume
        isPaused = false
        animateOptionsMenuClose()
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
    
    // Animations
    
    func animateOptionsMenuOpen(){
        
        UIView.transition(
            with: optionsPauseMenuView,
            duration: 0.25,
            options: [.transitionCrossDissolve],
            animations: {
                self.optionsPauseMenuView?.isHidden = false
            },
            completion: { _ in
        
            }
        )
        
    }
    
    func animateOptionsMenuClose(){
        
        UIView.transition(
            with: optionsPauseMenuView,
            duration: 0.25,
            options: [.transitionCrossDissolve],
            animations: {
                self.optionsPauseMenuView?.isHidden = true
            },
            completion: { _ in
            
            }
        )
        
    }
    
    func animateCounterLabelToBeforeStartTimerView(withText text: String){
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        label.textAlignment = .center
        label.alpha = 0
        label.font = UIFont(name: "ShowcardGothic-Reg", size: 50)
        label.text = text
        label.center = CGPoint(x: timerBeforeGameStartedView.frame.width / 2, y: timerBeforeGameStartedView.frame.height / 2)
        timerBeforeGameStartedView.addSubview(label)
        label.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        UIView.animate(
            withDuration: 0.25,
            animations: {
                label.transform = CGAffineTransform(scaleX: 1, y: 1)
                label.alpha = 1
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.75,
                    animations: {
                        label.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                        label.alpha = 0.2
                    },
                    completion: { _ in
                        label.removeFromSuperview()
                    }
                )
            }
        )
    }

    
    // SmackEmMole delegation
    
    func gameBeforeTimerStarted(secondsToZero: Int){
        
    }
    
    func gameBeforeTimerSecondTick(second: Int){
        print("that")
        //timerBeforeGameStartedLabel.text = String(second)
        animateCounterLabelToBeforeStartTimerView(withText: String(second))
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
