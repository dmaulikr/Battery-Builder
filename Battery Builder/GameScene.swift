//
//  GameScene.swift
//  Battery Builder
//
//  Created by Stephen Hetterich on 8/3/16.
//  Copyright © 2016 Stephen Hetterich. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    internal let currentBatteryKey = "current"
    internal let formerBatteryKey = "former"
    internal let nextBatteryKey = "next"
    internal let minSpeed: Double = 10
    internal let maxSpeed: Double = 200
    
    private var score: Int = 0 {
        didSet {
            scoreNode.text = "Score: \(score)"
        }
    }
    private var multiplier: Int = 1 {
        didSet {
            multiplierNode.text = "Multiplier: \(multiplier)"
        }
    }
    private var gameOver = false
    
    private var scoreNode: SKLabelNode = SKLabelNode()
    private var multiplierNode: SKLabelNode = SKLabelNode()
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.gray
        
        let currentBattery = Battery(chargeSpeed: minSpeed)
        currentBattery.setScale(0.65 * self.size.width / currentBattery.size.width)
        currentBattery.alpha = 0.0
        currentBattery.name = currentBatteryKey
        self.addChild(currentBattery)
        currentBattery.run(SKAction.fadeIn(withDuration: 1.0), completion: {
            currentBattery.charge()
        })
        
        let nextBattery = Battery(chargeSpeed: 10.0)
        nextBattery.setScale(0.65 * self.size.width / nextBattery.size.width)
        nextBattery.alpha = 0.0
        nextBattery.name = nextBatteryKey
        nextBattery.position = CGPoint(x: 0, y: -0.7 * nextBattery.size.height)
        self.addChild(nextBattery)
        
        scoreNode.text = "Score: \(score)"
        scoreNode.position = CGPoint(x: 0, y: -0.20 * self.size.height)
        scoreNode.alpha = 0.0
        self.addChild(scoreNode)
        scoreNode.run(SKAction.fadeIn(withDuration: 1.0))
        
        multiplierNode.text = "Multiplier: \(multiplier)"
        multiplierNode.position = CGPoint(x: 0, y: -0.25 * self.size.height)
        multiplierNode.alpha = 0.0
        self.addChild(multiplierNode)
        multiplierNode.run(SKAction.fadeIn(withDuration: 1.0))
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameOver {
            if let battery = childNode(withName: currentBatteryKey) as? Battery {
                if battery.isCharging {
                    if battery.gotCoin() {
                        battery.collectCoin()
                        score = score + 5 * multiplier
                        return
                    } else {
                        var chargeQuality: ChargeQuality
                        if battery.overcharged {
                            chargeQuality = .bad
                        } else {
                            battery.stopCharging()
                            battery.name = formerBatteryKey
                            chargeQuality = battery.chargeQuality()
                        }
                        switch chargeQuality {
                        case .bad:
                            multiplier = 1
                            endGame()
                            return
                        case .good:
                            multiplier = 1
                            score = score + 1 * multiplier
                        case .great:
                            multiplier = multiplier + 1
                            score = score + 1 * multiplier
                        case .perfect:
                            multiplier = multiplier + 10
                            score = score + 1 * multiplier
                        }
                    }
                    if let battery = childNode(withName: nextBatteryKey) as? Battery {
                        let moveIn = SKAction.group([SKAction.move(to: CGPoint.zero, duration: 0.5), SKAction.fadeIn(withDuration: 0.5)])
                        moveIn.timingMode = .easeInEaseOut
                        battery.run(moveIn, completion: {
                            battery.name = self.currentBatteryKey
                            let nextBattery = Battery(chargeSpeed: self.minSpeed + Double(self.score))
                            nextBattery.setScale(0.65 * self.size.width / nextBattery.size.width)
                            nextBattery.alpha = 0.0
                            nextBattery.name = self.nextBatteryKey
                            nextBattery.position = CGPoint(x: 0, y: -0.7 * nextBattery.size.height)
                            self.addChild(nextBattery)
                            battery.charge()
                        })
                    }
                    enumerateChildNodes(withName: formerBatteryKey, using: {formerBattery,_ in
                        if let battery = formerBattery as? Battery {
                            let moveOut = SKAction.group([SKAction.move(by: CGVector(dx: 0, dy: 0.7 * battery.size.height),duration: 0.5), SKAction.fadeAlpha(to: battery.alpha * 0.5, duration: 0.5)])
                            moveOut.timingMode = .easeInEaseOut
                            battery.run(moveOut, completion: {
                                if battery.position.y - 0.5 * battery.size.height > 0.5 * self.size.height {
                                    battery.removeFromParent()
                                }
                            })
                        }
                    })
                }
            }
        }
        for t in touches {
            touchDown(atPoint: t.location(in: self))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            touchMoved(toPoint: t.location(in: self))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            touchUp(atPoint: t.location(in: self))
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            touchUp(atPoint: t.location(in: self))
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func endGame() {
        gameOver = true
        
    }
}
