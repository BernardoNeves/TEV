import SpriteKit
import GameplayKit
import CoreGraphics

class BulletNode: SKSpriteNode {
    var bounceCount: Int = 1
}

class GameScene: SKScene, SKSceneDelegate {
    var player: SKSpriteNode!
    var lastUpdateTime: TimeInterval = 0
    var playerBullets: [SKSpriteNode] = []

    var invaders: [SKSpriteNode] = []
    var initialEnemyCount: Int = 5
    var enemyCount: Int = 0
    var enemyCountLabel: SKLabelNode!
    
    var moveDirection: CGFloat = 1.0
    var moveSpeed: CGVector = CGVector(dx: 75, dy: 25)
    
    var chosenPowerUp: String?
    
    var lastShotTime: TimeInterval = 0
    var rateOfFire: CGFloat = 1.0
    var bulletSpeed: Double = 1.0
    var bulletCount: Int = 1
    var bulletSize: Double = 1.0
    var bulletBounce: Int = 1
    var bulletSpread: Double = 1
    
    var wave: Int = 0
    
    func getStatValue(for powerUp: String) -> CGFloat? {
            switch powerUp {
            case "Rate of Fire":
                return CGFloat(rateOfFire)
            case "BulletSpeed":
                return CGFloat(bulletSpeed)
            case "BulletCount":
                return CGFloat(bulletCount)
            case "BulletSize":
                return CGFloat(bulletSize)
            case "BulletBounce":
                return CGFloat(bulletBounce)
            case "BulletSpread":
                return CGFloat(bulletSpread)
            default:
                return nil
            }
        }
    
