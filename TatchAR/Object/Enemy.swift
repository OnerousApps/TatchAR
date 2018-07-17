//
//  Enemy.swift
//  Tatch Shooter
//
//  Created by Gabriel Wong on 7/16/18.
//  Copyright © 2018 Gabriel Wong. All rights reserved.
//

import Foundation
import SpriteKit

class Enemy: SKSpriteNode {
    static let categoryBitMask: UInt32 = 0x1 << 0
    
    init() {
        let texture = SKTexture(imageNamed: "balloon")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        self.isHidden = false

        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width / 2)
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.linearDamping = 0.5
        
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = Enemy.categoryBitMask
        self.physicsBody?.collisionBitMask = Enemy.categoryBitMask | Bullet.categoryBitMask
        self.physicsBody?.contactTestBitMask = Enemy.categoryBitMask | Bullet.categoryBitMask
        self.physicsBody?.affectedByGravity = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
