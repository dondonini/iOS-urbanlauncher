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
    private var minAngle: Float32 = 0.0
    private var maxAngle: Float32 = 90.0
    private var currentAngle: Float32 = 0.0
    private var angleSpeed: Float32 = 1.0
    
    private var jumpForceMultiplier: Float32 = 10.0
    
    private var minPower: Float32 = 0.0
    private var maxPower: Float32 = 1.0
    private var currentPower: Float32 = 0.0
    private var powerSpeed: Float32 = 0.0
    
    // Building parameters
    private var minBuildingWidth: Float32 = 50.0
    private var maxBuildingWidth: Float32 = 150.0
    
    private var minBuildingHeight: Float32 = 75.0
    private var maxBuildingHeight: Float32 = 300.0
    
    private var dothing: Float32 = 0.0
    
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
    
    
    // Delta
    private var delta: CFTimeInterval = 0.0
    
    //private var label : SKLabelNode?
    //private var spinnyNode : SKShapeNode?
    
    ////////
    // Start
    ////////
    
    override func didMove(to view: SKView)
    {
        player = self.childNode(withName: "Player") as! SKSpriteNode;
        
        building = self.childNode(withName: "Spawn") as! SKSpriteNode;

        powerBar = player.childNode(withName: "PowerBar") as! SKSpriteNode;

        arrowAnchor = player.childNode(withName: "Arrow") as! SKSpriteNode;

        dothing = 1
        
        
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
        /*if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }*/
        changeMode()
        
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
    
    var lastUpdateTimeInterval: CFTimeInterval = 0
    
    override func update(_ currentTime: CFTimeInterval)
    {
        // Called before each frame is rendered
        delta = currentTime - lastUpdateTimeInterval
        
        
        
        switch(currentMode)
        {
        case modes.Idle:
            break;
        case modes.Angle:
            
            let p: Float32 = sin(Float(currentTime) * angleSpeed) / 2 + 0.5
            
            currentAngle = (3.14 / 180) * lerp(minAngle, maxAngle, p)
            
            arrowAnchor.zRotation = CGFloat(currentAngle) * -1
            
            print(currentAngle)
            
            break;
        case modes.Power:
            break;
        }
        
        
        
        lastUpdateTimeInterval = currentTime
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
                currentAngle = minAngle
                currentMode = modes.Angle
                break;
            default:
                break;
            }
        }
        
    }
    
    /////////
    // Helper
    /////////
    
    func randomIntFrom(start: Int, to end: Int) -> Int {
        var a = start
        var b = end
        
        // Swap to prevent negative integer crashes
        if a > b {
            swap(&a, &b)
        }
        return Int(arc4random_uniform(UInt32(b - a + 1))) + a
    }
    
    func lerp(_ v0: Float,_ v1: Float,_ t: Float) -> Float
    {
        return (1 - t) * v0 + t * v1;
    }
    
    /////////////////
    // Mode functions
    /////////////////
    
    func changeMode()
    {
        switch(currentMode)
        {
        case modes.Idle:
            currentMode = modes.Angle;
            break;
        case modes.Angle:
            currentMode = modes.Power;
            break;
        case modes.Power:
            currentMode = modes.Idle;
            break;
        }
    }
}