    override init(size: CGSize) {
           super.init(size: size)
           setupScene()
       }
    override func didMove(to view: SKView) {
        wave+=1
        if wave%3==0{
            moveSpeed = CGVector(dx: moveSpeed.dx + 12.5 , dy: moveSpeed.dy)
        }
        clearScene()
        setupScene()
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setupScene() {
        setupPlayer()
        setupLabels()
        setupInvaders()
    }

    func clearScene() {
        player?.removeFromParent()
        enemyCountLabel?.removeFromParent()
        for invader in invaders {
            invader.removeFromParent()
        }
        invaders.removeAll()
    }

    func setupPlayer() {
        player = SKSpriteNode(color: .green, size: CGSize(width: 60, height: 60))
        player.position = CGPoint(x: frame.midX, y: frame.minY + 100)
        addChild(player)
    }

    func setupLabels() {
        // Set up the enemy count label
        enemyCountLabel = SKLabelNode()
        enemyCountLabel.fontSize = 200  // Large font size
        enemyCountLabel.fontColor = .lightGray  // Light color to blend with the background
        enemyCountLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        enemyCountLabel.zPosition = -1  // Place behind other nodes
        addChild(enemyCountLabel)
        updateEnemyCountLabel()
    }

    func updateEnemyCountLabel() {
        enemyCountLabel?.text = "\(wave)"
    }

    func setupInvaders() {
       enemyCount = 0
       let enemySize = CGSize(width: 40, height: 40)
       let horizontalSpacing: CGFloat = 60
       let verticalSpacing: CGFloat = 60

       // Calculate total width of all enemies and spacing
       let totalWidth = CGFloat(initialEnemyCount - 1) * horizontalSpacing + enemySize.width
       let startX = (frame.width - totalWidth) / 2  // Center the formation horizontally

       for j in 0..<wave {
           for i in 0..<initialEnemyCount {
               let invader = SKSpriteNode(color: .red, size: enemySize)
               invader.position = CGPoint(x: startX + CGFloat(i) * horizontalSpacing, y: frame.maxY + CGFloat(j) * verticalSpacing - 60)
               invaders.append(invader)
               addChild(invader)
               enemyCount += 1
           }
       }
       updateEnemyCountLabel()
   }
    
    func didChoosePowerUp(_ powerUp: String) {
        chosenPowerUp = powerUp
        switch powerUp {
        case "Rate of Fire":
            rateOfFire += 0.25
        case "BulletSpeed":
            bulletSpeed += 0.25
        case "BulletCount":
            bulletCount += 1
        case "BulletSize":
            bulletSize += 0.25
        case "BulletBounce":
            bulletBounce += 1
        case "BulletSpread":
            bulletSpread += 1
        default:
            break
        }
    }
    
        
    override func update(_ currentTime: TimeInterval) {
        if self.lastUpdateTime == 0 {
            self.lastUpdateTime = currentTime
        }

        let dt = currentTime - self.lastUpdateTime

        // Move Invaders
        var changeDirection = false
        for invader in invaders {
            invader.position.x += CGFloat(moveSpeed.dx * moveDirection * dt)
            if (invader.position.x > frame.maxX - invader.size.width / 2 || invader.position.x < frame.minX + invader.size.width / 2) {
                changeDirection = true
            }
        }

        if changeDirection {
            moveDirection *= -1
            for invader in invaders {
                invader.position.y -= moveSpeed.dy
                invader.position.x += CGFloat(moveSpeed.dx * moveDirection * dt)
            }
        }

        if currentTime - lastShotTime > 1 / rateOfFire {
            shootBullet()
            lastShotTime = currentTime
        }

        // Update the position of the player's bullets
        for bullet in playerBullets {
            guard let bulletNode = bullet as? BulletNode,
                  let velocity = bullet.userData?["velocity"] as? CGVector else {
                continue
            }

            bullet.position.x += velocity.dx * CGFloat(dt)
            bullet.position.y += velocity.dy * CGFloat(dt)

            // Check for bouncing off the screen edges
            if bullet.position.x <= frame.minX || bullet.position.x >= frame.maxX {
                bullet.userData?["velocity"] = CGVector(dx: -velocity.dx, dy: velocity.dy)
                bulletNode.bounceCount -= 1
            }

            if bullet.position.y <= frame.minY || bullet.position.y >= frame.maxY {
                bullet.userData?["velocity"] = CGVector(dx: velocity.dx, dy: -velocity.dy)
                bulletNode.bounceCount -= 1
            }

            // Remove bullet if bounce count reaches zero
            if bulletNode.bounceCount <= 0 {
                bullet.removeFromParent()
                playerBullets.removeAll { $0 == bullet }
            } else {
                // Check for collision with invaders
                for invader in invaders {
                    if bullet.frame.intersects(invader.frame) {
                        invader.removeFromParent()
                        invaders.removeAll { $0 == invader }
                        bullet.removeFromParent()
                        playerBullets.removeAll { $0 == bullet }
                        enemyCount -= 1
                        updateEnemyCountLabel()
                        checkForWin()
                        break
                    }
                }
            }
        }

        self.lastUpdateTime = currentTime
    }

    
    func shootBullet() {
        let bulletWidth: CGFloat = 10.0 * bulletSize
        let bulletHeight: CGFloat = 10.0 * bulletSize
        let spacing: CGFloat = 5.0
        let totalWidth = CGFloat(bulletCount - 1) * (bulletWidth + spacing)
        let spreadAngle: CGFloat = bulletSpread

        for i in 0..<bulletCount {
            let bullet = BulletNode(color: .yellow, size: CGSize(width: bulletWidth, height: bulletHeight))
            bullet.bounceCount = bulletBounce
            let offset = CGFloat(i) * (bulletWidth + spacing) - totalWidth / 2
            bullet.position = CGPoint(x: player.position.x + offset, y: player.position.y + player.size.height / 2 + bulletHeight / 2)

            // Calculate the angle for the bullet
            let angleOffset = (CGFloat(i) - CGFloat(bulletCount - 1) / 2) * spreadAngle
            let angleInRadians = angleOffset * (.pi / 180)

            // Apply the angle to the bullet's velocity
            let bulletSpeed: CGFloat = 1000.0 * bulletSpeed
            let velocity = CGVector(dx: bulletSpeed * sin(angleInRadians), dy: bulletSpeed * cos(angleInRadians))
            bullet.userData = [
                "velocity": velocity
            ]

            addChild(bullet)
            playerBullets.append(bullet)
        }
    }


    
    func checkForWin() {
        if enemyCount == 0 {
            showNextLevelScreen()
        }
    }
    
    func showNextLevelScreen() {
        let powerUpChoiceScene = PowerUpChoiceScene(size: size)
        powerUpChoiceScene.gameScene = self
        powerUpChoiceScene.scaleMode = scaleMode
        let transition = SKTransition.fade(withDuration: 1.0)
        view?.presentScene(powerUpChoiceScene, transition: transition)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            player.position.x = location.x
        }
    }
        
}

func lerpFloat(start: CGFloat, end: CGFloat, t: CGFloat) -> CGFloat {
    return start + (end - start) * t
}

extension CGPoint {
    static func lerp(start: CGPoint, end: CGPoint, t: CGFloat) -> CGPoint {
        let x = lerpFloat(start: start.x, end: end.x, t: t)
        let y = lerpFloat(start: start.y, end: end.y, t: t)
        return CGPoint(x: x, y: y)
    }
}
