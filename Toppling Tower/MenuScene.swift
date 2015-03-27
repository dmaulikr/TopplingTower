//
//  MenuScene.swift
//  Toppling Tower
//
//  Created by Alec Shedelbower on 3/13/15.
//  Copyright (c) 2015 Alec Shedelbower. All rights reserved.
//

import Foundation
import SpriteKit
import CoreMotion

class MenuScene: SKScene, SKPhysicsContactDelegate {
    
    let motionManager: CMMotionManager = CMMotionManager()
    
    func updateGravity() {
        
        if let data = motionManager.accelerometerData {
            self.physicsWorld.gravity = CGVector(dx: data.acceleration.x*4, dy: data.acceleration.y*4)
        }
        
    }
    
    func makeTitleLabel(title: String, fontSize: CGFloat) -> SKLabelNode {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -2)
        let titleNode = SKLabelNode(text: title)
        titleNode.fontName = mainFont
        titleNode.fontColor = colorBlack
        titleNode.fontSize = fontSize
        titleNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)-self.frame.height/8)
        return titleNode
    }
    
    func makeLevelButton(fillColor: SKColor, strokeColor: SKColor, text: String, name: String, yLocation: CGFloat) -> SKNode {
        let buttonNode = SKNode()
        buttonNode.name = name
        
        let blockNode = SKShapeNode(rect: CGRectMake(0, 0, screenWidth-10, 120))//120
        buttonNode.position = CGPointMake(CGRectGetMidX(self.frame)-blockNode.frame.width/2, yLocation)
        buttonNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(blockNode.frame.width, blockNode.frame.height), center: CGPointMake(blockNode.frame.width/2, blockNode.frame.height/2))
        blockNode.fillColor = fillColor
        blockNode.strokeColor = strokeColor
        blockNode.name = "blockNode" + name
        
        let caption = SKLabelNode(text: text)
        caption.name = "captionNode"
        caption.fontName = mainFont
        caption.fontColor = SKColor.blackColor()
        caption.fontSize = 80
        caption.position.x = blockNode.frame.width/2
        caption.position.y = blockNode.frame.height/4
        
        buttonNode.addChild(blockNode)
        buttonNode.addChild(caption)
        return buttonNode
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        let borderSize = CGSize(width: 430, height: self.frame.height)
        let originPoint = CGPoint(x: CGRectGetMidX(self.frame) - screenWidth/1.5, y: CGRectGetMinY(self.frame))
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(origin: originPoint, size: borderSize))
        self.physicsWorld.gravity = CGVectorMake(0, -2)
        self.backgroundColor = SKColor.whiteColor()
        
        UIApplication.sharedApplication().idleTimerDisabled = false
        
        let title = makeTitleLabel("Toppling Towers", fontSize: 60)
        self.addChild(title)
        
        motionManager.startAccelerometerUpdates()
        
        let blockMode1 = makeLevelButton(colorLightOrange, strokeColor: SKColor.blackColor(), text: "Mode 1", name: "blockMode1", yLocation: CGRectGetMidY(self.frame)+200)
        self.addChild(blockMode1)
        let blockMode2 = makeLevelButton(colorLightRed, strokeColor: SKColor.blackColor(), text: "Mode 2", name: "blockMode2", yLocation: CGRectGetMidY(self.frame))
        self.addChild(blockMode2)
        let blockMode3 = makeLevelButton(colorLightYellow, strokeColor: SKColor.blackColor(), text: "Mode 3", name: "blockMode3", yLocation: CGRectGetMidY(self.frame)-200)
        self.addChild(blockMode3)
    }
    
    override func update(currentTime: NSTimeInterval) {
        updateGravity()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */

        let nodeMode1 = self.childNodeWithName("blockMode1")
        let nodeMode2 = self.childNodeWithName("blockMode2")
        let nodeMode3 = self.childNodeWithName("blockMode3")
        
        let blockNode1 = nodeMode1?.childNodeWithName("blockNode*")
        let blockNode2 = nodeMode2?.childNodeWithName("blockNode*")
        let blockNode3 = nodeMode3?.childNodeWithName("blockNode*")
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            var nodes = nodesAtPoint(location)
            
            for node in nodes {
                if node.name == blockNode1?.name {
                    
                    if let scene = Level1Scene.unarchiveFromFile("Level1Scene") as? Level1Scene {
                        // Configure the view.
                        let skView = self.view as SKView?
                        skView?.showsFPS = false
                        skView?.showsNodeCount = false
                        skView?.showsPhysics = false
    
                        println("Scene unarchived")
    
                        /* Sprite Kit applies additional optimizations to improve rendering performance */
                        skView?.ignoresSiblingOrder = true
    
                        /* Set the scale mode to scale to fit the window */
                        scene.scaleMode = .AspectFill
                        
                        let transition = SKTransition.crossFadeWithDuration(1)
                        
                        skView?.presentScene(scene, transition: transition)
                    }

                }
            }
            
            //Add other scenes
            
        }
    }
}

/*
if blockNode1 == nodeAtPoint(location) || CaptionNode1 == nodeAtPoint(location) {
println("\(nodesAtPoint(location))")
if let scene = Level1Scene.unarchiveFromFile("Level1Scene") as? Level1Scene {
// Configure the view.
let skView = self.view as SKView?
skView?.showsFPS = false
skView?.showsNodeCount = false
skView?.showsPhysics = false

println("Scene unarchived")

/* Sprite Kit applies additional optimizations to improve rendering performance */
skView?.ignoresSiblingOrder = true

/* Set the scale mode to scale to fit the window */
scene.scaleMode = .AspectFill

let transition = SKTransition.crossFadeWithDuration(1)

skView?.presentScene(scene, transition: transition)
}
}
*/

/*
if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
// Configure the view.
let skView = self.view as SKView?
skView?.showsFPS = true
skView?.showsNodeCount = true

println("Scene unarchived")

/* Sprite Kit applies additional optimizations to improve rendering performance */
skView?.ignoresSiblingOrder = true

/* Set the scale mode to scale to fit the window */
scene.scaleMode = .AspectFill

skView?.presentScene(scene)
}
*/