//
//  Station.swift
//  HotdogUp
//
//  Created by Cathy Oun on 8/22/17.
//  Copyright © 2017 Cathy Oun. All rights reserved.
//

import UIKit
import SpriteKit

enum StationType: Int {
    case ketchup = 1  // lowered: appears at level 1 (~10 platforms) for earlier action
    case wasabi = 2
    case water = 3

    var name: String {
        switch self {
        case .ketchup: return "ketchup"
        case .wasabi: return "wasabi"
        case .water: return "water"
        }
    }

    var shootSpeed: TimeInterval {
        switch self {
        case .ketchup: return 4
        case .wasabi: return 3.5
        case .water: return 3
        }
    }
}

class Station: SKSpriteNode {
    
    var tag = 0
    var stationType = StationType.ketchup {
        didSet {
            self.texture = SKTexture(imageNamed: stationType.name)
        }
    }
    var isShooting = false
    var lastShotTime: TimeInterval = 0
    private let shootCooldown: TimeInterval = 1.5
    
    init() {
        let stationTexture = SKTexture(imageNamed: stationType.name)
        super.init(texture: stationTexture, color: .clear, size: stationTexture.size())
        self.physicsBody = SKPhysicsBody(texture: stationTexture, size: self.size)
        self.zPosition = 40
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.isDynamic = false
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.categoryBitMask = ContactCategory.station.rawValue
    }

    
    func animateLeftRight() {
        let moveLeft = SKAction.moveTo(x: -self.size.width/2.0, duration: stationType.shootSpeed)
        let moveRight = SKAction.moveTo(x: 0, duration: stationType.shootSpeed)
        let seq = SKAction.sequence([moveLeft, moveRight])
        self.run(SKAction.repeatForever(seq))
    }
    
    func animateRightLeft() {
        let moveLeft = SKAction.moveTo(x: 0, duration: stationType.shootSpeed)
        let moveRight = SKAction.moveTo(x: -self.size.width/2.0, duration: stationType.shootSpeed)
        let seq = SKAction.sequence([moveLeft, moveRight])
        self.run(SKAction.repeatForever(seq))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func shootSauce() {
        let now = CACurrentMediaTime()
        guard now - lastShotTime >= shootCooldown else { return }
        lastShotTime = now
        isShooting = true
        let sauce = Sauce(type: stationType)
        sauce.ownerStation = self
        // spawn sauce in scene coordinate space so it behaves independently
        sauce.zPosition = 35
        sauce.position = self.convert(CGPoint(x: sauce.size.width/2.0 - 5, y: 0), to: self.scene!)
        sauce.physicsBody?.isDynamic = true
        self.scene?.addChild(sauce)
        let wait = SKAction.wait(forDuration: 1.5)
        let moveAcross = SKAction.moveTo(x: UIScreen.main.bounds.width + sauce.size.width, duration: stationType.shootSpeed)
        let moveDown = SKAction.moveBy(x: 0, y: -UIScreen.main.bounds.height/4.0, duration: stationType.shootSpeed)
        let group = SKAction.group([moveAcross, moveDown])
        let reset = SKAction.run {
            self.isShooting = false
            sauce.removeFromParent()
        }
        sauce.run(SKAction.sequence([wait, group, reset]))
    }
}
