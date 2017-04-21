//
//  VerdictScene.swift
//  UrbanLauncher
//
//  Created by Tech on 2017-03-20.
//  Copyright © 2017 Adrian&Edisson. All rights reserved.
//

import UIKit

class VerdictViewController: UIViewController {
    
    @IBOutlet weak var playerScore: UILabel!
    @IBOutlet weak var highScoreText: UILabel!
    
    var playerData: PlayerData = PlayerData.sharedInstance
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        playerScore.text = String(playerData.getScore())
        highScoreText.text = String(playerData.getHighScore())
        
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    }
}
