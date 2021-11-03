//
//  BubblesView.swift
//  CoinvisionTV
//
//  Created by Jacob Davis on 10/27/21.
//

import SwiftUI
import SpriteKit
import SDWebImageSwiftUI

let SPRITE_KIT_VIEWPORT = CGSize(width: 1800, height: 860)

struct BubblesView: View {
    
    var scene: SKScene {
        let scene = BubblesScene(marketItems: $dataProvider.marketItems)
        scene.size = SPRITE_KIT_VIEWPORT
        scene.scaleMode = .fill
        scene.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        return scene
    }
    
    @EnvironmentObject var dataProvider: DataProvider

    var body: some View {
        
        SpriteView(scene: scene)
            .frame(width: SPRITE_KIT_VIEWPORT.width, height: SPRITE_KIT_VIEWPORT.height)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(dataProvider.overallMarket() > .zero ? .green : .red, lineWidth: 6)
            )
            .environmentObject(dataProvider)
    }
    
}

struct BubblesView_Previews: PreviewProvider {
    static var previews: some View {
        BubblesView()
    }
}

class BubblesScene: SKScene {
    
    @Binding var marketItems: [MarketItem]
    var physicsField: SKFieldNode?
    var bubbleNodes: Set<BubbleNode> = []
    
    init(marketItems: Binding<[MarketItem]>) {
        _marketItems = marketItems
        super.init(size: SPRITE_KIT_VIEWPORT)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupPhysicsFieldNode() {
        self.physicsField?.removeFromParent()
        self.physicsField = SKFieldNode.noiseField(withSmoothness: 0.5, animationSpeed: 0.5)
        self.physicsField?.position = CGPoint(x: SPRITE_KIT_VIEWPORT.width/2, y: SPRITE_KIT_VIEWPORT.height/2)
        self.physicsField?.strength = 0.1
        if let physicsField = physicsField {
            addChild(physicsField)
        }
    }
    
    override func didMove(to view: SKView) {

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.gravity = .zero

        setupPhysicsFieldNode()

        for m in marketItems {
            SDWebImageManager.shared.loadImage(with: URL(string: m.image), options: [], progress: nil) { image, data, err, cacheType, success, url in
                DispatchQueue.main.async { [weak self] in
                    if let image = image {
                        let t = SKTexture(image: image)
                        self?.createBubble(id: m.id, symbol: m.symbol, percentage: m.priceChangePercentage24H ?? .zero, texture: t)
                    } else {
                        self?.createBubble(id: m.id, symbol: m.symbol, percentage: m.priceChangePercentage24H ?? .zero, texture: nil)
                    }
                }
            }
        }
        
        let updateBubblesBlock = SKAction.run {
            
            // update and add new nodes
            
            for m in self.marketItems {
                if let node = self.bubbleNodes.first(where: { $0.name == m.id }) {
                    node.update(id: m.id, symbol: m.symbol, percentage: m.priceChangePercentage24H ?? .zero)
                } else {
                    SDWebImageManager.shared.loadImage(with: URL(string: m.image), options: [], progress: nil) { image, data, err, cacheType, success, url in
                        DispatchQueue.main.async { [weak self] in
                            if let image = image {
                                let t = SKTexture(image: image)
                                self?.createBubble(id: m.id, symbol: m.symbol, percentage: m.priceChangePercentage24H ?? .zero, texture: t)
                            } else {
                                self?.createBubble(id: m.id, symbol: m.symbol, percentage: m.priceChangePercentage24H ?? .zero, texture: nil)
                            }
                        }
                    }
                    
                }
            }

            // remove nodes not in market items list
            for (_, v) in self.bubbleNodes.enumerated() {
                if let _ = self.marketItems.first(where: { $0.id == v.name }) {
                    continue
                } else {
                    v.removeFromParent()
                    self.bubbleNodes.remove(v)
                }
            }

            self.setupPhysicsFieldNode()
        }

        run(SKAction.repeatForever(SKAction.sequence([ SKAction.wait(forDuration: 30), updateBubblesBlock ])))
        
    }
    
    func createBubble(id: String, symbol: String, percentage: Double, texture: SKTexture? = nil) {
        let bubble = BubbleNode(id: id, symbol: symbol, percentage: percentage, texture: texture)
        bubble.position = CGPoint(x: CGFloat.random(in: 100...SPRITE_KIT_VIEWPORT.width-100), y: CGFloat.random(in: 100...SPRITE_KIT_VIEWPORT.height-100))
        self.bubbleNodes.insert(bubble)
        self.addChild(bubble)
        bubble.applyImpulse()
    }
    
}
