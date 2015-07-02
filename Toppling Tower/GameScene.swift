//
//  GameScene.swift
//  Toppling Tower
//
//  Created by Alec Shedelbower on 3/13/15.
//  Copyright (c) 2015 Alec Shedelbower. All rights reserved.
//

import SpriteKit
import CoreMotion
import Foundation

enum PhysicsCategory : UInt32 {
    case None   = 1
    case All    = 2
    case Platform  = 4
    case Block = 8
    case Border = 16
    case PowerUp = 32
}

enum BlockType {
    case Wide
    case Tall
    case Small
    case Medium
    case Large
}

enum PowerUp {
    case None
    case Removal
    case Flame
    case Spark
    case Plus
}

enum BlockRemovalMethod {
    case Shrink
    case Dissolve
    case Burn
    case Shock
}

enum GameMode {
    case Elimination
    case Stacker
    case Bins
}

var blocksTouchingPlatform: [SKShapeNode] = []

var currentScore: Int = 0

let difficultyCounterLimit: Int = 500
var difficultyCounter: Int = 0

let powerUpCountLimit: Int = 400
var powerUpCounter: Int = 0

var playPop: SKAction = SKAction.playSoundFileNamed("Bubble_Pop.wav", waitForCompletion: false)
var playTap: SKAction = SKAction.playSoundFileNamed("Soft_Tap.wav", waitForCompletion: false)
var playPowerUp: SKAction = SKAction.playSoundFileNamed("PowerUp.wav", waitForCompletion: false)
var playShimmer: SKAction = SKAction.playSoundFileNamed("Shimmer.wav", waitForCompletion: false)
var playPowerDown: SKAction = SKAction.playSoundFileNamed("PowerDown.wav", waitForCompletion: false)
var playBurning: SKAction = SKAction.playSoundFileNamed("Burning.wav", waitForCompletion: false)
var playElectricity: SKAction = SKAction.playSoundFileNamed("Electricity.wav", waitForCompletion: false)
let playMusic = SKAction.repeatActionForever(SKAction.playSoundFileNamed("Ambient_Beat.wav", waitForCompletion: true))

var gameType: GameMode = .Elimination
var activePowerUp: PowerUp = .None
var mostRecentPowerUpMade: PowerUp = .None

/* Colors */
//Light
let colorLightYellow: SKColor = SKColor(red: (255/255), green: (255/255), blue: (150/255), alpha: 1.0)
let colorLightOrange: SKColor = SKColor(red: (255/255), green: (230/255), blue: (180/255), alpha: 1.0)
let colorLightRed: SKColor = SKColor(red: (255/255), green: (215/255), blue: (185/255), alpha: 1.0)
//Normal
let colorPurple: SKColor = SKColor(red: (200/255), green: (100/255), blue: (200/255), alpha: 1.0)
let colorGreen: SKColor = SKColor(red: (50/255), green: (200/255), blue: (50/255), alpha: 1.0)
let colorYellow: SKColor = SKColor(red: (255/255), green: (255/255), blue: (10/255), alpha: 1.0)
let colorRed: SKColor = SKColor(red: (255/255), green: (10/255), blue: (10/255), alpha: 1.0)
let colorBlue: SKColor = SKColor(red: (10/255), green: (100/255), blue: (255/255), alpha: 1.0)
let colorOrange: SKColor = SKColor(red: (255/255), green: (100/255), blue: (0/255), alpha: 1.0)
let colorBlack: SKColor = SKColor.blackColor()
//Intense
let colorRedIntense: SKColor = SKColor(red: (255/255), green: (10/255), blue: (10/255), alpha: 1.0)


let powerUpName = "powerUp"
let emitterNodeName = "emitterNode"
let powerUpRadius:CGFloat = 8
let powerUpShapeNodeGlowWidth: CGFloat = 4
var powerUpSpawningCounter: CGFloat = 2500
var powerUpSpawnFrequency: CGFloat = 3000

var maxBlocksMissed: CGFloat = 10
var currentBlocksMissed: CGFloat = 0

let scoreLabelName = "scoreLabel"
let scoreLabelFontSize: CGFloat = 20

let scoreupdateCounterMax: Int = 20
var scoreUpdateCounterLimit: Int = 20
var scoreUpdateCounter: Int = 0

let finalScoreLabelName = "finalScoreLabel"
let finalScoreLabelFontSize: CGFloat = 50
let finalScoreLabelFontColor: SKColor = colorBlack

