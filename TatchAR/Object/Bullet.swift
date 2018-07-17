//
//  Bullet.swift
//  Tatch Shooter
//
//  Created by Gabriel Wong on 7/16/18.
//  Copyright © 2018 Gabriel Wong. All rights reserved.
//

import Foundation
import SpriteKit

class Bullet: SKSpriteNode {
    static let categoryBitMask: UInt32 = 0x1 << 1
    
    init() {
        let texture = SKTexture(imageNamed: "bullet")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        self.isHidden = false
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width / 2)
        self.physicsBody?.allowsRotation = true
        
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = Bullet.categoryBitMask
        self.physicsBody?.collisionBitMask = Bullet.categoryBitMask | Enemy.categoryBitMask
        self.physicsBody?.contactTestBitMask = Bullet.categoryBitMask | Enemy.categoryBitMask
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
