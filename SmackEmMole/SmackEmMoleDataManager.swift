//
//  DataManager.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 6/15/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//

import Foundation

class SmackEmMoleDataManager{

    let highScoresFileName = "smack_em_mole_hs.dat"
    let maxHighScores = 10
    var highscorePersistablePlayers: [PersistablePlayer]
    
    static var applicationLibraryPath: NSString = {
        if let libraryDirectoryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).last {
            return libraryDirectoryPath as NSString
        }
        
        print("ERROR!! Library directory not found 😱")
        return ""
    }()
    
    init(){
        print("data manager init")
        let encodedPlayerFilePath = URL(fileURLWithPath: SmackEmMoleDataManager.applicationLibraryPath.appendingPathComponent(highScoresFileName))

        if let encodedPlayersData = try? Data(contentsOf: encodedPlayerFilePath), let encodedPlayers = NSKeyedUnarchiver.unarchiveObject(with: encodedPlayersData) as? [PersistablePlayer] {
            
            highscorePersistablePlayers = encodedPlayers
            
            highscorePersistablePlayers = highscorePersistablePlayers.sorted(by: { (p1, p2) -> Bool in
                return Int(p1.score)! > Int(p2.score)!
            })
            
        } else {
            
            highscorePersistablePlayers = ([] as? [PersistablePlayer])!
            
        }
        
        print("table loaded:")
        printReadableHighscores()
    }
    
    func isHighScore(score: Int) -> Bool{
        if (self.highscorePersistablePlayers.count < maxHighScores){
            return true
        }
        
        for persistablePlayer in self.highscorePersistablePlayers {
            if(Int(persistablePlayer.score)! < score){
                return true
            }
        }
        
        return false
    }
    
    func getHighScores() -> [Player]? {
        
        return nil
    }
    
    func addHighScore(player: Player){
        
        print("before setting the highscore:")
        printReadableHighscores()
        
        if highscorePersistablePlayers.count == maxHighScores {
            deleteLastHighScore();
        }
        
        let persistablePlayer = PersistablePlayer(
            name: player.playerName ,
            score: String(player.score.score),
            lng: String(player.lng ?? 0.0),
            lat: String(player.lat ?? 0.0)
        )
        
        print(persistablePlayer)
        
        if highscorePersistablePlayers.count == 0 {
            highscorePersistablePlayers.append(persistablePlayer)
            print("added the first highscore")
        } else {
            for (index, highscorePersistablePlayer) in highscorePersistablePlayers.enumerated() {
                if(Int(persistablePlayer.score)! >= Int(highscorePersistablePlayer.score)!){
                    highscorePersistablePlayers.insert(persistablePlayer, at: index)
                    print("added highscores to position: \(index + 1)")
                    break
                } else if index == highscorePersistablePlayers.count - 1 {
                    highscorePersistablePlayers.append(persistablePlayer)
                    print("added highscores to last position: \(index + 1)")
                }
            }
        }
        
        
        
        save()
        print("after seeting the highscore")
        printReadableHighscores()
        
    }
    
    func deleteLastHighScore(){
        highscorePersistablePlayers.remove(at: highscorePersistablePlayers.count - 1)
    }
    
    func save(){
        print("saving highscores")
        let encodedUserFilePath = URL(fileURLWithPath: SmackEmMoleDataManager.applicationLibraryPath.appendingPathComponent(highScoresFileName))
        
        try? NSKeyedArchiver.archivedData(withRootObject: highscorePersistablePlayers).write(to: encodedUserFilePath)
    }
    
    func clearHighScores(){
        highscorePersistablePlayers = []
        save()
    }
    
    func printReadableHighscores(){
        for (i,p) in highscorePersistablePlayers.enumerated() {
            print("\(i+1). \(p.name) : \(p.score)")
        }
    }
    
}