let labelName: String = "label"
let labelFontColor: SKColor = SKColor.blackColor()
let labelFontSize: CGFloat = 72

let screenSize: CGRect = UIScreen.mainScreen().bounds
let screenWidth = screenSize.width
let screenHeight = screenSize.height

var blockSpawningFrequency: CGFloat = 400

let platformForceX:CGFloat = 100

let platformName = "platform"
let platformFillColor = colorBlack
let platformStrokeColor = SKColor.clearColor()
let platformGlowWidth: CGFloat = 4
let platformWidth: CGFloat = 200
let platformHeight: CGFloat = 30
let platformYPosition: CGFloat = 100

var blockNumber: Int = 0
let blockName = "block"
var blockGlowWidth: CGFloat = 4
let BlockSizeWide: CGSize = CGSizeMake(150,50)
let BlockSizeTall: CGSize = CGSizeMake(50,150)
let BlockSizeSmall: CGSize = CGSizeMake(50,50)
let BlockSizeMedium: CGSize = CGSizeMake(50,100)
let BlockSizeLarge: CGSize = CGSizeMake(100,100)

let BlockStrokeColor: SKColor = SKColor.clearColor()
let BlockColorWide: SKColor = colorPurple
let BlockColorTall: SKColor = colorBlue
let BlockColorSmall: SKColor = colorGreen
let BlockColorMedium: SKColor = colorRed
let BlockColorLarge: SKColor = colorOrange




