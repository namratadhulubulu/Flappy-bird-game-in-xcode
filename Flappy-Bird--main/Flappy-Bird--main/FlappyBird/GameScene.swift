import SpriteKit
import GameplayKit
import AVFoundation // Import AVFoundation

var isAlive = true
var score = 0
var highestScore = 0
var upgravity = CGVector(dx: 0, dy: 10)
var downgravity = CGVector(dx: 0, dy: -10)

struct PhysicsCategory {
    static let player: UInt32 = 1
    static let ground: UInt32 = 2
    static let pipe: UInt32 = 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var textureAtLas = SKTextureAtlas(named: "bird")
    var textures = [SKTexture]()
    
    var player: SKSpriteNode!
    var groundpipe: SKSpriteNode!
    var roofpipe: SKSpriteNode!
    
    var gameOverLabel: SKLabelNode!
    var finalScoreLabel: SKLabelNode!
    var highestScoreLabel: SKLabelNode!
    var restartLabel: SKLabelNode!
    
    var audioPlayer: AVAudioPlayer? // Declare audio player

    override func didMove(to view: SKView) {
        setupGame()
    }
    
    func setupGame() {
        isAlive = true
        score = 0
        
        physicsWorld.contactDelegate = self
        
        let backgroundImage = SKSpriteNode(imageNamed: "flappy-bird-background-11")
        backgroundImage.size = CGSize(width: frame.size.width, height: frame.size.height)
        backgroundImage.position = CGPoint(x: frame.midX, y: frame.midY)
        backgroundImage.zPosition = -1
        addChild(backgroundImage)
        
        let landImage = SKSpriteNode(imageNamed: "land")
        landImage.size = CGSize(width: frame.size.width, height: 200)
        landImage.position = CGPoint(x: frame.midX, y: frame.midY - 500)
        landImage.physicsBody = SKPhysicsBody(rectangleOf: landImage.size)
        landImage.physicsBody?.isDynamic = false
        landImage.physicsBody?.categoryBitMask = PhysicsCategory.ground
        landImage.physicsBody?.contactTestBitMask = PhysicsCategory.player
        landImage.name = "ground"
        addChild(landImage)

        for i in 1..<textureAtLas.textureNames.count {
            let name = "bird-0\(i).png"
            textures.append(SKTexture(imageNamed: name))
        }
        
        SpawnPlayer()
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(RandomPipes), userInfo: nil, repeats: true)
    }
    
    func SpawnGroundPipe() {
        groundpipe = SKSpriteNode(imageNamed: "PipeUp")
        groundpipe.position = CGPoint(x: frame.midX + 300, y: frame.midY - 220)
        groundpipe.size = CGSize(width: 80, height: Int.random(in: 315...450))
        groundpipe.physicsBody = SKPhysicsBody(rectangleOf: groundpipe.size)
        groundpipe.physicsBody?.categoryBitMask = PhysicsCategory.pipe
        groundpipe.physicsBody?.contactTestBitMask = PhysicsCategory.player
        groundpipe.physicsBody?.isDynamic = false
        groundpipe.name = "pipe"
        addChild(groundpipe)
        
        let moveToLeft = SKAction.moveTo(x: -1000, duration: 1.5)
        let wait = SKAction.wait(forDuration: 2.0)
        let destroy = SKAction.run {
            self.groundpipe.removeFromParent()
        }
        
        groundpipe.run(SKAction.sequence([moveToLeft, wait, destroy]))
    }
    
    func SpawnRoofPipe() {
        roofpipe = SKSpriteNode(imageNamed: "PipeDown")
        roofpipe.position = CGPoint(x: frame.midX + 400, y: frame.midY + 400)
        roofpipe.size = CGSize(width: 80, height: Int.random(in: 315...500))
        roofpipe.physicsBody = SKPhysicsBody(rectangleOf: roofpipe.size)
        roofpipe.physicsBody?.categoryBitMask = PhysicsCategory.pipe
        roofpipe.physicsBody?.contactTestBitMask = PhysicsCategory.player
        roofpipe.physicsBody?.isDynamic = false
        roofpipe.name = "pipe"
        addChild(roofpipe)
        
        let moveToLeft = SKAction.moveTo(x: -1000, duration: 1.5)
        let wait = SKAction.wait(forDuration: 2.0)
        let destroy = SKAction.run {
            self.roofpipe.removeFromParent()
        }
        
        roofpipe.run(SKAction.sequence([moveToLeft, wait, destroy]))
    }
    
    func SpawnPlayer() {
        player = SKSpriteNode(imageNamed: "bird-1")
        player.size = CGSize(width: 80, height: 80)
        player.position = CGPoint(x: frame.midX - 200, y: frame.midY)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.pipe | PhysicsCategory.ground // Contact test with ground
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = true
        player.name = "player"
        addChild(player)
        
        player.run(SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: 0.1)))
    }
    
    @objc func RandomPipes() {
        if isAlive {
            let i = Int.random(in: 0...1)
            score += 1
            
            if i == 0 {
                SpawnRoofPipe()
            } else {
                SpawnGroundPipe()
            }
        } else {
            showGameOver()
        }
    }
    
    func showGameOver() {
        if score > highestScore {
            highestScore = score
        }
        
        gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName = "Futura"
        gameOverLabel.fontSize = 60
        gameOverLabel.fontColor = UIColor.white
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        addChild(gameOverLabel)

        finalScoreLabel = SKLabelNode(text: "Final Score: \(score)")
        finalScoreLabel.fontName = "Futura"
        finalScoreLabel.fontSize = 40
        finalScoreLabel.fontColor = UIColor.white
        finalScoreLabel.position = CGPoint(x: frame.midX, y: frame.midY);
        addChild(finalScoreLabel)

        highestScoreLabel = SKLabelNode(text: "Highest Score: \(highestScore)")
        highestScoreLabel.fontName = "Futura"
        highestScoreLabel.fontSize = 40
        highestScoreLabel.fontColor = UIColor.white
        highestScoreLabel.position = CGPoint(x: frame.midX, y: frame.midY - 50);
        addChild(highestScoreLabel)

        restartLabel = SKLabelNode(text: "Restart")
        restartLabel.fontName = "Futura"
        restartLabel.fontSize = 40
        restartLabel.fontColor = UIColor.red
        restartLabel.position = CGPoint(x: frame.midX, y: frame.midY - 100);
        restartLabel.name = "restartLabel"
        addChild(restartLabel)
        
        isAlive = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isAlive {
            physicsWorld.gravity = upgravity
        } else {
            if let touch = touches.first {
                let location = touch.location(in: self)
                let touchedNode = self.atPoint(location)
                
                if touchedNode.name == "restartLabel" {
                    resetGame()
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isAlive {
            physicsWorld.gravity = downgravity
        }
    }
    
    func resetGame() {
        gameOverLabel?.removeFromParent()
        finalScoreLabel?.removeFromParent()
        highestScoreLabel?.removeFromParent()
        restartLabel?.removeFromParent()
        
        setupGame()
    }
    
    func playCollisionSound() {
        guard let soundURL = Bundle.main.url(forResource: "sfx_die", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Error loading sound file")
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if (bodyA.node?.name == "player" && bodyB.node?.name == "pipe") || (bodyB.node?.name == "player" && bodyA.node?.name == "pipe") {
            isAlive = false
            player.removeFromParent()
            playCollisionSound() // Play collision sound here
        } else if (bodyA.node?.name == "player" && bodyB.node?.name == "ground") || (bodyB.node?.name == "player" && bodyA.node?.name == "ground") {
            isAlive = false
            player.removeFromParent()
            playCollisionSound() // Play collision sound here
        }
    }
}
