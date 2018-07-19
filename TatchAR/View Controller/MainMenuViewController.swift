//
//  MainMenuViewController.swift
//  TatchAR
//
//  Created by Gabriel Wong on 7/19/18.
//  Copyright © 2018 Onerous. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var difficultySelectView: UIView!
    @IBOutlet weak var playButtonOutlet: UIButton!
    @IBOutlet weak var settingsButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func buttonEvent(_ sender: UIButton) {
        switch sender.tag {
        case 0: play()
        case 1: displaySettings()
        default: fatalError("Main menu button TAG not recognized!")
        }
    }
    
    func play() {
        
    }
    
    func displaySettings() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
