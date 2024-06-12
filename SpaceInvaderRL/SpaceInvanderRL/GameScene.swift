import SpriteKit
import GameplayKit
import CoreGraphics
import AVFoundation

class BulletNode: SKSpriteNode {
    var bounceCount: Int = 1
}

class EnemyBulletNode: SKSpriteNode {
    var velocity: CGVector!
}

class GameScene: SKScene, SKSceneDelegate {
    var player: SKSpriteNode!
    var lastUpdateTime: TimeInterval = 0
    var playerBullets: [SKSpriteNode] = []
    var enemyBullets: [EnemyBulletNode] = []

    var invaders: [SKSpriteNode] = []
    var initialEnemyCount: Int = 5
    var enemyCount: Int = 0
    var waveLabel: SKLabelNode!
    
    var moveDirection: CGFloat = 1.0
    var moveSpeed: CGVector = CGVector(dx: 100, dy: 40)
    
    var chosenPowerUp: String?
    
    var lastShotTime: TimeInterval = 0
    var rateOfFire: CGFloat = 1.0
    var bulletSpeed: Double = 1.0
    var bulletCount: Int = 1
    var bulletSize: Double = 1.0
    var bulletBounce: Int = 1
    var bulletSpread: Double = 1
    
    var wave: Int = 0
    
    var drawerButton: SKSpriteNode!
    var drawer: SKShapeNode!
    var drawerIsOpen = false
    var pauseButton: SKSpriteNode!
    
    var background: SKNode!
    var currentBackgroundIndex: Int = 0
    var backgroundTextureNames = ["Background1", "Background2", "Background3", "Background4", "Background5", "Background6", "Background7", "Background8", "Background9"]
    
    var highestRateOfFire: CGFloat {
        get { return UserDefaults.standard.value(forKey: "highestRateOfFire") as? CGFloat ?? 1.0 }
        set { UserDefaults.standard.set(newValue, forKey: "highestRateOfFire") }
    }
    
    var highestBulletSpeed: CGFloat {
        get { return UserDefaults.standard.value(forKey: "highestBulletSpeed") as? CGFloat ?? 1.0 }
        set { UserDefaults.standard.set(newValue, forKey: "highestBulletSpeed") }
    }

    var highestBulletCount: Int {
        get { return UserDefaults.standard.value(forKey: "highestBulletCount") as? Int ?? 1 }
        set { UserDefaults.standard.set(newValue, forKey: "highestBulletCount") }
    }

    var highestBulletSize: CGFloat {
        get { return UserDefaults.standard.value(forKey: "highestBulletSize") as? CGFloat ?? 1.0 }
        set { UserDefaults.standard.set(newValue, forKey: "highestBulletSize") }
    }

    var highestBulletBounce: Int {
        get { return UserDefaults.standard.value(forKey: "highestBulletBounce") as? Int ?? 1 }
        set { UserDefaults.standard.set(newValue, forKey: "highestBulletBounce") }
    }

    var highestBulletSpread: CGFloat {
        get { return UserDefaults.standard.value(forKey: "highestBulletSpread") as? CGFloat ?? 1.0 }
        set { UserDefaults.standard.set(newValue, forKey: "highestBulletSpread") }
    }
    
    var highestWave: Int {
        get { return UserDefaults.standard.value(forKey: "highestWave") as? Int ?? 0 }
        set { UserDefaults.standard.set(newValue, forKey: "highestWave") }
    }

    func checkAndSaveHighestStats() {
        if rateOfFire > highestRateOfFire { highestRateOfFire = rateOfFire }
        if bulletSpeed > highestBulletSpeed { highestBulletSpeed = bulletSpeed }
        if bulletCount > highestBulletCount { highestBulletCount = bulletCount }
        if bulletSize > highestBulletSize { highestBulletSize = bulletSize }
        if bulletBounce > highestBulletBounce { highestBulletBounce = bulletBounce }
        if bulletSpread > highestBulletSpread { highestBulletSpread = bulletSpread }
        if wave > highestWave { highestWave = wave }
    }
    

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
    
    var backgroundMusicPlayer: AVAudioPlayer?
    
    func setupBackgroundMusic() {
        let music = SKAudioNode(fileNamed: "SpaceInvaders.mp3")
        music.autoplayLooped = true
        addChild(music)
    }
    
