//
//  GameScene.swift
//  HotdogUp
//
//  Created by Cathy Oun on 5/21/17.
//  Copyright © 2017 Cathy Oun. All rights reserved.
//

import SpriteKit
import GameplayKit
import SnapKit
import AVFoundation

protocol GameSceneDelegate: class {
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
    
    var scoreLabel = UILabel()
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
            scoreLabel.text = String(score)
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
        
//        let longPress = UILongPressGestureRecognizer(target: self,
//                                                     action: #selector(springJump(longPress:)))
//        self.view?.addGestureRecognizer(longPress)
    }
    
//    @objc func springJump(longPress: UILongPressGestureRecognizer) {
//        switch longPress.state {
//        case .began:
//            timer = Timer.scheduledTimer(timeInterval: 0.2,
//                                         target: self,
//                                         selector: #selector(incrementTimer),
//                                         userInfo: nil,
//                                         repeats: true)
//            print("begin")
//            break
//        case .ended:
//            print("end")
//            timer.invalidate()
//            let pos = longPress.location(in: self.view)
//            jump(pos: pos)
//            timeCounter = kMinJumpHeight
//            break
//        default:
//            break
//        }
//    }
    
//    @objc func incrementTimer() {
//        timeCounter += kJumpIntensity
//        print(timeCounter)
//    }
    
    
    func resetGameScene() {
        removeAllChildren()
        paths.removeAll()
        stations.removeAll()
        
        setupPaths()
        setupHighestScoreLabel()
        createHotdog()
        createBackground()
        createStation()
//        createHealth()
        
        score = 0
        reuseCount = 0
        scoreLabel.text = "0"
        
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
        

        hotdog = Hotdog(hotdogType: Hotdog.HotdogType(rawValue: UserDefaults.standard.integer(forKey: "UserDefaultsSelectCharacterKey"))!)
                
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
        self.view?.addSubview(scoreLabel)
        scoreLabel.text = "0"
        scoreLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view!)
            make.top.equalTo(30)
        }
        scoreLabel.textColor = UIColor.white
        scoreLabel.font = UIFont.init(name: "MarkerFelt-Wide", size: 50)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let body = hotdog.physicsBody {
            let dy = body.velocity.dy
            if dy > 0 && !isLanded {
                // Prevent collisions if the hotdog is jumping -> no pathCategory
                body.collisionBitMask = ContactCategory.sidebounds.rawValue | ContactCategory.rightbound.rawValue | ContactCategory.leftbound.rawValue
            }
            reusePath()
            if hotdog.position.y < -100 && !isGameOver {
                gameOver()
            }
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
            firstPath = paths.last!
            var x = p_randomPoint(min: Int(firstPath.size.width / 2.0),
                                  max: Int(self.frame.size.width - firstPath.size.width))
            
            // if the distance between two paths (center to center) is greater than 1.5 paths
            while abs(Int(lastPath.position.x) - x) > Int(1.65 * firstPath.size.width) {
                x = p_randomPoint(min: Int(firstPath.size.width / 2.0),
                                  max: Int(self.frame.size.width - firstPath.size.width))
            }
            
            let y = Int(firstPath.frame.origin.y) + kMinJumpHeight + 30
            let path = Path(position: CGPoint(x: x, y: y))
            lastPath = path
            path.tag = firstPath.tag + 1
            paths.append(path)
        }
    }
    
    private func p_randomPoint(min: Int, max: Int) -> Int {
        let rand = Int(arc4random_uniform(UInt32(max))) + min
        return rand
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
                    path.type = PathType(rawValue: level)!
                    
                    if level >= 2 && level < 5 {
                        minLeft = Int(stations[0].size.width)
                        if path.tag >= 3 {
                            stations.forEach({ (station) in
                                station.isHidden = false
                                station.stationType = StationType(rawValue: level)!
                            })
                        }
                    }
                }

                
                
                var x = p_randomPoint(min: Int(path.size.width / 2.0),
                                      max: Int(self.frame.size.width - path.size.width))
                
                // if the distance between two paths (center to center) is greater than 1.8 paths
                while abs(Int(paths.last!.position.x) - x) > Int(1.65 * path.size.width) || x <= minLeft {
                    x = p_randomPoint(min: Int(path.size.width / 2.0),
                                      max: Int(self.frame.size.width - path.size.width))
                }
                let y = Int(paths.last!.frame.origin.y) + kMinJumpHeight + 30
                path.position = CGPoint(x: x, y: y)
                paths.remove(at: paths.index(of: path)!) // remove the old path
                                paths.append(path) // append new path
            }
        }
    }
    
    func createStation() {
        // generates
        for i in 0...2 {
            let station = Station()
            let y = Int((self.view?.bounds.height)! / 4.0) * (i + 1)
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
    
//    func createHealth() {
//        for _ in 0...2 {
//            let texture = SKTexture(imageNamed: "")
//            let health = SKSpriteNode(texture: texture)
//            addChild(health)
//            healths.append(health)
//            health.position = CGPoint(x: highest.position.x, y: highest.position.y - 40)
//        }
//    }
    
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
        isLanded = (hotdog.physicsBody?.velocity.dy)! <= 1.0 && (hotdog.physicsBody?.velocity.dy)! >= 0.0
        if bodyA.categoryBitMask == ContactCategory.sidebounds.rawValue || bodyB.categoryBitMask == ContactCategory.sidebounds.rawValue {
            isLanded = true
            print("At ground")
        }
        if bodyA.categoryBitMask == ContactCategory.leftbound.rawValue || bodyB.categoryBitMask == ContactCategory.leftbound.rawValue {
            hotdog.xScale *= hotdog.xScale > 0 ? 1 : -1
            hotdog.removeAction(forKey: "moveLeft")
            let moveRight = SKAction.moveBy(x: hotdogMoveVelocity, y: 0, duration: 1)
            let moveForever = SKAction.repeatForever(moveRight)
            hotdog.run(moveForever, withKey: "moveRight")
        } else if bodyA.categoryBitMask == ContactCategory.rightbound.rawValue || bodyB.categoryBitMask == ContactCategory.rightbound.rawValue {
            hotdog.xScale *= hotdog.xScale > 0 ? -1 : 1
            hotdog.removeAction(forKey: "moveRight")
            let moveLeft = SKAction.moveBy(x: -hotdogMoveVelocity, y: 0, duration: 1)
            let moveForever = SKAction.repeatForever(moveLeft)
            hotdog.run(moveForever, withKey: "moveLeft")
        }
        if bodyA.categoryBitMask == ContactCategory.path.rawValue || bodyB.categoryBitMask == ContactCategory.path.rawValue {
            let currPath = bodyB.categoryBitMask == ContactCategory.path.rawValue ? bodyB.node as! Path : bodyA.node as! Path
            let dy = hotdog.physicsBody!.velocity.dy
            if dy > 0 {
                // go up
                hotdog.physicsBody?.collisionBitMask = ContactCategory.sidebounds.rawValue | ContactCategory.rightbound.rawValue | ContactCategory.leftbound.rawValue
            } else {
                // if current hotdog position is greater than current path
                if (hotdog.position.y - hotdog.size.height / 2.0 >= currPath.position.y + currPath.size.height / 2 - 20) {
                    hotdog.physicsBody?.contactTestBitMask = ContactCategory.path.rawValue | ContactCategory.sauce.rawValue
                    hotdog.physicsBody?.collisionBitMask = ContactCategory.path.rawValue | ContactCategory.sidebounds.rawValue | ContactCategory.leftbound.rawValue | ContactCategory.rightbound.rawValue
                    
                    if !currPath.isVisited {
                        score += 1
                        currPath.isVisited = true
                    }
                    isLanded = true
                }
            }
        }
        
        if bodyA.categoryBitMask == ContactCategory.sauce.rawValue || bodyB.categoryBitMask == ContactCategory.sauce.rawValue && !isGameOver {
            // update hotdog texture
            print("Got shot")
            bodyA.isResting = true
//            hotdog.shotCount += 1
//            bodyA.velocity.dx = 0
//            if hotdog.shotCount >= 3 {
                gameOver()
//            }
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
            // middle
            if !hotdog.hasActions() {
                hotdog.texture = hotdog.hotdogTexture
            }
            let diff = CGVector(dx: 0, dy: CGFloat(kMinJumpHeight + 5))
            if isLanded {
                hotdog.physicsBody?.applyImpulse(diff)
                if isSoundEffectOn {
                    run(jumpSound)
                }
            }
            isLanded = false

            // Start moving background
            if hotdog.position.y > self.frame.size.height / 2.0 && background.speed == 0 {
                // move the background up
                initialBackground.speed = kGameSpeed
                for bg in backgrounds {
                    bg.speed = kGameSpeed
                }
                for path in paths {
                    path.speed = kGameSpeed
                }
                self.physicsBody?.categoryBitMask = ContactCategory.hotdog.rawValue
            }
            
            if score % kLevel == 0 && score > 0 {
                hotdog.physicsBody?.mass += 0.001
                for bg in backgrounds {
                    bg.speed += kSpeedIncrement
                }
                hotdogMoveVelocity += kHotdogMoveVelocityIncrement
                for path in paths {
                    path.speed += kSpeedIncrement
                }
            }
        }
    }

//    func touchMoved(toPoint pos : CGPoint) {
//    }
//    
//    func touchUp(atPoint pos : CGPoint) {
//    }
//    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchDown(atPoint: t.location(in: self))
        }
    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches {
//            self.touchMoved(toPoint: t.location(in: self))
//        }
//    }
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
//    
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
}