class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let motionManager: CMMotionManager = CMMotionManager()
    
    var blockSpawningCounter: CGFloat = 400
    
    func updateDifficulty() {
        difficultyCounter += 1
        if difficultyCounter >= difficultyCounterLimit && blockSpawningFrequency >= 100 {
            difficultyCounter = 0
            blockSpawningFrequency -= 10
        }
    }
    
    func updateBackground() {
        let percentage: CGFloat = (maxBlocksMissed - currentBlocksMissed) / maxBlocksMissed
        switch percentage {
        case 0.51...1.0:
            self.backgroundColor = SKColor.whiteColor()
        case 0.26...0.5:
            self.backgroundColor = colorLightYellow
        case 0.1...0.25:
            self.backgroundColor = colorLightOrange
        case 0.0...0.09:
            self.backgroundColor = colorLightRed
        default:
            println("Error 'updateBackground()'")
            self.backgroundColor = SKColor.blueColor()
        }
    }
    
    func updateScore() {
        scoreUpdateCounter += 1
        if scoreUpdateCounter >= scoreUpdateCounterLimit {
            scoreUpdateCounter = 0
            currentScore += 1
        }
    }
    
    func makeScoreLabel() -> SKNode {
        let scoreLabel = SKLabelNode(fontNamed: mainFont)
        scoreLabel.name = scoreLabelName
        scoreLabel.text = "Score: "
        scoreLabel.fontColor = labelFontColor
        scoreLabel.fontSize = scoreLabelFontSize
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        scoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame) - screenWidth/1.5, y: CGRectGetMaxY(self.frame))
        return scoreLabel
    }
    
    func updateScoreLabel(scoreLabel: SKLabelNode) {
        scoreLabel.text = "Score: \(currentScore)"
    }
    
    func makeFinalScoreLabel() -> SKNode {
        let finalScoreLabel = SKLabelNode(fontNamed: mainFont)
        finalScoreLabel.name = finalScoreLabelName
        finalScoreLabel.text = "Score: \(currentScore)"
        finalScoreLabel.fontSize = finalScoreLabelFontSize
        finalScoreLabel.fontColor = finalScoreLabelFontColor
        let label = self.childNodeWithName(labelName) as! SKLabelNode
        finalScoreLabel.position = CGPoint(x: label.position.x, y: label.position.y - (finalScoreLabel.frame.height + 20))
        return finalScoreLabel
    }
    
    func makeLabel() -> SKNode {
        let label = SKLabelNode(fontNamed: mainFont)
        label.name = labelName
        label.text = "\(Int(maxBlocksMissed-currentBlocksMissed))"
        label.fontSize = labelFontSize
        label.fontColor = labelFontColor
        label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        return label
    }
    
    func updateLabel(label: SKLabelNode) {
        label.text = "\(Int(maxBlocksMissed-currentBlocksMissed))"
    }
    
    func activatePowerUp(type: PowerUp) {
        self.runAction(playPowerUp)
        powerUpCounter = powerUpCountLimit
        activePowerUp = type
        let platform = self.childNodeWithName(platformName) as! SKShapeNode
        switch type {
        case .Removal:
            platform.strokeColor = colorBlue
        case .Flame:
            platform.strokeColor = colorOrange
        case .Spark:
            platform.strokeColor = colorYellow
        case .Plus:
            platform.strokeColor = colorGreen
            scoreUpdateCounterLimit = scoreUpdateCounterLimit/4
        default:
            println("Error in activatePowerUp")
        }
    }
    
    func checkForExpiredPowerUps(){
        if powerUpCounter == 1 {
            self.runAction(playPowerDown)
            powerUpCounter -= 1
        }
        else if powerUpCounter > 0 {
            powerUpCounter -= 1
        }
        else {
            if activePowerUp == .Plus {
                scoreUpdateCounterLimit = scoreupdateCounterMax
            }
            activePowerUp = .None
            let platform = self.childNodeWithName(platformName) as! SKShapeNode
            platform.strokeColor = SKColor.clearColor()
        }
    }
    
    func makePowerUp(type: PowerUp, location: CGPoint) -> SKNode {
        var ParticleEffectFile: String = "RemovalEmitter"
        var shapeNodeColor: SKColor = colorRedIntense
        var Name: String = powerUpName
        
        mostRecentPowerUpMade = type
        
        switch type {
        case .Removal:
            ParticleEffectFile = "RemovalEmitter"
            shapeNodeColor = colorBlue
            Name = powerUpName + "Removal"
        case .Flame:
            ParticleEffectFile = "FlameEmitter"
            shapeNodeColor = colorRedIntense
            Name = powerUpName + "Flame"
        case .Spark:
            ParticleEffectFile = "SparkEmitter"
            shapeNodeColor = colorYellow
            Name = powerUpName + "Spark"
        case .Plus:
            ParticleEffectFile = "PlusEmitter"
            shapeNodeColor = colorGreen
            Name = powerUpName + "Plus"
        default:
            println("Error: PowerUp type not applicable")
        }
        
        let sparkEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(NSBundle.mainBundle().pathForResource(ParticleEffectFile, ofType: "sks")!) as! SKEmitterNode
        let shapeNode = SKShapeNode(circleOfRadius: powerUpRadius)
        shapeNode.name = "shapeNode"
        sparkEmitterNode.name = emitterNodeName
        
        shapeNode.fillColor = shapeNodeColor
        shapeNode.strokeColor = shapeNodeColor
        shapeNode.glowWidth = powerUpShapeNodeGlowWidth
        
        
        let mainNode = SKNode()
        mainNode.name = Name
        mainNode.physicsBody = SKPhysicsBody(circleOfRadius: powerUpRadius)
        mainNode.physicsBody?.linearDamping = 8.0
        mainNode.physicsBody?.categoryBitMask = PhysicsCategory.PowerUp.rawValue
        mainNode.physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue
        mainNode.physicsBody?.contactTestBitMask = PhysicsCategory.Platform.rawValue
        
        
        mainNode.addChild(sparkEmitterNode)
        mainNode.addChild(shapeNode)
        mainNode.position = location
        return mainNode
    }
    
    func makeEmitterNodeForShapeNode(shapeNode: SKShapeNode, color: SKColor, EmitterFileName: String, makePhysicsBody: Bool, useDefaultColor: Bool, collideWithPlatform: Bool) -> SKEmitterNode {
        let EmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(NSBundle.mainBundle().pathForResource(EmitterFileName, ofType: "sks")!) as! SKEmitterNode
        EmitterNode.name = emitterNodeName
        EmitterNode.particlePositionRange.dx = shapeNode.frame.width
        EmitterNode.particlePositionRange.dy = shapeNode.frame.height
        if useDefaultColor == false {
            EmitterNode.particleColor = color
            EmitterNode.particleColorSequence = nil
        }
        EmitterNode.particleBirthRate = 500
        
        let blockVelocity = shapeNode.physicsBody?.velocity
        EmitterNode.position = shapeNode.position
        if makePhysicsBody {
            EmitterNode.physicsBody = SKPhysicsBody(rectangleOfSize: shapeNode.frame.size)
            EmitterNode.physicsBody?.velocity = blockVelocity!
            EmitterNode.physicsBody?.affectedByGravity = false
            EmitterNode.physicsBody?.categoryBitMask = PhysicsCategory.PowerUp.rawValue
            if collideWithPlatform {
                EmitterNode.physicsBody?.collisionBitMask = PhysicsCategory.Platform.rawValue
            }
            else {
                EmitterNode.physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue
            }
        }
        
        return EmitterNode
    }
    
    func makeScreenBorder() {
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRectMake(CGRectGetMidX(self.frame)-450/2, CGRectGetMidY(self.frame)-800/2, 450, 800))
        self.physicsBody?.categoryBitMask = PhysicsCategory.Border.rawValue
        self.physicsBody?.collisionBitMask = PhysicsCategory.Platform.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Block.rawValue
    }
    
