import SpriteKit

class MainMenuScene: SKScene {
    var drawerButton: SKSpriteNode!
    var drawer: SKShapeNode!
    var drawerIsOpen = false
    
    override func didMove(to view: SKView) {
        setupTilingBackground(textureName: "Background2")
        
        // Create title label
        let titleLabel = createLabel(text: "Space Invader", fontSize: 48, position: CGPoint(x: size.width * 0.5, y: size.height * 0.8))
        addChild(titleLabel)
        
        let subTitleLabel = createLabel(text: "Rogue Like", fontSize: 36, position: CGPoint(x: size.width * 0.5, y: size.height * 0.75))
        addChild(subTitleLabel)
        
        // Create and position the buttons
        let positions = [CGPoint(x: size.width * 0.5, y: size.height * 0.5),
                         CGPoint(x: size.width * 0.5, y: size.height * 0.3)]
        let sizes = CGSize(width: 300, height: 125)
        let titles = ["Play", "Stats"]
        
        for (index, title) in titles.enumerated() {
            let button = createButton(title: title, position: positions[index], sizes: sizes)
            addChild(button)
        }
        
        setupDrawerAndButton()
    }
    
    func setupTilingBackground(textureName: String) {
        // Create the tiling background node
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
        
        // Create button background using an image
        let buttonBackground = SKSpriteNode(imageNamed: "Button")
        buttonBackground.size = sizes
        buttonBackground.zPosition = 1
        
        let buttonLabel = SKLabelNode(text: title)
        buttonLabel.fontColor = .white
        buttonLabel.fontSize = 36
        buttonLabel.fontName = "Helvetica-Bold"
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.position = CGPoint(x: 0, y: 0)
        buttonLabel.zPosition = 2
        
        buttonNode.addChild(buttonBackground)
        buttonNode.addChild(buttonLabel)
        buttonNode.name = title
        
        return buttonNode
    }
    
    func createLabel(text: String, fontSize: CGFloat = 32, position: CGPoint) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontColor = .white
        label.fontSize = fontSize
        label.fontName = "Helvetica-Bold"
        label.position = position
        return label
    }
    
    func setupDrawerAndButton() {
        drawer = SKShapeNode(rectOf: CGSize(width: frame.width, height: 450))
        drawer.position = CGPoint(x: frame.midX, y: frame.maxY + 300)
        drawer.fillColor = .darkGray
        drawer.zPosition = 10
        addChild(drawer)
        
        drawer.addChild(createLabel(text: "Highest Stats", fontSize: 48, position: CGPoint(x: 0, y: 50)))
        drawer.addChild(createLabel(text: "Rate of Fire: \(UserDefaults.standard.value(forKey: "highestRateOfFire") as? CGFloat ?? 1.0)", position: CGPoint(x: 0, y: 0)))
        drawer.addChild(createLabel(text: "Bullet Speed: \(UserDefaults.standard.value(forKey: "highestBulletSpeed") as? CGFloat ?? 1.0)", position: CGPoint(x: 0, y: -30)))
        drawer.addChild(createLabel(text: "Bullet Count: \(UserDefaults.standard.value(forKey: "highestBulletCount") as? Int ?? 1)", position: CGPoint(x: 0, y: -60)))
        drawer.addChild(createLabel(text: "Bullet Size: \(UserDefaults.standard.value(forKey: "highestBulletSize") as? CGFloat ?? 1.0)", position: CGPoint(x: 0, y: -90)))
        drawer.addChild(createLabel(text: "Bullet Bounce: \(UserDefaults.standard.value(forKey: "highestBulletBounce") as? Int ?? 1)", position: CGPoint(x: 0, y: -120)))
        drawer.addChild(createLabel(text: "Bullet Spread: \(UserDefaults.standard.value(forKey: "highestBulletSpread") as? CGFloat ?? 1.0)", position: CGPoint(x: 0, y: -150)))
        drawer.addChild(createLabel(text: "Wave: \(UserDefaults.standard.value(forKey: "highestWave") as? Int ?? 1)", fontSize: 48, position: CGPoint(x: 0, y: -200)))
    }
    
    func toggleDrawer(state: Bool) {
        let moveAction: SKAction
        
        if drawerIsOpen && !state {
            moveAction = SKAction.moveTo(y: frame.maxY + 300, duration: 0.5)
        } else if !drawerIsOpen && state {
            moveAction = SKAction.moveTo(y: frame.maxY - 150, duration: 0.5)
        } else {
            return
        }
        
        drawer.run(moveAction)
        drawerIsOpen.toggle()
    }

    // Handle touch events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        let touchedNode = self.atPoint(location)

        if (!drawerIsOpen) {
            for node in nodesAtPoint {
                if let nodeName = node.name {
                    handleButtonPress(name: nodeName)
                    return
                }
            }
        }
        toggleDrawer(state: touchedNode.name == "drawerButton")
    }
    
    func handleButtonPress(name: String) {
        if let view = view {
            let playSound = SKAction.playSoundFileNamed("pick", waitForCompletion: false)
            self.run(playSound)
            
            switch name {
            case "Play":
                let gameScene = GameScene(size: size)
                gameScene.scaleMode = .aspectFill
                let transition = SKTransition.fade(withDuration: 1.0)
                view.presentScene(gameScene, transition: transition)
                break
            case "Stats":
                toggleDrawer(state: true)
                break
            default:
                break
            }
        }
    }
}
