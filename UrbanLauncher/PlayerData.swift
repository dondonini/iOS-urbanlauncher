//
//  PlayerData.swift
//  UrbanLauncher
//
//  Created by Tech on 2017-04-17.
//  Copyright © 2017 Adrian&Edisson. All rights reserved.
//

import Foundation



class PlayerData
{
    // singlton
    static let sharedInstance = PlayerData()
    
    private var score: Int = 0
    private var highScore: Int = 0
    
    private init(){}
    
    public func getScore() -> Int
    {
        return score
    }
    
    public func setScore(_ newScore: Int)
    {
        score = newScore
        
        if (newScore > highScore)
        {
            highScore = score
        }
    }
    
    public func addToScore(_ newScore: Int)
    {
        setScore(score + newScore)
    }
    
    public func getHighScore() -> Int
    {
        return highScore
    }
    
}