//    func makePlusAndLabelNode(label: String) {
//        let 
//    }
    
    func makePlusPointsNode(block: SKShapeNode, label: String) {
        self.enumerateChildNodesWithName("block*"){
            node, stop in
            
        }
    }
    
    func makePlatform() -> SKNode {
        let platform = SKShapeNode(rectOfSize: CGSizeMake(platformWidth, platformHeight))
        platform.name = platformName
        platform.fillColor = platformFillColor
        platform.strokeColor = platformStrokeColor
        platform.glowWidth = platformGlowWidth
        platform.position = CGPointMake(CGRectGetMidX(self.frame), platformYPosition)
        platform.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(platformWidth, platformHeight))
        platform.physicsBody?.linearDamping = 2.0
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.mass = 10.0
        platform.physicsBody?.friction = 100.0
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = PhysicsCategory.Platform.rawValue
        platform.physicsBody?.collisionBitMask = PhysicsCategory.Block.rawValue | PhysicsCategory.Border.rawValue
        platform.physicsBody?.contactTestBitMask = PhysicsCategory.Block.rawValue
        return platform
    }
    
    func makeBlock(Type: BlockType, Location: CGPoint) -> SKNode {
        var BlockSize: CGSize
        var BlockColor: SKColor
        switch Type {
        case .Wide:
            BlockSize = BlockSizeWide
            BlockColor = BlockColorWide
        case .Tall:
            BlockSize = BlockSizeTall
            BlockColor = BlockColorTall
        case .Small:
            BlockSize = BlockSizeSmall
            BlockColor = BlockColorSmall
        case .Medium:
            BlockSize = BlockSizeMedium
            BlockColor = BlockColorMedium
        case .Large:
            BlockSize = BlockSizeLarge
            BlockColor = BlockColorLarge
            
        }
        
        let block = SKShapeNode(rectOfSize: BlockSize)
        block.name = blockName
        block.fillColor = BlockColor
        block.strokeColor = BlockStrokeColor
        block.physicsBody = SKPhysicsBody(rectangleOfSize: BlockSize)
        block.physicsBody?.friction = 5.0
        block.physicsBody?.mass = 0.01
        block.physicsBody?.linearDamping = 5.0
        block.physicsBody?.angularDamping = 4.0
        block.physicsBody?.categoryBitMask = PhysicsCategory.Block.rawValue
        block.physicsBody?.collisionBitMask = PhysicsCategory.Block.rawValue | PhysicsCategory.Platform.rawValue
        block.physicsBody?.contactTestBitMask = PhysicsCategory.Block.rawValue | PhysicsCategory.Platform.rawValue
        block.position = Location
        blockNumber += 1
        return block
    }
    
    func dropPowerUpsRandomly(frequency: CGFloat) {
        powerUpSpawningCounter += 1
        if powerUpSpawningCounter >= frequency && activePowerUp == .None {
            powerUpSpawningCounter = 0
            var Type: PowerUp = .Removal
            var Location: CGPoint = CGPointMake(CGRectGetMidX(self.frame), self.frame.height*1.5)
            let RandomValueType = arc4random_uniform(4)+1
            switch RandomValueType{
            case 1:
                Type = .Removal
            case 2:
                Type = .Flame
            case 3:
                Type = .Spark
            case 4:
                Type = .Plus
            default:
                println("Error in 'dropPowerUpsRandomly'\nRandomValueType not accounted for.")
            }
            
            let minX = Int(round(CGRectGetMidX(self.frame)-100))
            let maxX = Int(round(CGRectGetMidX(self.frame)+100))
            let xValue = CGFloat(randomRange(minX, upper: maxX))
            Location = CGPoint(x: xValue, y: self.frame.height*1.5)
            
//            let RandomValueLocation = arc4random_uniform(3)+1
//            switch RandomValueLocation {
//            case 1:
//                Location = CGPointMake(CGRectGetMidX(self.frame), self.frame.height*1.5)
//            case 2:
//                Location = CGPointMake(CGRectGetMidX(self.frame) - 100, self.frame.height*1.5)
//            case 3:
//                Location = CGPointMake(CGRectGetMidX(self.frame) + 100, self.frame.height*1.5)
//            default:
//                println("Error in 'dropBlocksRandomlyFunction'\nRandomValueLocation not accounted for.")
//            }
            
            let powerUp = makePowerUp(Type, location: Location)
            self.addChild(powerUp)
        }
    }
    
    func randomRange (lower: Int , upper: Int) -> Int {
        return Int(arc4random_uniform(UInt32(upper - lower + 1))) + lower
    }
    
    func dropBlocksRandomly(frequency: CGFloat){
        blockSpawningCounter += 1
        if blockSpawningCounter >= frequency {
            blockSpawningCounter = 0
            var Type: BlockType = .Wide
            var Location: CGPoint = CGPointMake(CGRectGetMidX(self.frame), self.frame.height*1.5)
            let RandomValueType = arc4random_uniform(5)+1
            switch RandomValueType{
            case 1:
                Type = .Wide
            case 2:
                Type = .Small
            case 3:
                Type = .Medium
            case 4:
                Type = .Large
            case 5:
                Type = .Tall
            default:
                println("Error in 'dropBlocksRandomlyFunction'\nRandomValueType not accounted for.")
            }
            let minX = Int(round(CGRectGetMidX(self.frame)-100))
            let maxX = Int(round(CGRectGetMidX(self.frame)+100))
            let xValue = CGFloat(randomRange(minX, upper: maxX))
            Location = CGPoint(x: xValue, y: self.frame.height*1.5)
            
//            let RandomValueLocation = arc4random_uniform(3)+1
//            switch RandomValueLocation {
//            case 1:
//                Location = CGPointMake(CGRectGetMidX(self.frame), self.frame.height*1.5)
//            case 2:
//                Location = CGPointMake(CGRectGetMidX(self.frame) - 100, self.frame.height*1.5)
//            case 3:
//                Location = CGPointMake(CGRectGetMidX(self.frame) + 100, self.frame.height*1.5)
//            default:
//                println("Error in 'dropBlocksRandomlyFunction'\nRandomValueLocation not accounted for.")
//            }
            
            let block = makeBlock(Type, Location: Location)
            self.addChild(block)
        }
    }
    
    func CheckForGameOver() -> Bool {
        if (maxBlocksMissed-currentBlocksMissed) <= 0 {
            self.enumerateChildNodesWithName("block*") {
                node, stop in
                
                let action = SKAction.sequence([SKAction.scaleBy(0.01, duration: 1), SKAction.removeFromParent()])
                node.runAction(action)
                node.name = "removed block"
                self.runAction(playPop)
            }
            self.enumerateChildNodesWithName("powerUp*") {
                node, stop in
                
                let action = SKAction.sequence([SKAction.scaleBy(0.01, duration: 1), SKAction.removeFromParent()])
                node.runAction(action)
                node.name = "removed powerUp"
            }
            let label = self.childNodeWithName("label") as! SKLabelNode
            label.text = "Game Over"
            let finalScoreLabel = makeFinalScoreLabel()
            self.addChild(finalScoreLabel)
            return true
        }
        return false
    }
    
    func ResetGame() {
        println("GAME SHOULD RESET")
        currentBlocksMissed = 0
        currentScore = 0
        scoreUpdateCounterLimit = scoreupdateCounterMax
        blockSpawningFrequency = 400
        powerUpCounter = 0
        powerUpSpawningCounter = 2500
        blockSpawningCounter = 400
        self.enumerateChildNodesWithName("*") {
            node, stop in
            node.removeFromParent()
        }
    
    }
    
    func movePlatformFromAccelerometerData(currentTime: CFTimeInterval) {
        
        let platform = childNodeWithName(platformName) as! SKShapeNode
        
        if let data = motionManager.accelerometerData {
            
            if (data.acceleration.x > 0.2) {
                platform.physicsBody?.applyImpulse(CGVectorMake(platformForceX * CGFloat(data.acceleration.x), 0))
            }
            else if (data.acceleration.x < -0.2) {
                platform.physicsBody?.applyImpulse(CGVectorMake(platformForceX * CGFloat(data.acceleration.x), 0))
            }
        }
    }
    
    func updateFireEmitters() {
        self.enumerateChildNodesWithName("block*") {
            node, stop in
            if let emitter = node.childNodeWithName(emitterNodeName + "Fire") as? SKEmitterNode {
                emitter.zRotation = -node.zRotation
                emitter.particlePositionRange.dx = node.frame.width
                emitter.particlePositionRange.dy = node.frame.height
            }
        }
    }
    
     override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        motionManager.startAccelerometerUpdates()
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        
    }
    
     override func update(currentTime: NSTimeInterval) {
        let platform = childNodeWithName(platformName) as! SKShapeNode
        platform.position.y = platformYPosition
        movePlatformFromAccelerometerData(currentTime)
        RemoveBlocksOutOfBounds()
        let label = self.childNodeWithName(labelName) as! SKLabelNode
        let scoreLabel = self.childNodeWithName(scoreLabelName) as! SKLabelNode
        if CheckForGameOver() == false {
            dropBlocksRandomly(blockSpawningFrequency)
            dropPowerUpsRandomly(powerUpSpawnFrequency)
            checkForExpiredPowerUps()
            updateDifficulty()
            updateScoreLabel(scoreLabel)
            updateLabel(label)
            //updateFireEmitters()
            updateBackground()
            updateScore()
        }
    }
    
    
    func RemoveBlock(block: SKShapeNode, method: BlockRemovalMethod) {

        let shrinkAndRemoveAction = SKAction.sequence([SKAction.scaleBy(0.01, duration: 1), SKAction.removeFromParent()])
        
        switch method {
        case .Shrink:
            block.runAction(shrinkAndRemoveAction)
            block.name = "removed block"
            self.runAction(playPop)
        case .Dissolve:
            let Emitter = makeEmitterNodeForShapeNode(block, color: block.fillColor, EmitterFileName: "RemovalEmitter", makePhysicsBody: true, useDefaultColor: false, collideWithPlatform: false)
            self.addChild(Emitter)
            Emitter.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(2.0), SKAction.removeFromParent()]))
            block.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.50), SKAction.removeFromParent()]))
            block.name = "removed block"
            self.runAction(playShimmer)
            currentScore += 10
        case .Burn:
            let Emitter = makeEmitterNodeForShapeNode(block, color: block.fillColor, EmitterFileName: "BlockFlameEmitter", makePhysicsBody: false, useDefaultColor: true, collideWithPlatform: false)
            Emitter.position = CGPoint(x: 0,y: 0)
            Emitter.zRotation = -block.zRotation
            Emitter.name = emitterNodeName + "Fire"
            block.addChild(Emitter)
            block.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(5.0), SKAction.removeFromParent()]))
            block.name = "removed block"
            self.runAction(playBurning)
            currentScore += 5
        case .Shock:
            let Emitter = makeEmitterNodeForShapeNode(block, color: block.fillColor, EmitterFileName: "BlockSparkEmitter", makePhysicsBody: false, useDefaultColor: true, collideWithPlatform: false)
            Emitter.position = CGPoint(x: 0,y: 0)
            block.addChild(Emitter)
            block.runAction(SKAction.sequence([SKAction.fadeAlphaTo(0.25, duration: 0.5),SKAction.fadeAlphaTo(1.0, duration: 0.5),SKAction.fadeAlphaTo(0.25, duration: 0.5),SKAction.fadeAlphaTo(1.0, duration: 0.5), SKAction.fadeOutWithDuration(1.0), SKAction.removeFromParent()]))
            block.name = "removed block"
            block.strokeColor = colorYellow
            block.glowWidth = blockGlowWidth
            self.runAction(playElectricity)
            currentScore += 10
        }
    }
    
    func RemoveBlocksOutOfBounds() {
        self.enumerateChildNodesWithName("block*") {
            node, stop in
            if node.position.y < CGRectGetMinY(self.frame) {
                self.RemoveBlock(node as! SKShapeNode, method: .Shrink)
                currentBlocksMissed += 1
                
                let label = self.childNodeWithName(labelName)
                let lAction = SKAction.sequence([SKAction.scaleTo(1.1, duration: 0.25), SKAction.scaleTo(1.0, duration: 0.25)])
                label?.runAction(lAction)
                
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch gameType {
            
        case .Elimination:
            
            switch contactMask {
            case PhysicsCategory.Platform.rawValue | PhysicsCategory.Block.rawValue:
                var block: SKShapeNode
                if contact.bodyA.categoryBitMask == PhysicsCategory.Block.rawValue {
                    block = contact.bodyA.node as! SKShapeNode
                } else {
                    block = contact.bodyB.node as! SKShapeNode
                }
                blocksTouchingPlatform.append(block)
                self.runAction(playTap)
            case PhysicsCategory.Block.rawValue | PhysicsCategory.Block.rawValue:
                self.runAction(playTap)
            case PhysicsCategory.PowerUp.rawValue | PhysicsCategory.Platform.rawValue:
                if contact.bodyA.categoryBitMask == PhysicsCategory.PowerUp.rawValue {
                    contact.bodyA.node?.runAction(SKAction.sequence([SKAction.group([SKAction.fadeOutWithDuration(0.2), SKAction.scaleTo(2.0, duration: 0.2)]), SKAction.removeFromParent()]))
                    
                } else {
                    contact.bodyB.node?.runAction(SKAction.sequence([SKAction.group([SKAction.fadeOutWithDuration(0.2), SKAction.scaleTo(2.0, duration: 0.2)]), SKAction.removeFromParent()]))
                }
                self.activatePowerUp(mostRecentPowerUpMade)
            default:
                println("Other Contact")
                // Nobody expects this, so satisfy the compiler and catch
                // ourselves if we do something we didn't plan to
                //fatalError("other collision: \(contactMask)")
            }
        default:
            println("No gamemode specified")
        }
    }
    
     func didEndContact(contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch gameType {
            
        case .Elimination:
            
            switch contactMask {
            case PhysicsCategory.Platform.rawValue | PhysicsCategory.Block.rawValue:
                var block: SKShapeNode
                if contact.bodyA.categoryBitMask == PhysicsCategory.Block.rawValue {
                    block = contact.bodyA.node as! SKShapeNode
                } else {
                    block = contact.bodyB.node as! SKShapeNode
                }
                
                if contains(blocksTouchingPlatform, block) {
                    if let index = find(blocksTouchingPlatform, block){
                        blocksTouchingPlatform.removeAtIndex(index)
                    }
                }

            default:
                println("Other End Contact")
                // Nobody expects this, so satisfy the compiler and catch
                // ourselves if we do something we didn't plan to
                //fatalError("other collision: \(contactMask)")
            }
        default:
            println("No gamemode specified")
        }
    }
    
    
   }

//    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//        /* Called when a touch begins */
//
//        for touch: AnyObject in touches {
//            let location = touch.locationInNode(self)
//
//            let sprite = SKSpriteNode(imageNamed:"Spaceship")
//
//            sprite.xScale = 0.5
//            sprite.yScale = 0.5
//            sprite.position = location
//
//            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
//
//            sprite.runAction(SKAction.repeatActionForever(action))
//
//            self.addChild(sprite)
//        }
//
//        if let scene = MenuScene.unarchiveFromFile("MenuScene") as? MenuScene {
//            // Configure the view.
//            let skView = self.view as SKView?
//            skView?.showsFPS = true
//            skView?.showsNodeCount = true
//
//            println("Scene unarchived")
//
//            /* Sprite Kit applies additional optimizations to improve rendering performance */
//            skView?.ignoresSiblingOrder = true
//
//            /* Set the scale mode to scale to fit the window */
//            scene.scaleMode = .AspectFill
//
//            skView?.presentScene(scene)
//        }
//    }
/*
func didBeginContact(contact: SKPhysicsContact) {
    println("didEndContact")
    let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    switch contactMask {
        
    case PhysicsCategory.Border.rawValue | PhysicsCategory.Block.rawValue:
        
        if contact.bodyA.categoryBitMask == PhysicsCategory.Border.rawValue {
            //contact.bodyB.node?.removeFromParent()
        } else {
            //contact.bodyA.node?.removeFromParent()
        }
    case PhysicsCategory.Platform.rawValue | PhysicsCategory.Block.rawValue:
        self.runAction(playPop)
    case PhysicsCategory.Block.rawValue | PhysicsCategory.Block.rawValue:
        self.runAction(playPop)
    default:
        println("contact began")
        // Nobody expects this, so satisfy the compiler and catch
        // ourselves if we do something we didn't plan to
        fatalError("other collision: \(contactMask)")
    }
} */
