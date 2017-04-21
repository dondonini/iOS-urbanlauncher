//
//  Mathf.swift
//  UrbanLauncher
//
//  Created by Diane Flores on 2017-04-21.
//  Copyright © 2017 Adrian&Edisson. All rights reserved.
//

import Foundation
import SpriteKit

class Mathf
{
    // Lerp function for Float
    public static func lerpFloat(_ v0: Float,_ v1: Float,_ t: Float) -> Float
    {
        return (1 - t) * v0 + t * v1;
    }
    
    
    // Lerp function for CGVector
    public static func lerpVector(_ v0: CGVector,_ v1: CGVector,_ t: Float) -> CGVector
    {
        return CGVector(
            dx: CGFloat(lerpFloat(Float(v0.dx), Float(v1.dx), t)),
            dy: CGFloat(lerpFloat(Float(v0.dy), Float(v1.dy), t))
        )
    }
    
    // Lerp function for CGPoint
    public static func lerpPoint(_ v0: CGPoint,_ v1: CGPoint,_ t: Float) -> CGPoint
    {
        return CGPoint(
            x: CGFloat(lerpFloat(Float(v0.x), Float(v1.x), t)),
            y: CGFloat(lerpFloat(Float(v0.y), Float(v1.y), t))
        )
    }
    
    // Degree to Rad
    public static func degToRad(_ deg: Float) -> Float
    {
        return (3.14 / 180) * deg
    }
    
    // Clamp function
    public static func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T
    {
        return min(max(value, lower), upper)
    }
    
    // Calculate distance
    public static func distance(_ from: CGFloat, _ to: CGFloat) -> CGFloat
    {
        return abs(to - from)
    }
}
