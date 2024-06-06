import SpriteKit

class PowerUpChoiceScene: SKScene {
    var gameScene: GameScene?
    let powerUps = ["Rate of Fire", "BulletSpeed", "BulletCount", "BulletBounce", "BulletSize", "BulletSpread"] 
    
    override func didMove(to view: SKView) {
        
        // Select 3 random power-ups from the list
        let selectedPowerUps = selectRandomPowerUps(count: 3)
        
        // Create and position the buttons
        let positions = [CGPoint(x: size.width * 0.5, y: size.height * 0.3),
                         CGPoint(x: size.width * 0.5, y: size.height * 0.5),
                         CGPoint(x: size.width * 0.5, y: size.height * 0.7)]
        let sizes = CGSize(width: 240, height: 100)
        
        for (index, powerUp) in selectedPowerUps.enumerated() {
            let button = createButton(title: powerUp, position: positions[index], sizes: sizes)
            if let statValue = gameScene?.getStatValue(for: powerUp) {
                addStatLabel(to: button, value: statValue)
            }
            addChild(button)
        }
    }
    
    // Function to create a button
    func createButton(title: String, position: CGPoint, sizes: CGSize) -> SKNode {
        let buttonNode = SKNode()
        buttonNode.position = position
        
        // Create shadow node
        let shadowNode = SKShapeNode(rectOf: sizes, cornerRadius: 12)
        shadowNode.fillColor = UIColor.black.withAlphaComponent(0.4)
        shadowNode.strokeColor = .clear
        shadowNode.position = CGPoint(x: 4, y: -4)  // Offset for shadow effect
        shadowNode.zPosition = 0
        
        // Create button background
        let buttonBackground = SKShapeNode(rectOf: sizes, cornerRadius: 12)
        buttonBackground.fillColor = .gray
        buttonBackground.strokeColor = .black
        buttonBackground.lineWidth = 2
        buttonBackground.zPosition = 1
        
        let buttonLabel = SKLabelNode(text: title)
        buttonLabel.fontColor = .white
        buttonLabel.fontSize = 36
        buttonLabel.fontName = "Helvetica-Bold"
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.position = CGPoint(x: 0, y: 0)
        buttonLabel.zPosition = 2
        
        buttonNode.addChild(shadowNode)
        buttonNode.addChild(buttonBackground)
        buttonNode.addChild(buttonLabel)
        buttonNode.name = title
        
        return buttonNode
    }
    
    // Function to add a stat label under the button
    func addStatLabel(to button: SKNode, value: CGFloat) {
        let roundedValue = (value == floor(value)) ? String(format: "%.0f", value) : String(format: "%.1f", value)
        let statLabel = SKLabelNode(text: "\(roundedValue)")
        statLabel.fontColor = .white
        statLabel.fontName = "Helvetica-Bold"
        statLabel.fontSize = 20
        statLabel.position = CGPoint(x: 0, y: -40)  // Position below the button
        statLabel.zPosition = 1
        button.addChild(statLabel)
    }
    
    // Function to randomly select a given number of power-ups from the list
    func selectRandomPowerUps(count: Int) -> [String] {
        var selected = Set<String>()
        while selected.count < count {
            let randomIndex = Int(arc4random_uniform(UInt32(powerUps.count)))
            selected.insert(powerUps[randomIndex])
        }
        return Array(selected)
    }
    
    // Handle touch events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for node in nodesAtPoint {
            if let nodeName = node.name {
                handleButtonPress(name: nodeName)
            }
        }
    }
    
    func handleButtonPress(name: String) {
        if let view = view, let gameScene = gameScene {
            gameScene.scaleMode = .aspectFill
            gameScene.didChoosePowerUp(name)
            let transition = SKTransition.fade(withDuration: 1.0)
            view.presentScene(gameScene, transition: transition)
        }
    }
}
