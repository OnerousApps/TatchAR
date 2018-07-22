//
//  Scene.swift
//  Tatch Shooter AR
//
//  Created by Gabriel Wong on 7/16/18.
//  Copyright © 2018 Onerous. All rights reserved.
//

import SpriteKit
import ARKit
import GameplayKit

class ShooterScene: SKScene, SKPhysicsContactDelegate {
    // MARK: Global Variables
    //Layer Nodes
    private var backgroundNode: SKNode!
    private var enemyNode: SKNode!
    private var bulletNode: SKNode!
    private var foregroundNode: SKNode!
    
    //UI Nodes
    private var shooterLeft: SKSpriteNode!
    private var crosshairs: SKSpriteNode!
    private var shootButton: SKSpriteNode!
    private var arrowLeft: SKSpriteNode!
    private var arrowRight: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    
    //Groups
    private var enemyAnchors: [ARAnchor] = []
    private var bulletAnchors: [ARAnchor] = []
    
    //Alerts & Score
    private var leftArrowOn: Bool = false
    private var rightArrowOn: Bool = false
    private var currentScore: Int!
    
    //Shoot pixel Offset
    private let shootPixelOffset: CGFloat = 20
    
    //Shooting & Enemy Vars
    private var hasShot: Bool = false
    private var enemyRespawnRate: CGFloat = 5 // Seconds
    private let enemyDistanceFromCamera: Float = 5 //In Meters
    private let bulletRemovalDistance: Float = 20 //In Meters
    
    //Respawn Vars
    private let baseRespawnTimer: CGFloat = 300 //Frames
    private let difficultyRespawnTimerModifiers: [CGFloat] = [0, 60, 120, 180, 240] //Subtracted from the base!
    private var enemyRespawnTimer: CGFloat!
    private var spawningCounter: CGFloat!
    
    //Delegate and Pass-though Code
    public static var pendingEnemy: Bool = false
    public static var difficulty: Int!
    
    
    // MARK: Begin of Functions
    override func didMove(to view: SKView) {
        //Point the Layer Node variables to their visible counterparts
        backgroundNode = self.childNode(withName: "Background")
        enemyNode = self.childNode(withName: "Enemy")
        foregroundNode = self.childNode(withName: "Foreground")
        bulletNode = self.childNode(withName: "Bullet")
        
        shooterLeft = foregroundNode?.childNode(withName: "shooterLeft") as? SKSpriteNode
        crosshairs = foregroundNode?.childNode(withName: "crosshairs") as? SKSpriteNode
        shootButton = foregroundNode?.childNode(withName: "shootButton") as? SKSpriteNode
        arrowLeft = foregroundNode?.childNode(withName: "arrowLeft") as? SKSpriteNode
        arrowRight = foregroundNode?.childNode(withName: "arrowRight") as? SKSpriteNode
        
        scoreLabel = foregroundNode?.childNode(withName: "score") as? SKLabelNode
        scoreLabel.fontName = "Courier Bold"
        
        //Initialize Variables and Set Delegates
        arrowLeft?.isHidden = true
        arrowRight?.isHidden = true
        currentScore = 0
        
        //Respawning difficulty-dependant code
        spawningCounter = 0
        enemyRespawnTimer = baseRespawnTimer - difficultyRespawnTimerModifiers[ShooterScene.difficulty]
        
        physicsWorld.contactDelegate = self
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        // // // // // // // // // // // // // // // // // // // // // // // //
        //  MOVE BULLETS & ENEMIES
        // // // // // // // // // // // // // // // // // // // // // // // //
        
        var bulletAnchorIndecesToRemove: [Int] = []
        
        if (bulletAnchors.count > 0) {
            for bulletAnchorIndex in 0..<bulletAnchors.count {
                moveBullet(anchorIndex: bulletAnchorIndex)
                
                if (abs(bulletAnchors[bulletAnchorIndex].transform.columns.3.z) > bulletRemovalDistance) {
                    bulletAnchorIndecesToRemove.append(bulletAnchorIndex)
                    
                    sceneView.session.remove(anchor: bulletAnchors[bulletAnchorIndex])
                }
            }
        }
        
        for i in 0 ..< bulletAnchorIndecesToRemove.count {
            bulletAnchors.remove(at: bulletAnchorIndecesToRemove[i] - i)
        }
        
        
        
        // // // // // // // // // // // // // // // // // // // // // // // //
        //  RESPAWN ENEMIES
        // // // // // // // // // // // // // // // // // // // // // // // //
        
        if (spawningCounter >= enemyRespawnTimer) {
            addEnemy();
            spawningCounter = 0
        }
        
        spawningCounter += 1
        
        
        
        // // // // // // // // // // // // // // // // // // // // // // // //
        //  ALERT CODE & SCORE
        // // // // // // // // // // // // // // // // // // // // // // // //
        
        leftArrowOn = false
        rightArrowOn = false
        
        for enemyAnchor in enemyAnchors {
            let enemyNode = sceneView.node(for: enemyAnchor)
            
            if (enemyNode?.position != nil) {
                let contains: Bool = self.view!.frame.contains(enemyNode!.position)
                
                if (!contains) {
                    leftArrowOn = true
                    rightArrowOn = true
                }
            }
        }
        
        arrowLeft?.isHidden = !leftArrowOn
        arrowRight?.isHidden = !rightArrowOn
        
        
        scoreLabel.text = "Score: \(currentScore!)"
    }
    
    
    
