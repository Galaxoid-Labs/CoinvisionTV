//
//  BubbleNode.swift
//  CoinvisionTV
//
//  Created by Jacob Davis on 10/28/21.
//

import Foundation
import SpriteKit

class BubbleNode: SKNode {
    
    let baseRadius: CGFloat = 35
    let maxRadius: CGFloat = 300
    let maxLabelSize: CGFloat = 48
    var shapeNode: SKShapeNode
    var labelContainer: SKNode
    var symbolLabel: SKLabelNode
    var percentageLabel: SKLabelNode
    var spriteNode: SKSpriteNode
    
    init(id: String, symbol: String, percentage: Double, texture: SKTexture? = nil) {
        
        let percentageString = percentage.formatted(.number.precision(.fractionLength(2)))

        var radius = baseRadius + (abs(percentage) * 2)
        
        if radius > maxRadius {
            radius = maxRadius
        }
        
        let strokeSize = (radius / 4) * 0.25
        let strokeColorAlpha = strokeSize * 0.2
        var symbolLablSize = 14 + abs(percentage)
        
        if symbolLablSize > maxLabelSize {
            symbolLablSize = maxLabelSize
        }
        
        var percentageLableSize = symbolLablSize * 0.65
        
        if symbol.count > 4 {
            symbolLablSize *= 0.65
            percentageLableSize = symbolLablSize - 1
        }
        
        self.shapeNode = SKShapeNode(circleOfRadius: radius)
        self.labelContainer = SKNode()
        self.symbolLabel = SKLabelNode(text: symbol.uppercased())
        self.percentageLabel = SKLabelNode(text: percentage > .zero ? "+\(percentageString)%" : "\(percentageString)%")
        self.spriteNode = SKSpriteNode()

        super.init()
        
        self.name = id
        self.shapeNode.strokeColor = percentage > .zero ? .systemGreen : .systemRed
        self.shapeNode.lineWidth = strokeSize
        self.physicsBody = createPhysicsBody(withRadius: radius)
        
        self.addChild(self.shapeNode)
        self.addChild(labelContainer)
        
        self.symbolLabel.fontName = "SFUI-Regular"
        self.symbolLabel.fontSize = symbolLablSize
        self.symbolLabel.position.y = symbolLabel.fontSize / 2
        self.symbolLabel.verticalAlignmentMode = .center
        self.symbolLabel.horizontalAlignmentMode = .center
        
        self.labelContainer.addChild(self.symbolLabel)
        
        self.percentageLabel = SKLabelNode(text: percentage > .zero ? "+\(percentageString)%" : "\(percentageString)%")
        self.percentageLabel.fontSize = percentageLableSize
        self.percentageLabel.fontName = "SFUI-Regular"
        self.percentageLabel.fontColor = .systemGray
        self.percentageLabel.verticalAlignmentMode = .center
        self.percentageLabel.horizontalAlignmentMode = .center
        self.percentageLabel.position.y = -(self.percentageLabel.fontSize / 2)
        self.labelContainer.addChild(self.percentageLabel)
        
        if let texture = texture {
            let iconSize = CGSize(width: self.shapeNode.frame.size.width / 3, height: self.shapeNode.frame.size.height / 3)
            self.spriteNode = SKSpriteNode(texture: texture)
            self.spriteNode.size = iconSize
            self.spriteNode.position.y = -(iconSize.height / 1.5)
            self.labelContainer.position.y = (iconSize.height / 2.5)
            self.addChild(self.spriteNode)
        }

        self.alpha = strokeColorAlpha
        
    }
    
    func update(id: String, symbol: String, percentage: Double) {
        
        let percentageString = percentage.formatted(.number.precision(.fractionLength(2)))
        
        var radius = baseRadius + (abs(percentage) * 2)
        
        if radius > maxRadius {
            radius = maxRadius
        }
        
        let strokeSize = (radius / 4) * 0.25
        let strokeColorAlpha = strokeSize * 0.2
        var symbolLablSize = 14 + abs(percentage)
        
        if symbolLablSize > maxLabelSize {
            symbolLablSize = maxLabelSize
        }
        
        var percentageLableSize = symbolLablSize * 0.65
        
        if symbol.count > 4 {
            symbolLablSize *= 0.65
            percentageLableSize = symbolLablSize - 1
        }
        
        self.shapeNode.removeFromParent()
        self.shapeNode = SKShapeNode(circleOfRadius: radius)
        
        self.shapeNode.strokeColor = percentage > .zero ? .systemGreen : .systemRed
        self.shapeNode.lineWidth = strokeSize
        
        let cv = self.physicsBody?.velocity ?? .zero
        
        self.physicsBody = createPhysicsBody(withRadius: radius)
        
        self.physicsBody?.velocity = cv
        
        self.insertChild(self.shapeNode, at: 0)
        
        self.symbolLabel.text = symbol.uppercased()
        self.symbolLabel.fontSize = symbolLablSize
        self.symbolLabel.position.y = symbolLabel.fontSize / 2
        
        self.percentageLabel.text = percentage > .zero ? "+\(percentageString)%" : "\(percentageString)%"
        self.percentageLabel.fontSize = percentageLableSize
        self.percentageLabel.position.y = -(self.percentageLabel.fontSize / 2)
        
        if let _ = self.spriteNode.texture {
            let iconSize = CGSize(width: self.shapeNode.frame.size.width / 3, height: self.shapeNode.frame.size.height / 3)
            self.spriteNode.size = iconSize
            self.spriteNode.position.y = -(iconSize.height / 1.5)
            self.labelContainer.position.y = (iconSize.height / 2.5)
        }

        self.alpha = strokeColorAlpha
        
        if ((self.physicsBody?.isResting) != nil) {
            applyImpulse()
        }

    }
    
    fileprivate func createPhysicsBody(withRadius radius: CGFloat) -> SKPhysicsBody {
        let physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody.friction = 0
        physicsBody.restitution = 0.5
        physicsBody.linearDamping = 0.2
        return physicsBody
    }
    
    func applyImpulse() {
        self.physicsBody?.applyImpulse(CGVector(dx: CGFloat.random(in: -5...5), dy: CGFloat.random(in: -5...5)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
