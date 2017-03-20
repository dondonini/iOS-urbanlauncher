//
//  MainMenu.swift
//  iOS-UrbanLauncher
//
//  Created by Tech on 2017-03-20.
//  Copyright © 2017 Adrian&Edisson. All rights reserved.
//

import SpriteKit
import GameplayKit

class MainMenu: SKScene {
    
    var b_StartGame:SKLabelNode?
    
    override init(size: CGSize){
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    override func sceneDidLoad() {
        
    }
    
    override func didMove(to view: SKView)
    {
        b_StartGame = self.childNode(withName: "b_StartGame") as? SKLabelNode;
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches
        {
            self.touchDown(atPoint: t.location(in: self))

        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        let reveal = SKTransition.flipVertical(withDuration: 1)
        
        print("Bitch");
        
        if (b_StartGame?.contains(pos))!
        {
            
            //We load the scene from the sks file. make sure that the Custom class is set there that poinst to your swift file
            
            if let scene = GKScene(fileNamed: "GameScene") {
                
                // Get the SKScene from the loaded GKScene. Notice that we cast to our swift class MyScene in this case
                if let sceneNode = scene.rootNode as! GameScene? {
                    
                    // Set the scale mode to scale to fit the window
                    sceneNode.scaleMode = .aspectFill
                    
                    // Present the scene
                    if let view = self.view {
                        view.presentScene(sceneNode, transition: reveal);
                        
                        //Optional to show stats
                        view.ignoresSiblingOrder = true
                        
                        view.showsFPS = true
                        view.showsNodeCount = true
                        
                    }
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
    }

    
    
}

