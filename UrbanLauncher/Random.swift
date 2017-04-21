//
//  Random.swift
//  UrbanLauncher
//
//  Created by Diane Flores on 2017-04-21.
//  Copyright © 2017 Adrian&Edisson. All rights reserved.
//

import Foundation

class Random
{
    // Random Int
    public static func RangeInt(start: Int, to end: Int) -> Int {
        var a = start
        var b = end
        
        // Swap to prevent negative integer crashes
        if a > b {
            swap(&a, &b)
        }
        return Int(arc4random_uniform(UInt32(b - a + 1))) + a
    }
    
    // Random Float
    public static func RangeFloat(start: Float, to end: Float) -> Float {
        let accuracy: Float = 10000.0
        
        var a: Int = Int(start * accuracy)
        var b: Int = Int(end * accuracy)
        
        // Swap to prevent negative integer crashes
        if a > b {
            swap(&a, &b)
        }
        let temp: Float = Float(Int(arc4random_uniform(UInt32(b - a + 1))) + a) / accuracy
        
        return temp
    }
    
    // Random Bool
    public static func Bool() -> Bool
    {
        let percent = RangeFloat(start: 0.0, to: 1.0)
        
        if (percent > 0.5)
        {
            return true
        }
        else
        {
            return false
        }
    }
}
