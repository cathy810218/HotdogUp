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

protocol GameSceneDelegate: AnyObject {
    func gameSceneGameEnded()
}

enum GameState {
    case playing
    case dead
}

enum ContactCategory: UInt32 {
    case hotdog = 1
    case sidebounds = 2
    case leftbound = 4
    case rightbound = 8
    case path = 16
    case sauce = 32
    case station = 64
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    weak var gameSceneDelegate: GameSceneDelegate?
    
    var hotdog = Hotdog(hotdogType: .mrjj)
    var hotdogRunForever = SKAction()
    
    var background = SKSpriteNode()
    var initialBackground = SKSpriteNode()
    
    var scoreLabelNode = SKLabelNode()
    var highest = SKLabelNode()
    var reuseCount = 0
    var hotdogMoveVelocity: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 100.0 : 80.0
    var gamePaused = false {
        didSet {
            isPaused = gamePaused
        }
    }
    
    override var isPaused: Bool {
        didSet {
            super.isPaused = gamePaused
        }
    }
    var hasInternet = true {
        didSet {
            highest.fontColor = hasInternet ? UIColor.white : UIColor.red
        }
    }
    var score = 0 {
        didSet {
            scoreLabelNode.text = String(score)
            if (score > UserDefaults.standard.integer(forKey: "UserDefaultsHighestScoreKey") && hasInternet) {
                highest.text = String(score)
                UserDefaults.standard.set(score, forKey: "UserDefaultsHighestScoreKey")
            }
        }
    }
    var timer = Timer()
    var timeCounter = kMinJumpHeight
    var isLanded = true
    var paths = [Path]()
    var stations = [Station]()
    var healths = [SKSpriteNode]()
    var backgrounds = [SKSpriteNode]()
    var isGameOver = false
    var jumpSound = SKAction()
    var fallingSound = SKAction()
    var isSoundEffectOn = UserDefaults.standard.bool(forKey: "UserDefaultsIsSoundEffectOnKey")
    var isMusicOn = UserDefaults.standard.bool(forKey: "UserDefaultsIsMusicOnKey") {
        didSet {
            if !gamePaused {
                isMusicOn ? MusicPlayer.resumePlay() : MusicPlayer.player.pause()
            }
        }
    }
    var isReset = false {
        didSet {
            if isReset && UserDefaults.standard.bool(forKey: "UserDefaultsIsMusicOnKey"){
                MusicPlayer.replay()
            }
        }
    }
    
    // --- new: charge jump state and configuration
    // track touch start timestamps so long press -> higher jump
    var touchStartTimes: [ObjectIdentifier: TimeInterval] = [:]
    let maxChargeDuration: TimeInterval = 0.6
    let minJumpImpulse: CGFloat = CGFloat(kMinJumpHeight + 5)
    let maxJumpImpulse: CGFloat = CGFloat(kMaxJumpHeight)
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        highest.fontColor = hasInternet ? UIColor.white : UIColor.red
        
        if !isGameOver {
            self.physicsWorld.contactDelegate = self
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
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
        isReset = true
        isUserInteractionEnabled = true
    }
    
