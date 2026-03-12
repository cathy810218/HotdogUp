//
//  GameScene.swift
//  HotdogUp
//
//  Created by Cathy Oun on 5/21/17.
//  Copyright © 2017 Cathy Oun. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

// MARK: - GameScene Delegate

protocol GameSceneDelegate: AnyObject {
    func gameSceneDidEnd()
    func gameSceneDidScore(_ newScore: Int)
}

// MARK: - Physics Contact Categories

enum ContactCategory: UInt32 {
    case hotdog = 1
    case sidebounds = 2
    case leftbound = 4
    case rightbound = 8
    case path = 16
    case sauce = 32
    case station = 64
}

// MARK: - GameScene

class GameScene: SKScene, SKPhysicsContactDelegate {

    weak var gameSceneDelegate: GameSceneDelegate?

    /// Injected settings — the scene reads preferences through this instead of UserDefaults.
    var settings: GameSettings?

    // MARK: - Game Objects

    private(set) var hotdog = Hotdog(hotdogType: .mrjj)
    private var hotdogRunForever = SKAction()

    private var scrollingBackground = SKSpriteNode()
    private var initialBackground = SKSpriteNode()
    private var backgrounds = [SKSpriteNode]()

    private var scoreLabelNode = SKLabelNode()
    private var highestScoreLabel = SKLabelNode()

    private(set) var paths = [Path]()
    private(set) var stations = [Station]()

    // MARK: - Game State (scene-local rendering state)

    private var reuseCount = 0
    private var hotdogMoveVelocity: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 100.0 : 80.0
    private(set) var isGameOver = false
    private var isLanded = true

    var gamePaused = false {
        didSet { isPaused = gamePaused }
    }

    override var isPaused: Bool {
        didSet { super.isPaused = gamePaused }
    }

    var hasInternet = true {
        didSet { highestScoreLabel.fontColor = hasInternet ? .white : .red }
    }

    /// Score is owned by the scene for SpriteKit label updates and delegates
    /// upward so the ViewModel can persist it.
    private(set) var score = 0 {
        didSet {
            scoreLabelNode.text = String(score)
            gameSceneDelegate?.gameSceneDidScore(score)
            // Update highest label if needed
            if let s = settings, score > s.highestScore && hasInternet {
                highestScoreLabel.text = String(score)
            }
        }
    }

    // MARK: - Audio (read from settings)

    var isSoundEffectOn: Bool { settings?.isSoundEffectOn ?? true }
    var isMusicOn: Bool {
        get { settings?.isMusicOn ?? true }
        set {
            settings?.isMusicOn = newValue
            if !gamePaused {
                newValue ? MusicPlayer.resumePlay() : MusicPlayer.player.pause()
            }
        }
    }

    private var jumpSound = SKAction()
    private var fallingSound = SKAction()

    // MARK: - Charged Jump

    private var touchStartTimes: [ObjectIdentifier: TimeInterval] = [:]
    private let maxChargeDuration: TimeInterval = 0.6
    private let minJumpImpulse: CGFloat = CGFloat(kMinJumpHeight + 5)
    private let maxJumpImpulse: CGFloat = CGFloat(kMaxJumpHeight)

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        highestScoreLabel.fontColor = hasInternet ? .white : .red

