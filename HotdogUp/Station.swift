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
    case ketchup = 2 //default level 2
    case wasabi = 3
    case water = 4
    
    var name : String {
        switch self {
        case .ketchup: return "ketchup"
        case .wasabi: return "wasabi"
        case .water: return "water"
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
    
    init(stationType: StationType) {
        let stationTexture = SKTexture(imageNamed: stationType.name)
        super.init(texture: stationTexture, color: .clear, size: stationTexture.size())
        self.stationType = stationType
        self.physicsBody = SKPhysicsBody(texture: stationTexture, size: self.size)
        self.zPosition = 40
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.isDynamic = false
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.categoryBitMask = ContactCategory.station.rawValue
    }

    
    func animateLeftRight(duration: TimeInterval) {
        let moveLeft = SKAction.moveTo(x: -self.size.width/2.0, duration: duration)
        let moveRight = SKAction.moveTo(x: 0, duration: duration)
        let seq = SKAction.sequence([moveLeft, moveRight])
        self.run(SKAction.repeatForever(seq))
    }
    
    func animateRightLeft(duration: TimeInterval) {
        let moveLeft = SKAction.moveTo(x: 0, duration: duration)
        let moveRight = SKAction.moveTo(x: -self.size.width/2.0, duration: duration)
        let seq = SKAction.sequence([moveLeft, moveRight])
        self.run(SKAction.repeatForever(seq))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func shootSauce() {
        isShooting = true
        let sauce = Sauce(type: stationType)
        addChild(sauce)
//        let moveAcross = SKAction.move(by: CGVector(dx: UIScreen.main.bounds.width + sauce.size.width, dy: -UIScreen.main.bounds.height/4.0), duration: 3)

        let moveAcross = SKAction.moveTo(x: UIScreen.main.bounds.width + sauce.size.width, duration: 3)
        let moveDown = SKAction.moveBy(x: 0, y: -UIScreen.main.bounds.height/4.0, duration: 3)
        let group = SKAction.group([moveAcross, moveDown])
        let reset = SKAction.run {
            self.isShooting = false
            sauce.removeFromParent()
        }
        sauce.run(SKAction.sequence([group, reset]))
    }
}