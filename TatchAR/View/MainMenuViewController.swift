//
//  MainMenuViewController.swift
//  TatchAR
//
//  Created by Gabriel Wong on 7/19/18.
//  Copyright © 2018 Onerous. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController  {
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var playButtonOutlet: UIButton!
    @IBOutlet weak var settingsButtonOutlet: UIButton!
    
    @IBOutlet weak var underlineLabel1: UILabel!
    @IBOutlet weak var underlineLabel2: UILabel!
    @IBOutlet weak var underlineLabel3: UILabel!
    @IBOutlet weak var underlineLabel4: UILabel!
    @IBOutlet weak var underlineLabel5: UILabel!
    
    @IBOutlet weak var difficultyButton1: UIButton!
    @IBOutlet weak var difficultyButton2: UIButton!
    @IBOutlet weak var difficultyButton3: UIButton!
    @IBOutlet weak var difficultyButton4: UIButton!
    @IBOutlet weak var difficultyButton5: UIButton!
    
    private var underlineLabel: [UILabel]!
    private var difficultyButton: [UIButton]!
    
    private let difficulties: [Int] = [1, 2, 3, 4, 5]
    private var selectedButtonIndex: Int!
    
    
    private let backgroundColor: UIColor = UIColor.black
    private let buttonBaseColor: UIColor = UIColor.black
    private let buttonSelectedColor: UIColor = UIColor(white: 0.1, alpha: 1.0)
    private let buttonUnderlineSelectedColor: UIColor = UIColor(white: 0.5, alpha: 1.0)
    private let playButtonColor: UIColor = UIColor(white: 0.1, alpha: 1.0)
    
    private let buttonFadeDuration: TimeInterval = 0.1
    
    private let segueToGameIdentifier = "mainToGame"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        underlineLabel = [underlineLabel1, underlineLabel2, underlineLabel3, underlineLabel4, underlineLabel5]
        difficultyButton = [difficultyButton1, difficultyButton2, difficultyButton3, difficultyButton4, difficultyButton5]
        
        for b in 0..<difficultyButton.count {
            underlineLabel[b].backgroundColor = buttonBaseColor
            difficultyButton[b].backgroundColor = buttonBaseColor
            difficultyButton[b].titleLabel?.font = UIFont(name: "Courier-Bold", size: 32)
        }
        
        selectedButtonIndex = 0
        
        underlineLabel[selectedButtonIndex].backgroundColor = buttonUnderlineSelectedColor
        difficultyButton[selectedButtonIndex].backgroundColor = buttonSelectedColor
        
        
        
        playButtonOutlet.backgroundColor = playButtonColor
        playButtonOutlet.titleLabel?.font = UIFont(name: "Courier-Bold", size: 64)
        playButtonOutlet.setTitleColor(UIColor.white, for: .normal)
        playButtonOutlet.setTitle("PLAY", for: .normal)
        
        settingsButtonOutlet.backgroundColor = backgroundColor
        settingsButtonOutlet.setTitle("", for: .normal)
    }
    
    @IBAction func buttonEvent(_ sender: UIButton) {
        switch sender.tag {
        case 0: play()
        case 1: displaySettings()
        default: fatalError("Main menu button TAG not recognized!")
        }
    }
    
    @IBAction func difficultyButtonEvent(_ sender: UIButton) {
        highlightButton(sender.tag - 1)
    }
    
    func highlightButton(_ index: Int) {
        if (selectedButtonIndex != index) {
            UIView.animate(withDuration: buttonFadeDuration, delay: 0.0, options: [], animations: {
                self.underlineLabel[self.selectedButtonIndex].backgroundColor = self.buttonBaseColor
                self.difficultyButton[self.selectedButtonIndex].backgroundColor = self.buttonBaseColor
            }, completion: nil)
        
            selectedButtonIndex = index
        
            UIView.animate(withDuration: buttonFadeDuration, delay: 0.0, options: [], animations: {
                self.underlineLabel[self.selectedButtonIndex].backgroundColor = self.buttonUnderlineSelectedColor
                self.difficultyButton[self.selectedButtonIndex].backgroundColor = self.buttonSelectedColor
            }, completion: nil)
        }
    }
    
    func play() {
        performSegue(withIdentifier: segueToGameIdentifier, sender: self)
    }
    
    func displaySettings() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == segueToGameIdentifier) {
            let destinationVC = segue.destination as! ShooterViewController
        
            destinationVC.difficulty = selectedButtonIndex + 1
        }
    }
}