    func loadParticleEffect(named name: String) -> SKEmitterNode? {
        return SKEmitterNode(fileNamed: name)
    }
    
    override func didMove(to view: SKView) {
        wave += 1
        if wave % 3 == 0 {
            moveSpeed = CGVector(dx: moveSpeed.dx + 12.5, dy: moveSpeed.dy)
        }
        clearScene()
        setupScene()
        
        currentBackgroundIndex = (wave - 1) % backgroundTextureNames.count
        setupBackground()
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupScene() {
        setupBackground()
        setupPlayer()
        setupLabels()
        setupInvaders()
        setupDrawerAndButton()
        setupPauseButton(name: "Pause")
        setupBackgroundMusic()
    }

    func clearScene() {
        player?.removeFromParent()
        waveLabel?.removeFromParent()

        for invader in invaders {
            invader.removeFromParent()
        }
        for bullet in playerBullets {
            bullet.removeFromParent()
        }
        for bullet in enemyBullets {
            bullet.removeFromParent()
        }
        invaders.removeAll()
        playerBullets.removeAll()
        enemyBullets.removeAll()
    }

    func setupPlayer() {
        let playerTexture = SKTexture(imageNamed: "Player")
        player = SKSpriteNode(texture: playerTexture)
        player.size = CGSize(width: 60, height: 26)
        player.position = CGPoint(x: frame.midX, y: frame.minY + 100)
        addChild(player)
    }

    func setupLabels() {
        waveLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        waveLabel.fontSize = 250
        waveLabel.fontColor = .white
        waveLabel.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        waveLabel.zPosition = -1
        waveLabel.alpha = 0.5
        waveLabel.text = "\(wave)"
        addChild(waveLabel)
        
        updateStatsLabels()
    }

    func setupInvaders() {
        enemyCount = 0
        let enemySize = CGSize(width: 40, height: 40)
        let horizontalSpacing: CGFloat = 60
        let verticalSpacing: CGFloat = 60

        // Calculate total width of all enemies and spacing
        let totalWidth = CGFloat(initialEnemyCount - 1) * horizontalSpacing + enemySize.width
        let startX = (frame.width - totalWidth) / 2  // Center the formation horizontally

        let invaderTextureA1 = SKTexture(imageNamed: "InvaderA1")
        let invaderTextureA2 = SKTexture(imageNamed: "InvaderA2")
        let invaderTextureB1 = SKTexture(imageNamed: "InvaderB1")
        let invaderTextureB2 = SKTexture(imageNamed: "InvaderB2")
        let invaderTextureC1 = SKTexture(imageNamed: "InvaderC1")
        let invaderTextureC2 = SKTexture(imageNamed: "InvaderC2")

        for j in 0..<wave {
            for i in 0..<initialEnemyCount {
                // Determine the texture based on the row number
                let invaderTexture1: SKTexture
                let invaderTexture2: SKTexture
                switch j % 3 {
                case 0:
                    invaderTexture1 = invaderTextureA1
                    invaderTexture2 = invaderTextureA2
                case 1:
                    invaderTexture1 = invaderTextureB1
                    invaderTexture2 = invaderTextureB2
                case 2:
                    invaderTexture1 = invaderTextureC1
                    invaderTexture2 = invaderTextureC2
                default:
                    invaderTexture1 = invaderTextureA1
                    invaderTexture2 = invaderTextureA2
                }
                
                let invader = SKSpriteNode(texture: invaderTexture1)
                invader.size = enemySize
                invader.position = CGPoint(x: startX + CGFloat(i) * horizontalSpacing, y: frame.maxY + CGFloat(j) * verticalSpacing - 60)

                let animationAction = SKAction.animate(with: [invaderTexture1, invaderTexture2], timePerFrame: 0.5)
                let repeatAction = SKAction.repeatForever(animationAction)
                invader.run(repeatAction)

                invaders.append(invader)
                addChild(invader)
                enemyCount += 1

                // Schedule enemy shooting
                let waitAction = SKAction.wait(forDuration: Double.random(in: 1...5))
                let shootAction = SKAction.run {
                    self.shootEnemyBullet(from: invader)
                }
                let sequence = SKAction.sequence([waitAction, shootAction])
                invader.run(SKAction.repeatForever(sequence))
            }
        }
    }
    
    func setupBackground() {
        if background != nil {
            background.removeFromParent()
        }
        
        // Get the current background texture name
        let textureName = backgroundTextureNames[currentBackgroundIndex]
        let texture = SKTexture(imageNamed: textureName)
        
        // Create and add the tiling background node
        background = SKNode()
        background.zPosition = -10
        
        let textureSize = CGSize(width: texture.size().width * 4, height: texture.size().height * 4)
        let columns = Int(ceil(frame.width / textureSize.width)) + 1
        let rows = Int(ceil(frame.height / textureSize.height)) + 1
        
        for row in 0..<rows {
            for column in 0..<columns {
                let tileNode = SKSpriteNode(texture: texture)
                tileNode.size = textureSize
                tileNode.position = CGPoint(x: CGFloat(column) * textureSize.width, y: CGFloat(row) * textureSize.height)
                tileNode.anchorPoint = .zero
                background.addChild(tileNode)
            }
        }
        
        addChild(background)
    }

    func shootEnemyBullet(from invader: SKSpriteNode) {
        if invader.position.y >= frame.maxY - 150 {
            return
        }
        // Load bullet textures
        let bulletTexture1 = SKTexture(imageNamed: "Ray1")
        let bulletTexture2 = SKTexture(imageNamed: "Ray2")
        let bulletTexture3 = SKTexture(imageNamed: "Ray3")
        let bulletTexture4 = SKTexture(imageNamed: "Ray4")

        let bullet = EnemyBulletNode(texture: bulletTexture1)
        bullet.size = CGSize(width: 20, height: 20)
        bullet.position = CGPoint(x: invader.position.x, y: invader.position.y - invader.size.height)

        // Create animation action for the bullet
        let animationAction = SKAction.animate(with: [bulletTexture1, bulletTexture2, bulletTexture3, bulletTexture4], timePerFrame: 0.1)
        let repeatAction = SKAction.repeatForever(animationAction)
        bullet.run(repeatAction)

        // Apply the velocity to the bullet
        bullet.velocity = CGVector(dx: 0, dy: -200)

        addChild(bullet)
        enemyBullets.append(bullet)
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
        if self.isPaused {
            return
        }
        if self.lastUpdateTime == 0 {
            self.lastUpdateTime = currentTime
        }

        let dt = currentTime - self.lastUpdateTime

        var changeDirection = false
        for invader in invaders {
            invader.position.x += CGFloat(moveSpeed.dx * moveDirection * dt)
            if (invader.position.x > frame.maxX - invader.size.width / 2 || invader.position.x < frame.minX + invader.size.width / 2) {
                changeDirection = true
            }
            if (invader.position.y <= player.position.y + player.size.height / 2 + invader.size.height / 2) {
                death()
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

        for bullet in playerBullets {
            guard let bulletNode = bullet as? BulletNode,
                  let velocity = bullet.userData?["velocity"] as? CGVector else {
                continue
            }

            bullet.position.x += velocity.dx * CGFloat(dt)
            bullet.position.y += velocity.dy * CGFloat(dt)

            if bullet.position.x <= frame.minX || bullet.position.x >= frame.maxX {
                bullet.userData?["velocity"] = CGVector(dx: -velocity.dx, dy: velocity.dy)
                bulletNode.bounceCount -= 1
            }

            if bullet.position.y <= frame.minY || bullet.position.y >= frame.maxY {
                bullet.userData?["velocity"] = CGVector(dx: velocity.dx, dy: -velocity.dy)
                bulletNode.bounceCount -= 1
            }

            if bulletNode.bounceCount <= 0 {
                bullet.removeFromParent()
                playerBullets.removeAll { $0 == bullet }
            } else {
                if bullet.frame.intersects(player.frame) {
                    // Handle player hit
                }
                for invader in invaders {
                    if bullet.frame.intersects(invader.frame) {
                        // Add particle effect when the invader is destroyed
                        if let explosion = loadParticleEffect(named: "EnemyExplosion") {
                            explosion.position = invader.position
                            addChild(explosion)
                            explosion.run(SKAction.sequence([SKAction.wait(forDuration: 0.1), SKAction.removeFromParent()]))
                        }

                        invader.removeFromParent()
                        invaders.removeAll { $0 == invader }
                        bullet.removeFromParent()
                        playerBullets.removeAll { $0 == bullet }
                        enemyCount -= 1
                        checkForWin()
                        break
                    }
                }
            }
        }

        for bullet in enemyBullets {
            bullet.position.x += bullet.velocity.dx * CGFloat(dt)
            bullet.position.y += bullet.velocity.dy * CGFloat(dt)

            if bullet.position.y <= frame.minY {
                bullet.removeFromParent()
                enemyBullets.removeAll { $0 == bullet }
            } else {
                if bullet.frame.intersects(player.frame) {
                    death()
                    break
                }
                for invader in invaders {
                    if bullet.frame.intersects(invader.frame) {
                        bullet.removeFromParent()
                        enemyBullets.removeAll { $0 == bullet }
                        break
                    }
                }
            }
        }

        self.lastUpdateTime = currentTime
    }

    func shootBullet() {
        let bulletWidth: CGFloat = 15.0 * bulletSize
        let bulletHeight: CGFloat = 15.0 * bulletSize
        let spacing: CGFloat = 5.0
        let totalWidth = CGFloat(bulletCount - 1) * (bulletWidth + spacing)
        let spreadAngle: CGFloat = bulletSpread

        // Load bullet textures
        let bulletTexture1 = SKTexture(imageNamed: "Bullet1")
        let bulletTexture2 = SKTexture(imageNamed: "Bullet2")
        let bulletTexture3 = SKTexture(imageNamed: "Bullet3")
        let bulletTexture4 = SKTexture(imageNamed: "Bullet4")

        for i in 0..<bulletCount {
            let bullet = BulletNode(texture: bulletTexture1)
            bullet.size = CGSize(width: bulletWidth, height: bulletHeight)
            bullet.bounceCount = bulletBounce
            let offset = CGFloat(i) * (bulletWidth + spacing) - totalWidth / 2
            bullet.position = CGPoint(x: player.position.x + offset, y: player.position.y + player.size.height / 2 + bulletHeight / 2)

            // Create animation action for the bullet
            let animationAction = SKAction.animate(with: [bulletTexture1, bulletTexture2, bulletTexture3, bulletTexture4], timePerFrame: 0.1)
            let repeatAction = SKAction.repeatForever(animationAction)
            bullet.run(repeatAction)

            // Calculate the angle for the bullet
            var angleOffset = (CGFloat(i) - CGFloat(bulletCount - 1) / 2) * spreadAngle
            angleOffset = max(min(angleOffset, 80), -80)
            let angleInRadians = angleOffset * (.pi / 180)

            // Apply the angle to the bullet's velocity
            let bulletSpeed: CGFloat = 500.0 * bulletSpeed
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
    
    func death() {
        checkAndSaveHighestStats()
        let menuScene = MainMenuScene(size: size)
        let transition = SKTransition.fade(withDuration: 1.0)
        view?.presentScene(menuScene, transition: transition)
    }
    
    func showNextLevelScreen() {
        let powerUpChoiceScene = PowerUpChoiceScene(size: size)
        powerUpChoiceScene.gameScene = self
        powerUpChoiceScene.scaleMode = scaleMode
        let transition = SKTransition.fade(withDuration: 1.0)
        view?.presentScene(powerUpChoiceScene, transition: transition)
        checkAndSaveHighestStats()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isPaused {
            return
        }
        if let touch = touches.first {
            let location = touch.location(in: self)
            player.position.x = location.x
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = self.atPoint(location)
        
        if touchedNode.name == "pauseButton" {
            togglePause()
        }
        toggleDrawer(state: touchedNode.name == "drawerButton")
    }

    func updateStatsLabels() {
        if let rateOfFireLabel = drawer?.childNode(withName: "rateOfFireLabel") as? SKLabelNode {
            rateOfFireLabel.text = "Rate of Fire: \(rateOfFire)"
        }
        
        if let bulletSpeedLabel = drawer?.childNode(withName: "bulletSpeedLabel") as? SKLabelNode {
            bulletSpeedLabel.text = "Bullet Speed: \(bulletSpeed)"
        }
        
        if let bulletCountLabel = drawer?.childNode(withName: "bulletCountLabel") as? SKLabelNode {
            bulletCountLabel.text = "Bullet Count: \(bulletCount)"
        }
        
        if let bulletSizeLabel = drawer?.childNode(withName: "bulletSizeLabel") as? SKLabelNode {
            bulletSizeLabel.text = "Bullet Size: \(bulletSize)"
        }
        
        if let bulletBounceLabel = drawer?.childNode(withName: "bulletBounceLabel") as? SKLabelNode {
            bulletBounceLabel.text = "Bullet Bounce: \(bulletBounce)"
        }
        
        if let bulletSpreadLabel = drawer?.childNode(withName: "bulletSpreadLabel") as? SKLabelNode {
            bulletSpreadLabel.text = "Bullet Spread: \(bulletSpread)"
        }
    }

    func setupPauseButton(name: String) {
        if pauseButton != nil {
            pauseButton.removeFromParent()
        }
        pauseButton = SKSpriteNode(texture: SKTexture(imageNamed: name))
        pauseButton.size = CGSize(width: 25, height: 25)
        pauseButton.position = CGPoint(x: frame.maxX - 35, y: frame.maxY - 35)
        pauseButton.name = "pauseButton"
        addChild(pauseButton)
    }

    func togglePause() {
        self.isPaused.toggle()

        if self.isPaused {
            setupPauseButton(name: "Play")
        } else {
            self.lastUpdateTime = 0
            setupPauseButton(name: "Pause")
        }
    }
    
    func toggleDrawer(state: Bool) {
        let moveAction: SKAction
        
        if drawerIsOpen && !state {
            moveAction = SKAction.moveTo(y: frame.maxY + 200, duration: 0.5)
        } else if !drawerIsOpen && state {
            moveAction = SKAction.moveTo(y: frame.maxY - 150, duration: 0.5)
        } else {
            return
        }
        
        drawer.run(moveAction)
        drawerIsOpen.toggle()
    }

    func addStatLabelToDrawer(text: String, fontSize: CGFloat = 32, position: CGPoint, name: String) {
        let label = SKLabelNode(text: text)
        label.fontSize = fontSize
        label.fontColor = .white
        label.fontName = "Helvetica-Bold"
        label.position = position
        label.name = name
        drawer.addChild(label)
    }

    func setupDrawerAndButton() {
        // Set up the drawer button
        let drawerButton_ = SKTexture(imageNamed: "Arrow")
        drawerButton = SKSpriteNode(texture: drawerButton_)
        drawerButton.size = CGSize(width: 25, height: 25)
        drawerButton.position = CGPoint(x: frame.minX + 35, y: frame.maxY - 35)
        drawerButton.name = "drawerButton"
        addChild(drawerButton)
        
        // Set up the drawer
        drawer = SKShapeNode(rectOf: CGSize(width: frame.width, height: 350))
        drawer.position = CGPoint(x: frame.midX, y: frame.maxY + 200)
        drawer.fillColor = .darkGray
        drawer.zPosition = 10
        addChild(drawer)
        
        // Add stats labels to the drawer
        addStatLabelToDrawer(text: "Stats", fontSize: 48, position: CGPoint(x: 0, y: 50), name: "statsLabel")
        addStatLabelToDrawer(text: "Rate of Fire: \(rateOfFire)", position: CGPoint(x: 0, y: 0), name: "rateOfFireLabel")
        addStatLabelToDrawer(text: "Bullet Speed: \(bulletSpeed)", position: CGPoint(x: 0, y: -30), name: "bulletSpeedLabel")
        addStatLabelToDrawer(text: "Bullet Count: \(bulletCount)", position: CGPoint(x: 0, y: -60), name: "bulletCountLabel")
        addStatLabelToDrawer(text: "Bullet Size: \(bulletSize)", position: CGPoint(x: 0, y: -90), name: "bulletSizeLabel")
        addStatLabelToDrawer(text: "Bullet Bounce: \(bulletBounce)", position: CGPoint(x: 0, y: -120), name: "bulletBounceLabel")
        addStatLabelToDrawer(text: "Bullet Spread: \(bulletSpread)", position: CGPoint(x: 0, y: -150), name: "bulletSpreadLabel")
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