        if !isGameOver {
            physicsWorld.contactDelegate = self
            physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
            createBackground()
            setupPaths()
            setupCounterLabel()
            setupHighestScoreLabel()
            createHotdog()
            createStation()
            jumpSound = SKAction.playSoundFileNamed("\(hotdog.hotdogType.name)_hop", waitForCompletion: false)
            fallingSound = SKAction.playSoundFileNamed("\(hotdog.hotdogType.name)_fall", waitForCompletion: true)
        }
        MusicPlayer.loadBackgroundMusic()
        isMusicOn ? MusicPlayer.resumePlay() : MusicPlayer.player.stop()
    }

    func resetGameScene() {
        removeAllChildren()
        paths.removeAll()
        stations.removeAll()

        setupPaths()
        setupHighestScoreLabel()
        createHotdog()
        createBackground()
        createStation()

        score = 0
        reuseCount = 0
        scoreLabelNode.text = "0"

        gamePaused = false
        isGameOver = false
        isLanded = true
        isUserInteractionEnabled = true

        if settings?.isMusicOn == true {
            MusicPlayer.replay()
        }
    }

    // MARK: - Background & Bounds

    private func createBackground() {
        for i in 0...1 {
            scrollingBackground = SKSpriteNode(texture: SKTexture(imageNamed: "background_second"))
            scrollingBackground.zPosition = -30
            scrollingBackground.anchorPoint = .zero
            scrollingBackground.size = CGSize(width: frame.size.width, height: frame.size.height)
            scrollingBackground.position = CGPoint(x: 0, y: scrollingBackground.size.height * CGFloat(i))
            addChild(scrollingBackground)
            backgrounds.append(scrollingBackground)

            let moveDown = SKAction.moveBy(x: 0, y: -scrollingBackground.size.height, duration: 12)
            let moveReset = SKAction.moveBy(x: 0, y: scrollingBackground.size.height, duration: 0)
            scrollingBackground.run(SKAction.repeatForever(SKAction.sequence([moveDown, moveReset])))
            scrollingBackground.speed = 0
        }

        initialBackground = SKSpriteNode(texture: SKTexture(imageNamed: "background_first"))
        initialBackground.zPosition = -20
        initialBackground.anchorPoint = .zero
        initialBackground.size = CGSize(width: frame.size.width, height: frame.size.height)
        initialBackground.position = .zero
        addChild(initialBackground)
        initialBackground.run(SKAction.moveBy(x: 0, y: -initialBackground.size.height, duration: 12))
        initialBackground.speed = 0

        // Boundary physics bodies
        physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: 0), to: CGPoint(x: frame.size.width, y: 0))
        physicsBody?.categoryBitMask = ContactCategory.sidebounds.rawValue
        physicsBody?.contactTestBitMask = ContactCategory.hotdog.rawValue
        physicsBody?.restitution = 0.0

        let leftNode = SKSpriteNode()
        addChild(leftNode)
        leftNode.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: frame.size.height + CGFloat(kMaxJumpHeight)),
                                             to: CGPoint(x: 0, y: CGFloat(-kMaxJumpHeight)))
        leftNode.physicsBody?.categoryBitMask = ContactCategory.leftbound.rawValue
        leftNode.physicsBody?.contactTestBitMask = ContactCategory.hotdog.rawValue

        let rightNode = SKSpriteNode()
        addChild(rightNode)
        rightNode.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: frame.size.width, y: frame.size.height + CGFloat(kMaxJumpHeight)),
                                              to: CGPoint(x: frame.size.width, y: CGFloat(-kMaxJumpHeight)))
        rightNode.physicsBody?.categoryBitMask = ContactCategory.rightbound.rawValue
        rightNode.physicsBody?.contactTestBitMask = ContactCategory.hotdog.rawValue

        speed = 1
    }

    // MARK: - Hotdog

    private func createHotdog() {
        let selectedType = settings?.selectedHotdogType ?? .mrjj
        hotdog = Hotdog(hotdogType: selectedType)

        hotdog.zPosition = 30
        hotdog.position = CGPoint(x: frame.size.width / 2.0, y: hotdog.size.height / 2.0)
        hotdog.physicsBody?.categoryBitMask = ContactCategory.hotdog.rawValue
        hotdog.physicsBody?.collisionBitMask = ContactCategory.sidebounds.rawValue
            | ContactCategory.rightbound.rawValue
            | ContactCategory.leftbound.rawValue
        let run = SKAction.animate(with: hotdog.actions, timePerFrame: 0.2)
        hotdogRunForever = SKAction.repeatForever(run)
        hotdogMoveVelocity = 80.0
        addChild(hotdog)
    }

    // MARK: - HUD Labels

    private func setupCounterLabel() {
        scoreLabelNode = SKLabelNode(fontNamed: kScoreFontName)
        scoreLabelNode.text = "0"
        scoreLabelNode.fontSize = kScoreFontSize
        scoreLabelNode.fontColor = .white
        scoreLabelNode.zPosition = 40
        scoreLabelNode.verticalAlignmentMode = .top
        scoreLabelNode.position = CGPoint(x: frame.midX, y: frame.height - kScoreTopOffset)
        addChild(scoreLabelNode)
    }

    private func setupHighestScoreLabel() {
        let titleLabel = SKLabelNode()
        titleLabel.text = "Highest"
        addChild(titleLabel)
        titleLabel.position = CGPoint(x: frame.width - 60, y: frame.height - 45)
        titleLabel.fontColor = .white
        titleLabel.fontSize = 18
        titleLabel.fontName = "AmericanTypewriter"
        titleLabel.verticalAlignmentMode = .center
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.zPosition = 35

        highestScoreLabel.text = String(settings?.highestScore ?? 0)
        addChild(highestScoreLabel)
        highestScoreLabel.position = CGPoint(x: titleLabel.position.x, y: frame.height - 65)
        highestScoreLabel.fontColor = .white
        highestScoreLabel.fontSize = 16
        highestScoreLabel.fontName = "AmericanTypewriter"
        highestScoreLabel.verticalAlignmentMode = .center
        highestScoreLabel.horizontalAlignmentMode = .center
        highestScoreLabel.zPosition = 35
    }

    // MARK: - Platforms

    private func setupPaths() {
        generatePaths()
        for path in paths {
            path.physicsBody?.categoryBitMask = ContactCategory.path.rawValue
            path.physicsBody?.contactTestBitMask = ContactCategory.hotdog.rawValue
            path.physicsBody?.collisionBitMask = ContactCategory.hotdog.rawValue
            addChild(path)
            let moveDown = SKAction.moveBy(x: 0, y: -scrollingBackground.size.height, duration: 12)
            path.run(SKAction.repeatForever(moveDown))
            path.speed = 0
        }
    }

    private func generatePaths() {
        let samplePath = Path(position: .zero)
        let tx = randomPoint(min: Int(samplePath.size.width / 2.0),
                             max: Int(frame.size.width - samplePath.size.width))
        var currentPath = Path(position: CGPoint(x: tx, y: kMinJumpHeight))
        paths.append(currentPath)
        var previousPath = currentPath

        for _ in 0...3 {
            guard let last = paths.last else { continue }
            currentPath = last
            var x = randomPoint(min: Int(currentPath.size.width / 2.0),
                                max: Int(frame.size.width - currentPath.size.width))
            while abs(Int(previousPath.position.x) - x) > Int(kPathGapMultiplier * currentPath.size.width) {
                x = randomPoint(min: Int(currentPath.size.width / 2.0),
                                max: Int(frame.size.width - currentPath.size.width))
            }
            let y = Int(currentPath.frame.origin.y) + kMinJumpHeight + kPathYIncrement
            let newPath = Path(position: CGPoint(x: x, y: y))
            previousPath = newPath
            newPath.tag = currentPath.tag + 1
            paths.append(newPath)
        }
    }

    private func randomPoint(min: Int, max: Int) -> Int {
        guard max >= min else { return min }
        return Int.random(in: min...max)
    }

    private func reusePath() {
        for path in paths {
            guard path.position.y < 0 else { continue }
            path.reset()

            var minLeft = 0
            if path.tag == 0 {
                reuseCount += 1
            }
            if reuseCount % kNumOfStairsToUpdate == 0 {
                let level = min(reuseCount / kNumOfStairsToUpdate, 4)
                if let newType = PathType(rawValue: level) {
                    path.type = newType
                }
                if level >= 2 && level < 5 {
                    minLeft = Int(stations.first?.size.width ?? 0)
                    if path.tag >= 3 {
                        stations.forEach { station in
                            station.isHidden = false
                            if let sType = StationType(rawValue: level) {
                                station.stationType = sType
                            }
                        }
                    }
                }
            }

            var x = randomPoint(min: Int(path.size.width / 2.0),
                                max: Int(frame.size.width - path.size.width))
            var attempts = 0
            while (paths.last.map { abs(Int($0.position.x) - x) } ?? 0) > Int(kPathGapMultiplier * path.size.width) || x <= minLeft {
                x = randomPoint(min: Int(path.size.width / 2.0),
                                max: Int(frame.size.width - path.size.width))
                attempts += 1
                if attempts >= kPathMaxAttempts { break }
            }
            guard let last = paths.last else { continue }
            let y = Int(last.frame.origin.y) + kMinJumpHeight + 30
            path.position = CGPoint(x: x, y: y)
            if let idx = paths.firstIndex(of: path) {
                paths.remove(at: idx)
                paths.append(path)
            }
        }
    }

    // MARK: - Stations (Enemies)

    private func createStation() {
        for i in 0...2 {
            let station = Station()
            let y = Int(size.height / 4.0) * (i + 1)
            station.position = CGPoint(x: i == 1 ? -station.size.width / 2.0 : 0, y: CGFloat(y))
            station.tag = i
            stations.append(station)
            addChild(station)
            station.isHidden = true
            if i == 1 {
                station.animateRightLeft()
            } else {
                station.animateLeftRight()
            }
        }
    }

    // MARK: - Game Over

    func gameOver() {
        isGameOver = true
        if isSoundEffectOn {
            run(fallingSound)
        }
        speed = 0
        gameSceneDelegate?.gameSceneDidEnd()
        isMusicOn = false
        isUserInteractionEnabled = false
        hotdog.speed = 0
    }

    // MARK: - Game Loop

    override func update(_ currentTime: TimeInterval) {
        guard let body = hotdog.physicsBody else { return }
        let dy = body.velocity.dy
        if dy > 0 && !isLanded {
            body.collisionBitMask = ContactCategory.sidebounds.rawValue
                | ContactCategory.rightbound.rawValue
                | ContactCategory.leftbound.rawValue
        }
        reusePath()

        if hotdog.position.y < -100 && !isGameOver {
            gameOver()
        }

        if stations.count == 3 {
            for i in 0...2 {
                if stations[i].position.x >= -10 && !stations[i].isHidden && !stations[i].isShooting {
                    stations[i].shootSauce()
                }
            }
        }
    }

    // MARK: - Collision Detection

    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB

        func bodyHas(_ body: SKPhysicsBody, _ category: ContactCategory) -> Bool {
            (body.categoryBitMask & category.rawValue) != 0
        }

        if let hBody = hotdog.physicsBody {
            let dy = hBody.velocity.dy
            isLanded = dy <= 1.0 && dy >= 0.0
        }

        // Ground
        if bodyHas(bodyA, .sidebounds) || bodyHas(bodyB, .sidebounds) {
            isLanded = true
        }

        // Wall bounces
        if bodyHas(bodyA, .leftbound) || bodyHas(bodyB, .leftbound) {
            hotdog.xScale *= hotdog.xScale > 0 ? 1 : -1
            hotdog.removeAction(forKey: "moveLeft")
            let moveRight = SKAction.moveBy(x: hotdogMoveVelocity, y: 0, duration: 1)
            hotdog.run(SKAction.repeatForever(moveRight), withKey: "moveRight")
        } else if bodyHas(bodyA, .rightbound) || bodyHas(bodyB, .rightbound) {
            hotdog.xScale *= hotdog.xScale > 0 ? -1 : 1
            hotdog.removeAction(forKey: "moveRight")
            let moveLeft = SKAction.moveBy(x: -hotdogMoveVelocity, y: 0, duration: 1)
            hotdog.run(SKAction.repeatForever(moveLeft), withKey: "moveLeft")
        }

        // Platform landing
        if bodyHas(bodyA, .path) || bodyHas(bodyB, .path) {
            let currPathBody = bodyHas(bodyA, .path) ? bodyA : bodyB
            if let currPath = currPathBody.node as? Path, let hBody = hotdog.physicsBody {
                let dy = hBody.velocity.dy
                if dy > 0 {
                    hBody.collisionBitMask = ContactCategory.sidebounds.rawValue
                        | ContactCategory.rightbound.rawValue
                        | ContactCategory.leftbound.rawValue
                } else {
                    if hotdog.position.y - hotdog.size.height / 2.0 >= currPath.position.y + currPath.size.height / 2 - 20 {
                        hBody.contactTestBitMask = ContactCategory.path.rawValue | ContactCategory.sauce.rawValue
                        hBody.collisionBitMask = ContactCategory.path.rawValue
                            | ContactCategory.sidebounds.rawValue
                            | ContactCategory.leftbound.rawValue
                            | ContactCategory.rightbound.rawValue
                        if !currPath.isVisited {
                            score += 1
                            currPath.isVisited = true
                        }
                        isLanded = true
                    }
                }
            }
        }

        // Sauce hit
        if (bodyHas(bodyA, .sauce) || bodyHas(bodyB, .sauce)) && !isGameOver {
            let sauceBody = bodyHas(bodyA, .sauce) ? bodyA : bodyB
            sauceBody.node?.removeFromParent()
            gameOver()
        }
    }

    // MARK: - Touch Input

    private func touchDown(atPoint pos: CGPoint) {
        if pos.x < frame.size.width / 5.0 {
            if !hotdog.hasActions() {
                hotdog.run(hotdogRunForever, withKey: "hotdogRunForever")
            }
            hotdog.xScale *= hotdog.xScale > 0 ? -1 : 1
            hotdog.removeAction(forKey: "moveRight")
            let moveLeft = SKAction.moveBy(x: -hotdogMoveVelocity, y: 0, duration: 1)
            hotdog.run(SKAction.repeatForever(moveLeft), withKey: "moveLeft")
        } else if pos.x > 4 * frame.size.width / 5.0 {
            if !hotdog.hasActions() {
                hotdog.run(hotdogRunForever, withKey: "hotdogRunForever")
            }
            hotdog.xScale *= hotdog.xScale > 0 ? 1 : -1
            hotdog.removeAction(forKey: "moveLeft")
            let moveRight = SKAction.moveBy(x: hotdogMoveVelocity, y: 0, duration: 1)
            hotdog.run(SKAction.repeatForever(moveRight), withKey: "moveRight")
        } else {
            if !hotdog.hasActions() {
                hotdog.texture = hotdog.hotdogTexture
            }
        }
    }

    private func applyJump(for duration: TimeInterval) {
        guard isLanded else { return }
        let clamped = min(duration, maxChargeDuration)
        let t = CGFloat(clamped / maxChargeDuration)
        let impulse = minJumpImpulse + t * (maxJumpImpulse - minJumpImpulse)
        hotdog.physicsBody?.applyImpulse(CGVector(dx: 0, dy: impulse))
        if isSoundEffectOn {
            run(jumpSound)
        }
        isLanded = false

        // Start scrolling once hotdog is high enough
        if hotdog.position.y > frame.size.height / 2.0 && scrollingBackground.speed == 0 {
            initialBackground.speed = kGameSpeed
            for bg in backgrounds { bg.speed = kGameSpeed }
            for path in paths { path.speed = kGameSpeed }
            physicsBody?.categoryBitMask = ContactCategory.hotdog.rawValue
        }

        // Level-up difficulty scaling
        if score % kLevel == 0 && score > 0 {
            hotdog.physicsBody?.mass += 0.001
            for bg in backgrounds { bg.speed += kSpeedIncrement }
            hotdogMoveVelocity += kHotdogMoveVelocityIncrement
            for path in paths { path.speed += kSpeedIncrement }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let pos = t.location(in: self)
            touchDown(atPoint: pos)
            if pos.x >= frame.size.width / 5.0 && pos.x <= 4 * frame.size.width / 5.0 {
                touchStartTimes[ObjectIdentifier(t)] = t.timestamp
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let id = ObjectIdentifier(t)
            if let start = touchStartTimes[id] {
                applyJump(for: t.timestamp - start)
                touchStartTimes[id] = nil
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchStartTimes[ObjectIdentifier(t)] = nil }
    }
}
