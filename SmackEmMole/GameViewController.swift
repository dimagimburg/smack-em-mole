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
    
    var game: Game? = Game()
    let utils = Utils()
    var config: Config = Config.sharedInstance
    let tileMargin = CGFloat(4.0)
    var cellWidth: CGFloat?
    var cellHeight: CGFloat?
    var isPaused: Bool = false
    
    deinit{
        print("game view controller dismissed")
    }
    
    override func viewDidLoad() {
        print("view di load")
        super.viewDidLoad()
        
        setupGameBoard()
        
        // game config
        game!.delegate = self
        game!.gameStart()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("vid did appear")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear")
        if let game = game {
            if(game.gameIsFinished){
                self.game = nil
                print("game is finished dismissing")
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("view will disappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("view did disappear")
        //dismiss(animated: false, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameFinishedSegue" {
            let vc = segue.destination as! EndGameViewController
            vc.player = game?.player
        }
    }
    
    @IBAction func pauseButtonPressed(_ sender: Any) {
        // TODO: implement game pause
        if(!isPaused){
            animateOptionsMenuOpen()
            game!.gamePause()
            isPaused = true
        }
    }
    
    
    @IBAction func quitButtonPressed(_ sender: Any) {
        print("quit button pressed")
        game = nil
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func optionsPauseMenuResumeButtonPressed(_ sender: Any) {
        // TODO: implement game resume
        isPaused = false
        animateOptionsMenuClose()
        game!.gameResume()
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
        return game!.gameBoard[section].count;
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return game!.gameBoard.count;
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
        game!.cellPressed(x: indexPath.row, y: indexPath.section)
    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // UIEdgeInsetsMake (top, left, bottom, right)
        
        let a = (CGFloat((game?.gameBoard[section].count)! - 1) * tileMargin)
        let b = (cellWidth! * CGFloat((game?.gameBoard[section].count)!))
        
        let leftRight = CGFloat((gameBoardCollectionView.frame.width - a - b) / 2)
        
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
            completion: nil
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
                    withDuration: 0.70,
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
    
    func animateStartGameLabel(){
        // here set animation for a GO! label appears when game starts
    }
    
    func animateMoleHit(x: Int, y: Int, moleType: MoleType?){
        if let moleType = moleType {
            
            let index = IndexPath(row: x, section: y)
            let moleView = gameBoardCollectionView.cellForItem(at: index) as! MoleCollectionViewCell
            let moleHitImageView = UIImageView()
            
            switch moleType {
            case MoleType.REGULAR:
                moleHitImageView.image = UIImage(named: "mole_regular")
                break;
            case MoleType.MALICIOUS:
                moleHitImageView.image = UIImage(named: "mole_malicious")
                break;
            case MoleType.SPECIAL_DOUBLE:
                moleHitImageView.image = UIImage(named: "mole_special_double")
                break;
            case MoleType.SPECIAL_QUANTITY:
                moleHitImageView.image = UIImage(named: "mole_special_extra")
                break;
            case MoleType.SPECIAL_TIME:
                moleHitImageView.image = UIImage(named: "mole_special_time")
                break;
            }
            
            moleHitImageView.frame = CGRect(
                x: moleView.frame.origin.x,
                y: moleView.frame.origin.y,
                width: moleView.frame.width,
                height: 45
            )
            
            gameBoardContainerView.addSubview(moleHitImageView)
            
            let randomAngle = utils.randomInRange(min: 90.0, max: 360.0) * (Double.pi / 180.0) * (utils.randomInRange(min: 0.0, max: 1.0) > 0.5 ? 1 : -1)
        
            UIView.animateKeyframes(
                withDuration: 0.3,
                delay: 0,
                options: [
                    .calculationModeCubic
                ],
                animations: {
                    moleHitImageView.alpha = 0.1
                    moleHitImageView.transform = CGAffineTransform(
                        translationX: CGFloat(self.utils.randomInRange(min: 0.0, max: Double(self.gameBoardContainerView.frame.width))),
                        y: CGFloat(self.utils.randomInRange(min: 0.0, max: Double(self.gameBoardContainerView.frame.width)))
                        ).concatenating(CGAffineTransform(rotationAngle: CGFloat(randomAngle))).concatenating(CGAffineTransform(scaleX: 0.3, y: 0.3))
                },
                completion: { _ in
                    moleHitImageView.removeFromSuperview()
                }
            )
        }
    }

    
    // SmackEmMole delegation
    
    func gameBeforeTimerStarted(secondsToZero: Int){
        
    }
    
    func gameBeforeTimerSecondTick(second: Int){
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
        animateStartGameLabel()
    }
    
    func gamePaused(){
        print("game paused")
    }
    
    func gameResumed(){
        print("game resumed")
    }
    
    func gameStopped(){
        print("game stopped")
    }
    
    func gameFinished(){
        print("game finished")
        timerMainTop.text = "Game Finished"
        performSegue(withIdentifier: "gameFinishedSegue", sender: nil)
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

    func moleHid(x: Int, y: Int, isHit: Bool, moleType: MoleType?) {
        let index = IndexPath(row: x, section: y)
        
        if(isHit){
            animateMoleHit(x: x, y: y, moleType: moleType)
        }
        
        let moleView = gameBoardCollectionView.cellForItem(at: index) as! MoleCollectionViewCell
        moleView.cellImageView.image = UIImage(named: "mole_sand")
    }
    
    func scoreChanged(score: Score){
        scoreLabel.text = "Score: \(score.score)"
    }
    
    func ongoingGameModeChanged(newMode: Config.GameOngoingMode) {
    
    }

}
