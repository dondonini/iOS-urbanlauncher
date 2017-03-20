//
//  MainMenu.swift
//  iOS-UrbanLauncher
//
//  Created by Tech on 2017-03-20.
//  Copyright © 2017 Adrian&Edisson. All rights reserved.
//

import SpriteKit
import GameplayKit

class CreditsScene: SKScene {
    
    override init(size: CGSize){
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func sceneDidLoad() {
        
        
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
    
    
    
}

