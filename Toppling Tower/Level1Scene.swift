//
//  Level1Scene.swift
//  Toppling Tower
//
//  Created by Alec Shedelbower on 3/19/15.
//  Copyright (c) 2015 Alec Shedelbower. All rights reserved.
//

import Foundation
import SpriteKit


class Level1Scene: GameScene, SKPhysicsContactDelegate {
    
    override func didMoveToView(view: SKView) {
        playPop = SKAction.playSoundFileNamed("Bubble_Pop.wav", waitForCompletion: false)
        playTap = SKAction.playSoundFileNamed("Soft_Tap.wav", waitForCompletion: false)
        playPowerUp = SKAction.playSoundFileNamed("PowerUp.wav", waitForCompletion: false)
        playShimmer = SKAction.playSoundFileNamed("Shimmer.wav", waitForCompletion: false)
        playPowerDown = SKAction.playSoundFileNamed("PowerDown.wav", waitForCompletion: false)
        playBurning = SKAction.playSoundFileNamed("Burning.wav", waitForCompletion: false)
        playElectricity = SKAction.playSoundFileNamed("Electricity.wav", waitForCompletion: false)
        
        ResetGame()
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, -6.0)
        self.backgroundColor = SKColor.whiteColor()
        makeScreenBorder()
        
        let platform = makePlatform()
        self.addChild(platform)
        println("platform added to scene")
        
        let scoreLabel = makeScoreLabel()
        self.addChild(scoreLabel)
        
        let label = makeLabel()
        self.addChild(label)
        
        motionManager.startAccelerometerUpdates()
        println("Starting updates")
        
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        if CheckForGameOver() == true {
            
            self.enumerateChildNodesWithName("*") {
                node, stop in
                node.removeFromParent()
            }
            
            if let scene = MenuScene.unarchiveFromFile("MenuScene") as? MenuScene {
                // Configure the view.
                let skView = self.view as SKView?
                //skView?.showsFPS = true
                //skView?.showsNodeCount = true
    
                println("Scene unarchived")
    
                /* Sprite Kit applies additional optimizations to improve rendering performance */
                skView?.ignoresSiblingOrder = true
    
                /* Set the scale mode to scale to fit the window */
                scene.scaleMode = .AspectFill
    
                skView?.presentScene(scene)
            }
        }
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let nodesAtLocation = nodesAtPoint(location)

            switch activePowerUp {
            case .Removal:
                for Node in nodesAtLocation {
                    if Node.name == "block" {
                        println("Should remove block")
                        RemoveBlock(Node as SKShapeNode, method: .Dissolve)
                    }
                }
            case .Flame:
//                for Node in nodesAtLocation {
//                    if Node.name == "block" {
//                        println("Should set fire to block")
//                        RemoveBlock(Node as SKShapeNode, method: .Burn)
//                    }
//                }
                self.enumerateChildNodesWithName("block*") {
                    node, stop in
                    self.RemoveBlock(node as SKShapeNode, method: .Burn)
                }
            case .Spark:
                for node in blocksTouchingPlatform {
                    let block = node as SKShapeNode
                    RemoveBlock(block, method: .Shock)
                    if contains(blocksTouchingPlatform, block) {
                        if let index = find(blocksTouchingPlatform, block){
                            blocksTouchingPlatform.removeAtIndex(index)
                        }
                    }
                }
            default:
                println("No active power up")
            }
        }
    }
    
    
}