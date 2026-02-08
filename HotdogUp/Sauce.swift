//
//  Sauce.swift
//  HotdogUp
//
//  Created by Cathy Oun on 8/23/17.
//  Copyright © 2017 Cathy Oun. All rights reserved.
//

import UIKit
import SpriteKit

class Sauce: SKSpriteNode {
    init(type: StationType) {
        let sauceTexture = SKTexture(imageNamed: "\(type.name)_short")
        super.init(texture: sauceTexture, color: .clear, size: sauceTexture.size())

        self.physicsBody = SKPhysicsBody(texture: sauceTexture, size: self.size)
        self.physicsBody?.mass = 0.2
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.isDynamic = true
        self.physicsBody?.contactTestBitMask = ContactCategory.hotdog.rawValue
        self.physicsBody?.categoryBitMask = ContactCategory.sauce.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
