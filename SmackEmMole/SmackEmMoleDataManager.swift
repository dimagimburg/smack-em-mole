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
    var highscorePersistablePlayers: [PersistablePlayer]?
    
    init(){
        print("data manager init")
        let encodedPlayerFilePath = URL(fileURLWithPath: SmackEmMoleDataManager.applicationLibraryPath.appendingPathComponent(highScoresFileName))

        if let encodedPlayersData = try? Data(contentsOf: encodedPlayerFilePath), let encodedPlayers = NSKeyedUnarchiver.unarchiveObject(with: encodedPlayersData) as? [PersistablePlayer] {
            
            highscorePersistablePlayers = encodedPlayers
            print(encodedPlayers)
        } else {
            highscorePersistablePlayers = []
        }
    }
    
    static var applicationLibraryPath: NSString = {
        if let libraryDirectoryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).last {
            return libraryDirectoryPath as NSString
        }
        
        print("ERROR!! Library directory not found 😱")
        return ""
    }()
    
    func isHighScore(score: Int) -> Bool{
        return false
    }
    
    func getHighScores() -> [Player]? {
        
        return nil
    }
    
    func addHighScore(player: Player){
        
        let persistablePlayer = PersistablePlayer(
            name: player.playerName ,
            score: String(player.score.score),
            lng: String(0.0),
            lat: String(0.0)
        )
        
        print("adding highscore")
        print(persistablePlayer)
        
        highscorePersistablePlayers?.append(persistablePlayer)
    }
    
    func deleteLasHighScore(){
    
    }
    
    func save(){
        let encodedUserFilePath = URL(fileURLWithPath: SmackEmMoleDataManager.applicationLibraryPath.appendingPathComponent(highScoresFileName))
        
        try? NSKeyedArchiver.archivedData(withRootObject: highscorePersistablePlayers ?? []).write(to: encodedUserFilePath)
    }
    
    func clearHighScores(){
    
    }
    
}
