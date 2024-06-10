import SpriteKit

class PowerUpChoiceScene: SKScene {
    var gameScene: GameScene?
    var powerUps = ["Rate of Fire", "BulletSpeed", "BulletCount", "BulletBounce", "BulletSize", "BulletSpread"]
    var drawerButton: SKSpriteNode!
    var drawer: SKShapeNode!
    var drawerIsOpen = false
    
    override func didMove(to view: SKView) {
        setupTilingBackground(textureName: "Background2")
        setupDrawerAndButton()

        // Select 3 random power-ups from the list
        let selectedPowerUps = selectRandomPowerUps(count: 3)
        
        // Create and position the buttons
        let positions = [CGPoint(x: size.width * 0.5, y: size.height * 0.3),
                         CGPoint(x: size.width * 0.5, y: size.height * 0.5),
                         CGPoint(x: size.width * 0.5, y: size.height * 0.7)]
        let sizes = CGSize(width: 360, height: 150)
        
        for (index, powerUp) in selectedPowerUps.enumerated() {
            let button = createButton(title: powerUp, position: positions[index], sizes: sizes)
            if let statValue = gameScene?.getStatValue(for: powerUp) {
                addStatLabel(to: button, value: statValue)
            }
            addChild(button)
        }
    }
    
    func setupTilingBackground(textureName: String) {
        let background = SKNode()
        background.zPosition = -10

        let texture = SKTexture(imageNamed: textureName)
        let textureSize = CGSize(width: texture.size().width * 4, height: texture.size().height * 4)
        let columns = Int(ceil(size.width / textureSize.width)) + 1
        let rows = Int(ceil(size.height / textureSize.height)) + 1

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
    
    func createButton(title: String, position: CGPoint, sizes: CGSize) -> SKNode {
        let buttonNode = SKNode()
        buttonNode.position = position
        
        let buttonBackground = SKSpriteNode(imageNamed: "Button")
        buttonBackground.size = sizes
        buttonBackground.zPosition = 1
        
        let buttonLabel = SKLabelNode(text: title)
        buttonLabel.fontColor = .white
        buttonLabel.fontSize = 36
        buttonLabel.fontName = "Helvetica-Bold"
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.position = CGPoint(x: 0, y: 10)
        buttonLabel.zPosition = 2
        
        buttonNode.addChild(buttonBackground)
        buttonNode.addChild(buttonLabel)
        buttonNode.name = title
        
        return buttonNode
    }
    
    func addStatLabel(to button: SKNode, value: CGFloat) {
        let roundedValue = (value == floor(value)) ? String(format: "%.0f", value) : String(format: "%.1f", value)
        let statLabel = SKLabelNode(text: "\(roundedValue)")
        statLabel.fontColor = .white
        statLabel.fontName = "Helvetica-Bold"
        statLabel.fontSize = 24
        statLabel.position = CGPoint(x: 0, y: -30)
        statLabel.zPosition = 2
        button.addChild(statLabel)
    }
    
    func selectRandomPowerUps(count: Int) -> [String] {
        var selected = Set<String>()
        while selected.count < count {
            let randomIndex = Int(arc4random_uniform(UInt32(powerUps.count)))
            selected.insert(powerUps[randomIndex])
        }
        return Array(selected)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        let touchedNode = self.atPoint(location)

        if (!drawerIsOpen){
            for node in nodesAtPoint {
                if let nodeName = node.name, powerUps.contains(nodeName) {
                    handleButtonPress(name: nodeName)
                    break
                }
            }
        }
        toggleDrawer(state: touchedNode.name == "drawerButton")
    }

    
    func handleButtonPress(name: String) {
        if let view = view, let gameScene = gameScene {
            gameScene.scaleMode = .aspectFill
            gameScene.didChoosePowerUp(name)
            let transition = SKTransition.fade(withDuration: 1.0)
            view.presentScene(gameScene, transition: transition)
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
        let drawerButton_ = SKTexture(imageNamed: "Arrow")
        drawerButton = SKSpriteNode(texture: drawerButton_)
        drawerButton.size = CGSize(width: 25, height: 25)
        drawerButton.position = CGPoint(x: frame.minX + 35, y: frame.maxY - 35)
        drawerButton.name = "drawerButton"
        addChild(drawerButton)
        
        drawer = SKShapeNode(rectOf: CGSize(width: frame.width, height: 350))
        drawer.position = CGPoint(x: frame.midX, y: frame.maxY + 200)
        drawer.fillColor = .darkGray
        drawer.zPosition = 10
        addChild(drawer)
        
        addStatLabelToDrawer(text: "Stats", fontSize: 48, position: CGPoint(x: 0, y: 50), name: "statsLabel")
        addStatLabelToDrawer(text: "Rate of Fire: \(gameScene?.rateOfFire ?? 0)", position: CGPoint(x: 0, y: 0), name: "rateOfFireLabel")
        addStatLabelToDrawer(text: "Bullet Speed: \(gameScene?.bulletSpeed ?? 0)", position: CGPoint(x: 0, y: -30), name: "bulletSpeedLabel")
        addStatLabelToDrawer(text: "Bullet Count: \(gameScene?.bulletCount ?? 0)", position: CGPoint(x: 0, y: -60), name: "bulletCountLabel")
        addStatLabelToDrawer(text: "Bullet Size: \(gameScene?.bulletSize ?? 0)", position: CGPoint(x: 0, y: -90), name: "bulletSizeLabel")
        addStatLabelToDrawer(text: "Bullet Bounce: \(gameScene?.bulletBounce ?? 0)", position: CGPoint(x: 0, y: -120), name: "bulletBounceLabel")
        addStatLabelToDrawer(text: "Bullet Spread: \(gameScene?.bulletSpread ?? 0)", position: CGPoint(x: 0, y: -150), name: "bulletSpreadLabel")
    }
    
}
