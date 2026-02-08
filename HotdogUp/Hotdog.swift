//
//  Hotdog.swift
//  HotdogUp
//
//  Created by Cathy Oun on 8/19/17.
//  Copyright © 2017 Cathy Oun. All rights reserved.
//

import UIKit
import SpriteKit

class Hotdog: SKSpriteNode {
    
    enum HotdogType: Int {
        case mrjj = 0
        case jane = 1
        case han = 2
        
        var name : String {
            switch self {
            case .mrjj: return "mrjj";
            case .jane: return "jane";
            case .han: return "han";
            }
        }
    }
    var actions: [SKTexture] = []
    var hotdogType = HotdogType.mrjj
    var hotdogTexture: SKTexture?
    var shotCount = 0
    init(hotdogType: HotdogType) {
        
        // safe texture loading
        let textureName = "\(hotdogType.name)_11"
        let texture = SKTexture(imageNamed: textureName)
        hotdogTexture = texture
        let sizeToUse = texture.size()
        super.init(texture: hotdogTexture, color: UIColor.clear, size: sizeToUse)
        self.hotdogType = hotdogType
//        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        // use a slightly smaller rectangle optionally
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: max(1, self.size.width-20), height: max(1, self.size.height)))
//        self.physicsBody = SKPhysicsBody(texture: hotdogTexture!, size: self.size)
//        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height/2.0)
        self.physicsBody?.mass = 0.18
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.physicsBody?.mass = 0.23
        }
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.restitution = 0.0
        createMovement()
    }
    private func createMovement() {
        for i in 1...10 {
            actions.append(SKTexture(imageNamed: "\(hotdogType.name)_\(i)"))
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
