//
//  Battery.swift
//  Battery Builder
//
//  Created by Stephen Hetterich on 8/3/16.
//  Copyright © 2016 Stephen Hetterich. All rights reserved.
//

import SpriteKit

class Battery: SKNode {
    
    private let chargeFill: SKSpriteNode = SKSpriteNode(imageNamed: "batteryFill")
    private let chargeMask: SKCropNode = SKCropNode()
    private let outline: SKSpriteNode = SKSpriteNode(imageNamed: "batteryOutline")
    private var coin: SKSpriteNode?
    
    private(set) var size: CGSize!
    
    internal let good: CGFloat = 0.65
    internal let great: CGFloat = 0.93
    internal let perfect: CGFloat = 0.99

    internal let chargeTime: TimeInterval //In percentage per second
    internal let chargingActionKey: String = "charging"
    internal let coinProb: Double = 0.05
    
    private(set) var isCharging = false
    private(set) var overcharged = false
    
    private var collectedCoin = false
    
    init(chargeSpeed speed: Double) {
        chargeTime = 100 / speed
        
        super.init()
        chargeFill.zPosition = 0
        chargeMask.addChild(chargeFill)
        chargeMask.zPosition = 1
        chargeMask.maskNode = SKSpriteNode(color: UIColor.red, size: CGSize(width: chargeFill.frame.size.width, height: chargeFill.frame.size.height))
        if let maskNode = chargeMask.maskNode as? SKSpriteNode {
            maskNode.anchorPoint = CGPoint(x: 1, y: maskNode.anchorPoint.y)
            maskNode.position = CGPoint(x: -0.5 * chargeFill.frame.size.width, y: 0)
        }
        self.addChild(chargeMask)
        outline.zPosition = 2
        self.addChild(outline)
        if (Double(arc4random_uniform(100)) + 1) * 0.01 <= coinProb {
            self.coin = SKSpriteNode(imageNamed: "coin")
            let x = CGFloat(Double(arc4random_uniform(80) + 1) * 0.01 + 0.10) * chargeFill.frame.size.width - 0.5 * chargeFill.frame.size.width
            if let coin = self.coin {
                coin.position = CGPoint(x: x, y: 0)
                coin.zPosition = 4
                addChild(coin)
            }
        }
        
        self.size = CGSize(width: self.calculateAccumulatedFrame().width, height: self.calculateAccumulatedFrame().height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func charge() {
        if let maskNode = chargeMask.maskNode as? SKSpriteNode {
            maskNode.run(SKAction.sequence([SKAction.move(to: CGPoint(x: 0.5 * chargeFill.frame.size.width, y: 0), duration: chargeTime), SKAction.customAction(withDuration: 0, actionBlock: {_,_ in 
                self.overcharged = true
            })]), withKey: chargingActionKey)
            isCharging = true
        }
    }
    
    func stopCharging() {
        if let maskNode = chargeMask.maskNode as? SKSpriteNode {
            maskNode.removeAction(forKey: chargingActionKey)
            isCharging = false
        }
    }
    
    func chargeQuality() -> ChargeQuality {
        if let maskNode = chargeMask.maskNode as? SKSpriteNode {
            let percentFilled = (maskNode.position.x + chargeFill.frame.width / 2.0) / chargeFill.frame.width
            if percentFilled < good {
                return .bad
            } else if percentFilled < great {
                return .good
            } else if percentFilled < perfect {
                return .great
            } else if percentFilled <= 1 {
                return .perfect
            }
        }
        return .bad
    }
    
    func gotCoin() -> Bool {
        if let coin = self.coin, let maskNode = chargeMask.maskNode as? SKSpriteNode, !collectedCoin {
            if coin.contains(maskNode.position) {
                collectedCoin = true
                return true
            }
        }
        return false
    }
    
    func collectCoin() {
        if let coin = self.coin {
            let disappear = SKAction.group([SKAction.scale(to: 0, duration: 0.3), SKAction.rotate(byAngle: 2 * CGFloat(M_PI), duration: 0.3)])
            let collect = SKAction.sequence([SKAction.scale(to: 1.25, duration: 0.2), disappear])
            coin.run(collect, completion: {
                coin.removeFromParent()
            })
            
        }
    }
}
