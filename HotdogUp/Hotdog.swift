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

        var name: String {
            switch self {
            case .mrjj: return "mrjj"
            case .jane: return "jane"
            case .han: return "han"
            }
        }
    }

    /// Accessories awarded in fixed order every kRewardInterval platforms.
    /// The sequence repeats, so accessories accumulate on the hotdog.
    enum AccessoryType: CaseIterable {
        case crown
        case cape
        case sunglasses
        case halo
        case bowtie
        case headband
    }

    var actions: [SKTexture] = []
    var hotdogType = HotdogType.mrjj
    var hotdogTexture: SKTexture?
    var shotCount = 0

    /// All currently displayed accessory nodes, accumulated over milestones.
    private(set) var accessoryNodes: [SKNode] = []

    init(hotdogType: HotdogType) {
        let textureName = "\(hotdogType.name)_11"
        let texture = SKTexture(imageNamed: textureName)
        hotdogTexture = texture
        let sizeToUse = texture.size()
        super.init(texture: hotdogTexture, color: .clear, size: sizeToUse)
        self.hotdogType = hotdogType
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: max(1, self.size.width - 20),
                                                             height: max(1, self.size.height)))
        self.physicsBody?.mass = kHotdogDefaultMass
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.physicsBody?.mass = kHotdogPadMass
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

    // MARK: - Accessory System

    /// Adds the next accessory in the fixed sequence. Accessories accumulate.
    func attachAccessory(_ type: AccessoryType) {
        let node: SKNode
        switch type {
        case .crown:
            node = makeCrown()
        case .cape:
            node = makeCape()
        case .sunglasses:
            node = makeSunglasses()
        case .bowtie:
            node = makeBowtie()
        case .halo:
            node = makeHalo()
        case .headband:
            node = makeHeadband()
        }

        node.zPosition = 5
        addChild(node)
        accessoryNodes.append(node)

        // Pop-in animation
        node.setScale(0.01)
        node.run(SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.15),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
    }

    func removeAllAccessories() {
        accessoryNodes.forEach { $0.removeFromParent() }
        accessoryNodes.removeAll()
    }

    // MARK: - Procedural Accessory Builders

    private func makeCape() -> SKNode {
        let capePath = CGMutablePath()
        capePath.move(to: CGPoint(x: -10, y: 0))
        capePath.addLine(to: CGPoint(x: -14, y: -22))
        capePath.addQuadCurve(to: CGPoint(x: 14, y: -22), control: CGPoint(x: 0, y: -28))
        capePath.addLine(to: CGPoint(x: 10, y: 0))
        capePath.closeSubpath()
        let cape = SKShapeNode(path: capePath)
        cape.fillColor = UIColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 0.9)
        cape.strokeColor = UIColor(red: 0.6, green: 0, blue: 0, alpha: 1)
        cape.lineWidth = 1.0
        cape.position = CGPoint(x: 0, y: -size.height / 2.0 + 5)
        cape.zPosition = -1

        // Gentle flutter animation
        let flutter = SKAction.sequence([
            SKAction.scaleX(to: 1.1, duration: 0.4),
            SKAction.scaleX(to: 0.9, duration: 0.4)
        ])
        cape.run(SKAction.repeatForever(flutter))

        return cape
    }

    private func makeSunglasses() -> SKNode {
        let container = SKNode()
        container.position = CGPoint(x: 0, y: size.height / 2.0 - 10)

        // Left lens
        let leftLens = SKShapeNode(rectOf: CGSize(width: 10, height: 7), cornerRadius: 2)
        leftLens.fillColor = UIColor(white: 0.1, alpha: 0.9)
        leftLens.strokeColor = .white
        leftLens.lineWidth = 1.0
        leftLens.position = CGPoint(x: -7, y: 0)
        container.addChild(leftLens)

        // Right lens
        let rightLens = SKShapeNode(rectOf: CGSize(width: 10, height: 7), cornerRadius: 2)
        rightLens.fillColor = UIColor(white: 0.1, alpha: 0.9)
        rightLens.strokeColor = .white
        rightLens.lineWidth = 1.0
        rightLens.position = CGPoint(x: 7, y: 0)
        container.addChild(rightLens)

        // Bridge
        let bridge = SKShapeNode(rectOf: CGSize(width: 4, height: 1.5))
        bridge.fillColor = .white
        bridge.strokeColor = .clear
        bridge.position = .zero
        container.addChild(bridge)

        return container
    }

    private func makeCrown() -> SKNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -12, y: 0))
        path.addLine(to: CGPoint(x: -12, y: 12))
        path.addLine(to: CGPoint(x: -6, y: 6))
        path.addLine(to: CGPoint(x: 0, y: 14))
        path.addLine(to: CGPoint(x: 6, y: 6))
        path.addLine(to: CGPoint(x: 12, y: 12))
        path.addLine(to: CGPoint(x: 12, y: 0))
        path.closeSubpath()
        let crown = SKShapeNode(path: path)
        crown.fillColor = .yellow
        crown.strokeColor = UIColor(red: 0.85, green: 0.65, blue: 0, alpha: 1)
        crown.lineWidth = 1.5
        crown.position = CGPoint(x: 0, y: size.height / 2.0 - 2)
        return crown
    }

    private func makeBowtie() -> SKNode {
        let container = SKNode()
        container.position = CGPoint(x: 0, y: -size.height / 2.0 + 8)

        // Left triangle
        let leftPath = CGMutablePath()
        leftPath.move(to: .zero)
        leftPath.addLine(to: CGPoint(x: -10, y: 5))
        leftPath.addLine(to: CGPoint(x: -10, y: -5))
        leftPath.closeSubpath()
        let left = SKShapeNode(path: leftPath)
        left.fillColor = .magenta
        left.strokeColor = .white
        left.lineWidth = 0.5
        container.addChild(left)

        // Right triangle
        let rightPath = CGMutablePath()
        rightPath.move(to: .zero)
        rightPath.addLine(to: CGPoint(x: 10, y: 5))
        rightPath.addLine(to: CGPoint(x: 10, y: -5))
        rightPath.closeSubpath()
        let right = SKShapeNode(path: rightPath)
        right.fillColor = .magenta
        right.strokeColor = .white
        right.lineWidth = 0.5
        container.addChild(right)

        // Center knot
        let knot = SKShapeNode(circleOfRadius: 2)
        knot.fillColor = .white
        knot.strokeColor = .clear
        container.addChild(knot)

        return container
    }

    private func makeHalo() -> SKNode {
        let halo = SKShapeNode(ellipseOf: CGSize(width: 24, height: 8))
        halo.fillColor = UIColor(red: 1, green: 0.95, blue: 0.4, alpha: 0.6)
        halo.strokeColor = .yellow
        halo.lineWidth = 1.5
        halo.position = CGPoint(x: 0, y: size.height / 2.0 + 6)
        halo.glowWidth = 2

        // Gentle bob animation
        let bob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 2, duration: 0.6),
            SKAction.moveBy(x: 0, y: -2, duration: 0.6)
        ])
        halo.run(SKAction.repeatForever(bob))

        return halo
    }

    private func makeHeadband() -> SKNode {
        let container = SKNode()
        container.position = CGPoint(x: 0, y: size.height / 2.0)

        // Band
        let band = SKShapeNode(rectOf: CGSize(width: size.width * 0.7, height: 3), cornerRadius: 1)
        band.fillColor = .cyan
        band.strokeColor = .clear
        container.addChild(band)

        // Star on top
        let star = SKLabelNode(text: "\u{2605}")  // Unicode star
        star.fontSize = 14
        star.fontColor = .cyan
        star.verticalAlignmentMode = .bottom
        star.position = CGPoint(x: 0, y: 2)
        container.addChild(star)

        return container
    }
}
