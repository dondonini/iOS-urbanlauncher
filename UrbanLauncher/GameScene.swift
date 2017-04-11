//
//  GameScene.swift
//  UrbanLauncher
//
//  Created by Tech on 2017-03-20.
//  Copyright © 2017 Adrian&Edisson. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Player parameters
    private var minAngle: Float = 0.0
    private var maxAngle: Float = 90.0
    private var currentAngle: Float = 0.0
    private var angleSpeed: Float = 1.0
    private var angleTime: Float = 0.0
    
    private var jumpForceMultiplier: Float = 500.0
    
    private var minPower: Float = 0.1
    private var maxPower: Float = 1.0
    private var currentPower: Float = 0.0
    private var powerSpeed: Float = 0.0
    private var powerTime: Float = 0.0
    
    // Building parameters
    private var minBuildingWidth: Float = 50.0
    private var maxBuildingWidth: Float = 150.0
    
    private var minBuildingHeight: Float = 75.0
    private var maxBuildingHeight: Float = 300.0
    
    private var timeTakenDuringLerp: Float = 1.0
    private var distanceToMove: Float = 10;
    
    private var previousPosition: CGPoint = CGPoint(x: 0, y: 0)
    
    // Modes
    private enum modes
    {
        case Idle
        case Angle
        case Power
    }
    
    private var currentMode: modes = modes.Idle
    
    // References
    private var player = SKSpriteNode()
    private var building = SKSpriteNode()
    
    private var powerBar = SKSpriteNode()
    private var arrowAnchor = SKSpriteNode()
    
    private var mainCamera = SKCameraNode()
    
    private var mainStoryboard = UIStoryboard()
    private var vc = UIViewController()
    private var gc = UIViewController()
    private var appDelegate = AppDelegate()
    
    //private var testBlock = SKSpriteNode()
    
    // Delta
    private var delta: CFTimeInterval = 0.0
    
    //private var label : SKLabelNode?
    //private var spinnyNode : SKShapeNode?
    
    ////////
    // Start
    ////////
    
    override func didMove(to view: SKView)
    {
        mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        vc = mainStoryboard.instantiateViewController(withIdentifier: "Verdict")
        gc = mainStoryboard.instantiateViewController(withIdentifier: "Game")
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        player = self.childNode(withName: "Player") as! SKSpriteNode;
        
        building = self.childNode(withName: "Spawn") as! SKSpriteNode;

        arrowAnchor = player.childNode(withName: "Arrow") as! SKSpriteNode;
        
        powerBar = arrowAnchor.childNode(withName: "PowerBar") as! SKSpriteNode;
        
        mainCamera = self.childNode(withName: "MainCamera") as! SKCameraNode;
        
        //testBlock = self.childNode(withName: "Test") as! SKSpriteNode;
        
        // Keep this last!
        self.physicsWorld.contactDelegate = self;
        
        /*// Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }*/
    }
    
    /////////////////
    // Input controls
    /////////////////
    
    func touchDown(atPoint pos : CGPoint) {
        
        switch(currentMode)
        {
        case modes.Angle:
            powerTime = -1;
            currentMode = modes.Power
            break;
            
        case modes.Power:
            launchPlayer()
            currentMode = modes.Idle
            break;
            
        default:
            break;
        }
        
        updateVisuals()
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        /*if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }*/
    }
    
    func touchUp(atPoint pos : CGPoint) {
        /*if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            //n.strokeColor = SKColor.red
            //self.addChild(n)
        }*/
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }*/
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    /////////
    // Update
    /////////
    
    // Keep previous time interval
    var lastUpdateTimeInterval: CFTimeInterval = 0
    
    override func update(_ currentTime: CFTimeInterval)
    {
        // Called before each frame is rendered
        delta = currentTime - lastUpdateTimeInterval
        
        followCamera(player.position)
        
        switch(currentMode)
        {
        case modes.Idle:
            break;
        case modes.Angle:
            
            angleTime += Float(delta)
            updateAngle(angleTime)
            
            break;
        case modes.Power:
            
            powerTime += Float(delta)
            updatePower(powerTime)
            
            break;
        }
        
        lastUpdateTimeInterval = currentTime
    }
    
    func followCamera(_ target: CGPoint)
    {
        let move = clamp(value: Float(delta), lower: 0.0, upper: 0.5)
        
        var newPosition: CGPoint = lerpPoint(mainCamera.position, target, Float(move) * 5)
        
        newPosition.y = mainCamera.position.y;
        
        mainCamera.position = newPosition

    }
    
    /////////////
    // Collisions
    /////////////
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        print(String(describing: contact.bodyA.node?.name) + " hit " + String(describing: contact.bodyB.node?.name));
        
        if (contact.bodyA.node?.name == "Player")
        {
            switch (contact.bodyB.node?.name)
            {
            case "Spawn"?:
                groundTouched()
                break;
                
            case "Top"?:
                groundTouched()
                break;
                
            case "EndGameTrigger"?:
                sendToController()
                break;
            default:
                break;
            }
        }
        
    }
    
    /////////
    // Helper
    /////////
    
    // Random Int
    func randomRangeInt(start: Int, to end: Int) -> Int {
        var a = start
        var b = end
        
        // Swap to prevent negative integer crashes
        if a > b {
            swap(&a, &b)
        }
        return Int(arc4random_uniform(UInt32(b - a + 1))) + a
    }
    
    // Random Float
    func randomRangeFloat(start: Float, to end: Float) -> Float {
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
    
    // Lerp function for Float
    func lerpFloat(_ v0: Float,_ v1: Float,_ t: Float) -> Float
    {
        return (1 - t) * v0 + t * v1;
    }
    
    
    // Lerp function for CGVector
    func lerpVector(_ v0: CGVector,_ v1: CGVector,_ t: Float) -> CGVector
    {
        return CGVector(
            dx: CGFloat(lerpFloat(Float(v0.dx), Float(v1.dx), t)),
            dy: CGFloat(lerpFloat(Float(v0.dy), Float(v1.dy), t))
            )
    }
    
    // Lerp function for CGPoint
    func lerpPoint(_ v0: CGPoint,_ v1: CGPoint,_ t: Float) -> CGPoint
    {
        return CGPoint(
            x: CGFloat(lerpFloat(Float(v0.x), Float(v1.x), t)),
            y: CGFloat(lerpFloat(Float(v0.y), Float(v1.y), t))
        )
    }
    
    // Degree to Rad
    func degToRad(_ deg: Float) -> Float
    {
        return (3.14 / 180) * deg
    }
    
    // Clamp function
    func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
        return min(max(value, lower), upper)
    }

    /////////////////
    // Mode functions
    /////////////////
    
    // Update angle visual
    func updateAngle(_ t: Float)
    {
        let p: Float = sin(Float(t) * angleSpeed) / 2.0 + 0.5
        
        currentAngle = degToRad(lerpFloat(minAngle, maxAngle, p))
        
        arrowAnchor.zRotation = CGFloat(currentAngle) - CGFloat(degToRad(90))
    }
    
    // Update power visual
    func updatePower(_ t: Float)
    {
        let p: Float = sin(Float(t) * angleSpeed) / 2.0 + 0.5
        
        currentPower = lerpFloat(minPower, maxPower, p)
        
        powerBar.size = CGSize(width: powerBar.size.width, height: CGFloat((currentPower / maxPower) * Float(player.size.height)))
    }
    
    // Launch player into air
    func launchPlayer()
    {
        // Enable physics on player
        //player.physicsBody?.isDynamic = true
        
        // Applies impulse to player
        player.physicsBody?.applyImpulse(
        CGVector(
            dx: CGFloat(jumpForceMultiplier * currentPower * cos(currentAngle)),
            dy: CGFloat(jumpForceMultiplier * currentPower * sin(currentAngle)))
        )
    }

    func groundTouched()
    {
        // Disable physics on player
        //player.physicsBody?.isDynamic = false
        
        // Set angle time to beginning
        angleTime = -1.5
        
        // Set mode
        currentMode = modes.Angle
        
        // Update visuals
        updateVisuals()
    }
    
    // Update all player visuals
    func updateVisuals()
    {
        switch(currentMode)
        {
        case modes.Angle:   // Show arrow only
            powerBar.isHidden = true
            arrowAnchor.isHidden = false
            break;
        case modes.Power:   // Show both arrow and bar
            powerBar.isHidden = false
            arrowAnchor.isHidden = false
            break;
        case modes.Idle:    // Hide both arrow and bar
            powerBar.isHidden = true
            arrowAnchor.isHidden = true
            break;
        }
    }
    
    ///////////////
    // "Transition"
    ///////////////
    
    func sendToController()
    {
        appDelegate.window?.rootViewController? = vc
        //appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
    }
}