    // MARK: Touch Recognizer Code
    func touchDown(atPoint pos : CGPoint) {
        if (shootButton?.contains(pos))! {
            shootButton?.texture = SKTexture(imageNamed: "buttonPressed")
            shooterLeft?.position.y -= shootPixelOffset
            
            shoot()
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if (hasShot) {
            shootButton?.texture = SKTexture(imageNamed: "button")
            shooterLeft?.position.y += shootPixelOffset
            
            hasShot = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchDown(atPoint: t.location(in: self))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchUp(atPoint: t.location(in: self))
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchUp(atPoint: t.location(in: self))
        }
    }
    
    
    
    // MARK: Enemy and Bullet Spawning and Animations
    func addEnemy() {
        ShooterScene.pendingEnemy = true
        
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {
            
            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -enemyDistanceFromCamera
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
            
            enemyAnchors.append(anchor)
        }
    }
    
    func shoot() {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {
            
            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -3
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
            
            bulletAnchors.append(anchor)
        }
        
        hasShot = true
    }
    
    func moveBullet(anchorIndex: Int) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        // Create anchor using the camera's current position
        if sceneView.session.currentFrame != nil {
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -1
            let transform = simd_mul(bulletAnchors[anchorIndex].transform, translation)
            
            sceneView.session.remove(anchor: bulletAnchors[anchorIndex])
            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
            
            bulletAnchors[anchorIndex] = anchor
        }
    }
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        let nodeA = contact.bodyA.node as! SKSpriteNode
        let nodeB = contact.bodyB.node as! SKSpriteNode
        
        if ((contact.bodyA.categoryBitMask == Enemy.categoryBitMask) && (contact.bodyB.categoryBitMask == Bullet.categoryBitMask)) || (contact.bodyA.categoryBitMask == Bullet.categoryBitMask) && (contact.bodyB.categoryBitMask == Enemy.categoryBitMask) {
            nodeA.removeFromParent()
            nodeB.removeFromParent()
            
            sceneView.session.remove(anchor: sceneView.anchor(for: nodeA)!)
            sceneView.session.remove(anchor: sceneView.anchor(for: nodeB)!)
            
            currentScore += 50
        } else if(contact.bodyA.categoryBitMask == Bullet.categoryBitMask) && (contact.bodyB.categoryBitMask == Bullet.categoryBitMask) {
            nodeB.removeFromParent()
            
            if (sceneView.anchor(for: nodeB) != nil) {
                sceneView.session.remove(anchor: sceneView.anchor(for: nodeB)!)
            }
        }
    }
}