    func createBackground() {
        
        for i in 0 ... 1 {
            background = SKSpriteNode(texture: SKTexture(imageNamed: "background_second"))
            background.zPosition = -30
            background.anchorPoint = CGPoint.zero
            background.size = CGSize(width: self.frame.size.width,
                                     height: self.frame.size.height)
            background.position = CGPoint(x: 0, y: background.size.height * CGFloat(i))
            addChild(background)
            backgrounds.append(background)
            let moveDown = SKAction.moveBy(x: 0, y: -background.size.height, duration: 12)
            let moveReset = SKAction.moveBy(x: 0, y: background.size.height, duration: 0)
            let moveLoop = SKAction.sequence([moveDown, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            background.run(moveForever)
            background.speed = 0
        }
        initialBackground = SKSpriteNode(texture: SKTexture(imageNamed: "background_first"))
        initialBackground.zPosition = -20
        initialBackground.anchorPoint = CGPoint.zero
        initialBackground.size = CGSize(width: self.frame.size.width, height: self.frame.size.height)
        initialBackground.position = CGPoint(x: 0, y: 0)
        addChild(initialBackground)
        let moveDown = SKAction.moveBy(x: 0, y: -initialBackground.size.height, duration: 12)
        initialBackground.run(moveDown)
        initialBackground.speed = 0
        
        // Add boundries physics body
        physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: 0), to: CGPoint(x: self.frame.size.width, y: 0))
        physicsBody?.categoryBitMask = ContactCategory.sidebounds.rawValue
        physicsBody?.contactTestBitMask = ContactCategory.hotdog.rawValue
        physicsBody?.restitution = 0.0
        let leftNode = SKSpriteNode()
        addChild(leftNode)
        leftNode.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: self.frame.size.height + CGFloat(kMaxJumpHeight)), to: CGPoint(x: 0, y: CGFloat(-kMaxJumpHeight)))
        leftNode.physicsBody?.categoryBitMask = ContactCategory.leftbound.rawValue
        leftNode.physicsBody?.contactTestBitMask = ContactCategory.hotdog.rawValue
        
        let rightNode = SKSpriteNode()
        addChild(rightNode)
        rightNode.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: self.frame.size.width, y: self.frame.size.height + CGFloat(kMaxJumpHeight)), to: CGPoint(x: self.frame.size.width, y: CGFloat(-kMaxJumpHeight)))
        rightNode.physicsBody?.categoryBitMask = ContactCategory.rightbound.rawValue
        rightNode.physicsBody?.contactTestBitMask = ContactCategory.hotdog.rawValue
        speed = 1
    }
    
    func createHotdog() {
        // Safely select hotdog type from UserDefaults, fallback to .mrjj
        let selectedRaw = UserDefaults.standard.integer(forKey: "UserDefaultsSelectCharacterKey")
        let selectedType = Hotdog.HotdogType(rawValue: selectedRaw) ?? .mrjj
        hotdog = Hotdog(hotdogType: selectedType)
        
        hotdog.zPosition = 30
        hotdog.position = CGPoint(x: self.frame.size.width/2.0, y: hotdog.size.height/2.0)
        hotdog.physicsBody?.categoryBitMask = ContactCategory.hotdog.rawValue
        hotdog.physicsBody?.collisionBitMask = ContactCategory.sidebounds.rawValue
        | ContactCategory.rightbound.rawValue
        | ContactCategory.leftbound.rawValue
        let run = SKAction.animate(with: hotdog.actions, timePerFrame: 0.2)
        hotdogRunForever = SKAction.repeatForever(run)
        hotdogMoveVelocity = 80.0
        self.addChild(hotdog)
    }
    
    func setupCounterLabel() {
        scoreLabelNode = SKLabelNode(fontNamed: kScoreFontName)
        scoreLabelNode.text = "0"
        scoreLabelNode.fontSize = kScoreFontSize
        scoreLabelNode.fontColor = .white
        scoreLabelNode.zPosition = 40
        scoreLabelNode.verticalAlignmentMode = .top
        // position near the top-center using scene coordinates
        scoreLabelNode.position = CGPoint(x: self.frame.midX, y: self.frame.height - kScoreTopOffset)
        addChild(scoreLabelNode)
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let body = hotdog.physicsBody else { return }
        let dy = body.velocity.dy
        if dy > 0 && !isLanded {
            // Prevent collisions if the hotdog is jumping -> no pathCategory
            body.collisionBitMask = ContactCategory.sidebounds.rawValue | ContactCategory.rightbound.rawValue | ContactCategory.leftbound.rawValue
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
    
    func setupPaths() {
        generatePaths()
        for path in paths {
            path.physicsBody?.categoryBitMask = ContactCategory.path.rawValue
            path.physicsBody?.contactTestBitMask = ContactCategory.hotdog.rawValue
            path.physicsBody?.collisionBitMask = ContactCategory.hotdog.rawValue
            addChild(path)
            let moveDown = SKAction.moveBy(x: 0, y: -background.size.height, duration: 12)
            let moveForever = SKAction.repeatForever(moveDown)
            path.run(moveForever)
            path.speed = 0
        }
    }
    
    private func generatePaths() {
        let path = Path(position: CGPoint.zero)
        let tx = p_randomPoint(min: Int(path.size.width / 2.0),
                               max: Int(self.frame.size.width - path.size.width))
        var firstPath = Path(position: CGPoint(x: tx,
                                               y: kMinJumpHeight))
        paths.append(firstPath)
        var lastPath = firstPath
        for _ in 0 ... 3 {
            // safely get the last path instead of force-unwrapping
            guard let maybeFirst = paths.last else { continue }
            firstPath = maybeFirst
            var x = p_randomPoint(min: Int(firstPath.size.width / 2.0),
                                  max: Int(self.frame.size.width - firstPath.size.width))
            
            // if the distance between two paths (center to center) is greater than 1.5 paths
            while abs(Int(lastPath.position.x) - x) > Int(kPathGapMultiplier * firstPath.size.width) {
                x = p_randomPoint(min: Int(firstPath.size.width / 2.0),
                                  max: Int(self.frame.size.width - firstPath.size.width))
            }
            
            let y = Int(firstPath.frame.origin.y) + kMinJumpHeight + kPathYIncrement
            let path = Path(position: CGPoint(x: x, y: y))
            lastPath = path
            path.tag = firstPath.tag + 1
            paths.append(path)
        }
    }
    
    private func p_randomPoint(min: Int, max: Int) -> Int {
        guard max >= min else { return min }
        return Int.random(in: min...max)
    }
    
    private func reusePath() {
        for path in paths {
            if path.position.y < 0 {
                path.reset()
                
                var minLeft = 0
                if path.tag == 0 {
                    reuseCount += 1
                }
                if reuseCount % kNumOfStairsToUpdate == 0 { // every kNumOfStairsToUpdate * 5 stairs change the stair style
                    let level = reuseCount / kNumOfStairsToUpdate > 4 ? 4 : reuseCount / kNumOfStairsToUpdate
                    if let newType = PathType(rawValue: level) {
                        path.type = newType
                    }
                    
                    if level >= 2 && level < 5 {
                        // guard stations access - if stations are not yet created this will safely fallback to 0
                        minLeft = Int(stations.first?.size.width ?? 0)
                        if path.tag >= 3 {
                            stations.forEach({ (station) in
                                station.isHidden = false
                                if let sType = StationType(rawValue: level) {
                                    station.stationType = sType
                                }
                            })
                        }
                    }
                }
                
                
                
                var x = p_randomPoint(min: Int(path.size.width / 2.0),
                                      max: Int(self.frame.size.width - path.size.width))
                
                // if the distance between two paths (center to center) is greater than 1.8 paths
                var attempts = 0
                while (paths.last.map { abs(Int($0.position.x) - x) } ?? 0) > Int(kPathGapMultiplier * path.size.width) || x <= minLeft {
                    x = p_randomPoint(min: Int(path.size.width / 2.0),
                                      max: Int(self.frame.size.width - path.size.width))
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
    }
    
    func createStation() {
        // generates
        for i in 0...2 {
            let station = Station()
            let y = Int(self.size.height / 4.0) * (i + 1)
            station.position = CGPoint(x: i == 1 ? -station.size.width/2.0 : 0, y: CGFloat(y))
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
    
    func setupHighestScoreLabel() {
        let highestScoreLab = SKLabelNode()
        highestScoreLab.text = "Highest"
        addChild(highestScoreLab)
        highestScoreLab.position = CGPoint(x: self.frame.width - 60, y: self.frame.height - 45)
        highestScoreLab.fontColor = UIColor.white
        highestScoreLab.fontSize = 18
        highestScoreLab.fontName = "AmericanTypewriter"
        highestScoreLab.verticalAlignmentMode = .center
        highestScoreLab.horizontalAlignmentMode = .center
        highestScoreLab.zPosition = 35
        
        highest.text = String(UserDefaults.standard.integer(forKey: "UserDefaultsHighestScoreKey"))
        addChild(highest)
        highest.position = CGPoint(x: highestScoreLab.position.x, y: self.frame.height - 65)
        highest.fontColor = UIColor.white
        highest.fontSize = 16
        highest.fontName = "AmericanTypewriter"
        highest.verticalAlignmentMode = .center
        highest.horizontalAlignmentMode = .center
        highest.zPosition = 35
    }
    
    // ====================================================================================================
    
    func gameOver() {
        isGameOver = true // needs to set this first to prevent updating getting called again
        if isSoundEffectOn {
            run(fallingSound)
        }
        speed = 0
        gameSceneDelegate?.gameSceneGameEnded()
        isMusicOn = false
        isUserInteractionEnabled = false
        hotdog.speed = 0
    }
    
    //MARK: Collision Detection
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        func bodyHas(_ body: SKPhysicsBody, _ category: ContactCategory) -> Bool {
            return (body.categoryBitMask & category.rawValue) != 0
        }
        
        // Update landed state safely
        if let hBody = hotdog.physicsBody {
            let dy = hBody.velocity.dy
            isLanded = dy <= 1.0 && dy >= 0.0
        }
        
        // sidebounds
        if bodyHas(bodyA, .sidebounds) || bodyHas(bodyB, .sidebounds) {
            isLanded = true
#if DEBUG
            print("At ground")
#endif
        }
        
        // leftbound / rightbound bounce handling
        if bodyHas(bodyA, .leftbound) || bodyHas(bodyB, .leftbound) {
            hotdog.xScale *= hotdog.xScale > 0 ? 1 : -1
            hotdog.removeAction(forKey: "moveLeft")
            let moveRight = SKAction.moveBy(x: hotdogMoveVelocity, y: 0, duration: 1)
            let moveForever = SKAction.repeatForever(moveRight)
            hotdog.run(moveForever, withKey: "moveRight")
        } else if bodyHas(bodyA, .rightbound) || bodyHas(bodyB, .rightbound) {
            hotdog.xScale *= hotdog.xScale > 0 ? -1 : 1
            hotdog.removeAction(forKey: "moveRight")
            let moveLeft = SKAction.moveBy(x: -hotdogMoveVelocity, y: 0, duration: 1)
            let moveForever = SKAction.repeatForever(moveLeft)
            hotdog.run(moveForever, withKey: "moveLeft")
        }
        
        // path collision
        if bodyHas(bodyA, .path) || bodyHas(bodyB, .path) {
            let currPathBody = bodyHas(bodyA, .path) ? bodyA : bodyB
            if let currPath = currPathBody.node as? Path, let hBody = hotdog.physicsBody {
                let dy = hBody.velocity.dy
                if dy > 0 {
                    // going up: disable path collision
                    hBody.collisionBitMask = ContactCategory.sidebounds.rawValue | ContactCategory.rightbound.rawValue | ContactCategory.leftbound.rawValue
                } else {
                    // check if hotdog feet are on or above path
                    if (hotdog.position.y - hotdog.size.height / 2.0 >= currPath.position.y + currPath.size.height / 2 - 20) {
                        hBody.contactTestBitMask = ContactCategory.path.rawValue | ContactCategory.sauce.rawValue
                        hBody.collisionBitMask = ContactCategory.path.rawValue | ContactCategory.sidebounds.rawValue | ContactCategory.leftbound.rawValue | ContactCategory.rightbound.rawValue
                        if !currPath.isVisited {
                            score += 1
                            currPath.isVisited = true
                        }
                        isLanded = true
                    }
                }
            }
        }
        
        // sauce collision -> safer handling
        if (bodyHas(bodyA, .sauce) || bodyHas(bodyB, .sauce)) && !isGameOver {
            let sauceBody = bodyHas(bodyA, .sauce) ? bodyA : bodyB
            // remove the sauce node safely (node is already an optional SKNode)
            sauceBody.node?.removeFromParent()
#if DEBUG
            print("Got shot")
#endif
            gameOver()
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if pos.x < self.frame.size.width / 5.0 {
            if !hotdog.hasActions() {
                hotdog.run(hotdogRunForever, withKey: "hotdogRunForever")
            }
            hotdog.xScale *= hotdog.xScale > 0 ? -1 : 1
            hotdog.removeAction(forKey: "moveRight")
            let moveLeft = SKAction.moveBy(x: -hotdogMoveVelocity, y: 0, duration: 1)
            let moveForever = SKAction.repeatForever(moveLeft)
            hotdog.run(moveForever, withKey: "moveLeft")
        } else if pos.x > 4 * self.frame.size.width / 5.0 {
            if !hotdog.hasActions() {
                hotdog.run(hotdogRunForever, withKey: "hotdogRunForever")
            }
            hotdog.xScale *= hotdog.xScale > 0 ? 1 : -1
            hotdog.removeAction(forKey: "moveLeft")
            let moveRight = SKAction.moveBy(x: hotdogMoveVelocity, y: 0, duration: 1)
            let moveForever = SKAction.repeatForever(moveRight)
            hotdog.run(moveForever, withKey: "moveRight")
        } else {
            // middle area: begin charging jump (handled in touchesBegan)
            if !hotdog.hasActions() {
                hotdog.texture = hotdog.hotdogTexture
            }
            // Visual/audio feedback could be added here for charge start
        }
    }
    
    private func applyJump(for duration: TimeInterval) {
        // map hold duration to impulse [minJumpImpulse .. maxJumpImpulse]
        guard isLanded else { return }
        let clamped = min(duration, maxChargeDuration)
        let t = CGFloat(clamped / maxChargeDuration)
        let impulse = minJumpImpulse + t * (maxJumpImpulse - minJumpImpulse)
        let diff = CGVector(dx: 0, dy: impulse)
        hotdog.physicsBody?.applyImpulse(diff)
        if isSoundEffectOn {
            run(jumpSound)
        }
        isLanded = false
        
        // Start moving background if hotdog high enough
        if hotdog.position.y > self.frame.size.height / 2.0 && background.speed == 0 {
            initialBackground.speed = kGameSpeed
            for bg in backgrounds { bg.speed = kGameSpeed }
            for path in paths { path.speed = kGameSpeed }
            self.physicsBody?.categoryBitMask = ContactCategory.hotdog.rawValue
        }
        
        // Level-up tuning (keeps previous behavior)
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
            self.touchDown(atPoint: pos)
            // if in middle area, record start time for charging
            if pos.x >= self.frame.size.width / 5.0 && pos.x <= 4 * self.frame.size.width / 5.0 {
                touchStartTimes[ObjectIdentifier(t)] = t.timestamp
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let id = ObjectIdentifier(t)
            if let start = touchStartTimes[id] {
                let duration = t.timestamp - start
                applyJump(for: duration)
                touchStartTimes[id] = nil
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Clean up any pending charge state
        for t in touches { touchStartTimes[ObjectIdentifier(t)] = nil }
    }
}
