//
//  Path.swift
//  HotdogUp
//
//  Created by Cathy Oun on 8/2/17.
//  Copyright © 2017 Cathy Oun. All rights reserved.
//

import UIKit
import SpriteKit
enum PathType: Int {
    case pickle = 0
    case onion = 1
    case tomato = 2
    case mustard = 3
    case fire = 4
    
    
    var name : String {
        switch self {
        case .pickle: return "pickle"
        case .onion: return "onion"
        case .tomato: return "tomato"
        case .mustard: return "mustard"
        case .fire: return "fire"
        }
    }

    /// Width scale relative to the base texture size.
    /// Early platforms are wider (easier), later ones shrink.
    var widthScale: CGFloat {
        switch self {
        case .pickle, .onion: return 1.4
        case .tomato, .mustard: return 1.2
        case .fire: return 1.0
        }
    }
}
class Path: SKSpriteNode {
    var isVisited: Bool
    var tag = 0
    private var baseSize: CGSize = .zero

    var type: PathType = PathType.pickle {
        didSet {
            let tex = SKTexture(imageNamed: "\(type.name)")
            self.texture = tex
            let newSize = CGSize(width: baseSize.width * type.widthScale,
                                 height: baseSize.height)
            self.size = newSize
            self.physicsBody = SKPhysicsBody(rectangleOf: newSize)
            self.physicsBody?.allowsRotation = false
            self.physicsBody?.affectedByGravity = false
            self.physicsBody?.isDynamic = false
            self.physicsBody?.friction = 1
            self.physicsBody?.restitution = 0.0
            self.physicsBody?.categoryBitMask = ContactCategory.path.rawValue
            self.physicsBody?.contactTestBitMask = ContactCategory.hotdog.rawValue
            self.physicsBody?.collisionBitMask = ContactCategory.hotdog.rawValue
        }
    }
    
    init(position: CGPoint) {
        let texture = SKTexture(imageNamed: "pickle")
        let texSize = texture.size()
        self.baseSize = texSize
        self.isVisited = false
        let scaledSize = CGSize(width: texSize.width * PathType.pickle.widthScale,
                                height: texSize.height)
        super.init(texture: texture, color: UIColor.clear, size: scaledSize)
        self.position = position
        self.physicsBody = SKPhysicsBody(rectangleOf: scaledSize)
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = false
        self.physicsBody?.friction = 1
        self.physicsBody?.restitution = 0.0
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        isVisited = false
    }
}
