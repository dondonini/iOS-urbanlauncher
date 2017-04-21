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
    
    // Instances
    private var playerData: PlayerData = PlayerData.sharedInstance
    
    // Scoring
    private var coinWorth: Int = 20
    private var coinMaxHeight: Float = 200.0
    
    private var distanceWorth: Int = 10
    private var distanceWidth: Float = 50.0
    
    // Player parameters
    private var minAngle: Float = 0.0
    
    // We changed this from 90 to 100 because the player would sometimes get stuck on a building and couldn't progress
    // So, we forced them to back-track
    private var maxAngle: Float = 100.0
    private var currentAngle: Float = 0.0
    private var angleSpeed: Float = 1.5
    private var angleTime: Float = 0.0
    
    private var jumpForceMultiplier: Float = 500.0
    
    private var minPower: Float = 0.1
    private var maxPower: Float = 1.0
    private var currentPower: Float = 0.0
    private var powerSpeed: Float = 0.0
    private var powerTime: Float = 0.0
    
    // Building parameters
    private var minBuildingGapWidth: Float = 0.0
    private var maxBuildingGapWidth: Float = 100.0
    
    // Camera perameters
    private var cameraXOffset: Float = 250.0
    
    // Modes
    private enum modes
    {
        case Idle
        case Angle
        case Power
    }
    
    private var currentMode: modes = modes.Idle
    
    /////////////
    // References
    /////////////
    
    // ??
    private var appDelegate = AppDelegate()
    
    // Player
    private var player = SKSpriteNode()
    private var powerBar = SKSpriteNode()
    private var arrowAnchor = SKSpriteNode()
    
    // Map
    private var building = SKSpriteNode()

    // UI
    private var scoreText = SKLabelNode()
    private var highScoreText = SKLabelNode()
    private var distanceScoreText = SKLabelNode()
    private var mainStoryboard = UIStoryboard()
    private var vc = UIViewController()
    private var gc = UIViewController()
    
    // Camera
    private var mainCamera = SKCameraNode()
    private var cameraBR = SKNode()
    
    // Coin
    private var coin = SKSpriteNode()
    
    // Available buildings to spawn
    private var availableBuildings = [SKNode]()
    
    // Scoring offset
    private var scoreOffsetPos = SKNode()
    
    ////////////////////
    // Runtime Variables
    ////////////////////
    
    private var previousBuildingPosition = CGPoint()
    
    private var previousLandingX: CGFloat = 0
    private var distanceFromLastLanding: Float = 0
    
    // Delta time
    private var delta: CFTimeInterval = 0.0
    
    /////////////////
    // Start Function
    /////////////////
    
    override func didMove(to view: SKView)
    {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Player
        player = self.childNode(withName: "Player") as! SKSpriteNode
        arrowAnchor = player.childNode(withName: "Arrow") as! SKSpriteNode
        powerBar = arrowAnchor.childNode(withName: "PowerBar") as! SKSpriteNode
        
        // Map
        building = self.childNode(withName: "Spawn") as! SKSpriteNode

        // Camera
        mainCamera = self.childNode(withName: "MainCamera") as! SKCameraNode
        cameraBR = mainCamera.childNode(withName: "BR")!
        
        // Scoring offset
        scoreOffsetPos = self.childNode(withName: "ScoreOffset")!
        
        // UI
        mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        vc = mainStoryboard.instantiateViewController(withIdentifier: "Verdict")
        gc = mainStoryboard.instantiateViewController(withIdentifier: "Game")
        scoreText = mainCamera.childNode(withName: "ScoreText") as! SKLabelNode
        highScoreText = mainCamera.childNode(withName: "HighScoreText") as! SKLabelNode
        distanceScoreText = scoreText.childNode(withName: "DistanceScoreText") as! SKLabelNode
        
        previousBuildingPosition = scoreOffsetPos.position
        
        // Adding buildings
        availableBuildings.append(self.childNode(withName: "Building1")!)
        availableBuildings.append(self.childNode(withName: "Building2")!)
        availableBuildings.append(self.childNode(withName: "Building3")!)
        
        // Coin
        coin = self.childNode(withName: "Coin") as! SKSpriteNode
        
        // Reset score
        playerData.setScore(0)
        
        // Reset previous position X
        previousLandingX = player.position.x
        
        // Keep this last!
        self.physicsWorld.contactDelegate = self;
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    /////////
    // Update
    /////////
    
    // Keep previous time interval
    var lastUpdateTimeInterval: CFTimeInterval = 0
    
    // Main Update
    override func update(_ currentTime: CFTimeInterval)
    {
        // Called before each frame is rendered
        delta = Mathf.clamp(value: currentTime - lastUpdateTimeInterval, lower: 0.0, upper: 1.0)
        
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
        
        // Building spawning
        if (previousBuildingPosition.x < cameraBR.position.x + mainCamera.position.x)
        {
            spawnNewBuilding()
        }
        
        // Calculate real-time distance from previous spot
        let realDistance: Float = Float(Mathf.distance(previousLandingX, player.position.x))
        
        let realScore: Int = Int(roundf(realDistance / distanceWidth)) * distanceWorth
        
        // Update UI
        updateScore(playerData.getScore())
        updateHighScore(playerData.getHighScore())
        updateDistanceScoreText(realScore)
        
        // KEEP LAST!
        lastUpdateTimeInterval = currentTime
    }
    
    // Updates camera position relative to target
    func followCamera(_ target: CGPoint)
    {
        let move = delta
        
        var goalPosition: CGPoint = target
        
        goalPosition.x = goalPosition.x + CGFloat(cameraXOffset)
        
        var newPosition: CGPoint = Mathf.lerpPoint(
            mainCamera.position
            , goalPosition
            , Float(move) * 5
        )
        
        newPosition.y = mainCamera.position.y;
        
        mainCamera.position = newPosition

    }
    
    // Updates score UI
    func updateScore(_ newScore: Int)
    {
        scoreText.text = String.init(format: "Score: %i", newScore)
    }
    
    // Updates high score UI
    func updateHighScore(_ newScore: Int)
    {
        highScoreText.text = String.init(format: "High Score: %i", newScore)
    }
    
    func updateDistanceScoreText(_ newScore: Int)
    {
        if (newScore == 0)
        {
            distanceScoreText.isHidden = true
        }
        else
        {
            distanceScoreText.isHidden = false
            
            distanceScoreText.text = String.init(format: "+%i", newScore)
        }
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
                
            case "BuildingTop"?:
                groundTouched()
                break;
                
            case "Coin"?:
                coinCollected(contact.bodyB.node as! SKSpriteNode)
                break;
                
            case "EndGameTrigger"?:
                sendToController()
                break;
                
            default:
                break;
            }
        }
    }
    
    /////////////////
    // Map Generation
    /////////////////
    
    func spawnNewBuilding()
    {
        // Randomly picked index
        let randPick = Random.RangeInt(start: 0, to: availableBuildings.count - 1)
        
        // Copied selected building
        let selectedBuilding = availableBuildings[randPick].copy() as! SKNode
        
        // Added to world
        self.addChild(selectedBuilding)
        
        let newPosition: CGPoint = fetchRandomBuildingPosition(selectedBuilding)
        
        selectedBuilding.position = newPosition
        
        if (Random.Bool())
        {
            spawnCoinOverPosition(newPosition)
        }
    }
    
    
    // private float whereToSpawnBuilding;
    func fetchRandomBuildingPosition(_ selectedBuilding: SKNode) -> CGPoint
    {
        // Spawnbuilding at wheretospawnbuilding
        // Subtract the width / 2 to wherespawnbuilding
        
        // Get building size
        let buildingBody = selectedBuilding.childNode(withName: "Body") as! SKSpriteNode
        let buildingSize: CGSize = buildingBody.size
        
        buildingBody.zPosition = -1
        
        // Calculate X
        var randGapX = previousBuildingPosition.x
        randGapX += CGFloat(Random.RangeFloat(start: minBuildingGapWidth, to: maxBuildingGapWidth))
        randGapX += buildingSize.width / 2
        
        // Calculate Y
        var randGapY = previousBuildingPosition.y
        randGapY += CGFloat(Mathf.lerpFloat(0, Float(buildingSize.height / 2), Random.RangeFloat(start: 0.0, to: 1.0)))
        
        previousBuildingPosition = CGPoint(x: randGapX + buildingSize.width / 2, y: previousBuildingPosition.y)
        
        return CGPoint(x: randGapX, y: randGapY)
    }

    /////////////////
    // Mode functions
    /////////////////
    
    // Update angle visual
    func updateAngle(_ t: Float)
    {
        let p: Float = sin(Float(t) * angleSpeed) / 2.0 + 0.5
        
        currentAngle = Mathf.degToRad(Mathf.lerpFloat(minAngle, maxAngle, p))
        
        arrowAnchor.zRotation = CGFloat(currentAngle) - CGFloat(Mathf.degToRad(90))
    }
    
    // Update power visual
    func updatePower(_ t: Float)
    {
        let p: Float = sin(Float(t) * angleSpeed) / 2.0 + 0.5
        
        currentPower = Mathf.lerpFloat(minPower, maxPower, p)
        
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
        
        // Calculate distance from previous jump
        distanceFromLastLanding = Float(Mathf.distance(previousLandingX, player.position.x))
        
        distancePoints(distanceFromLastLanding)
        
        // Save land position (X axis only)
        previousLandingX = player.position.x
        
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
    
    // Coin Collected action
    func coinCollected(_ c: SKSpriteNode)
    {
        playerData.addToScore(coinWorth)
        
        c.removeFromParent()
    }
    
    func spawnCoinOverPosition(_ pos: CGPoint)
    {
        let coinYOffset: Float = 50.0
        
        let newCoin: SKSpriteNode = coin.copy() as! SKSpriteNode
        
        self.addChild(newCoin)
        
        newCoin.position = CGPoint(x: pos.x, y: CGFloat(Random.RangeFloat(start: Float(pos.y) + coinYOffset, to: Float(pos.y) + coinMaxHeight + coinYOffset)))
    }
    
    func distancePoints(_ distance: Float)
    {
        if (distance / distanceWidth > 1.0)
        {
            var newScore: Int = 0
            
            newScore = Int(roundf(distance / distanceWidth)) * distanceWorth
            
            playerData.addToScore(newScore)
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
