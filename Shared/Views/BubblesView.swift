//
//  BubblesView.swift
//  CoinvisionTV
//
//  Created by Jacob Davis on 10/27/21.
//

import SwiftUI
import SpriteKit
import SDWebImageSwiftUI
import MapKit

//let SPRITE_KIT_VIEWPORT = CGSize(width: 1800/2, height: 860/1.5)

struct BubblesView: View {
    
    @State private var scenes: [BubblesScene] = []
    
    var scene: SKScene {
        if let scene = scenes.first {
            return scene
        } else {
            let scene = BubblesScene(marketItems: $dataProvider.marketItems)
            scene.scaleMode = .resizeFill
            scene.backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
            DispatchQueue.main.async {
                scenes.append(scene)
            }
            return scene
        }
    }
    
    @EnvironmentObject var dataProvider: DataProvider

    var body: some View {
        
        VStack(alignment: .center) {
            GeometryReader { geometry in
                SpriteView(scene: scene)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(dataProvider.overallMarket() > .zero ? .green : .red, lineWidth: 6)
                    )
                    .environmentObject(dataProvider)
            }
        }
        #if os(tvOS)
        .padding(0)
        #else
        .padding(16)
        #endif

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
    
    func prefix() -> Int {
        let sw = self.view?.frame.width ?? .zero
        if sw < 800 {
            return 35
        } else if sw < 900 {
            return 50
        } else if sw < 1280 {
            return 65
        }
        return 100
    }
    
    var bubbleModels: [BubbleModel] {
        
        let sw = self.view?.frame.width ?? .zero
        
        let negatives = self.marketItems.prefix(prefix())
            .filter({ !$0.isUp() })
            .sorted(by: { ($0.priceChangePercentage24H ?? .zero) < ($1.priceChangePercentage24H ?? .zero) })
        
        let nmax = abs(negatives.first?.priceChangePercentage24H ?? 0.0)
        let nmin = abs(negatives.last?.priceChangePercentage24H ?? 0.0)
        
        let positives = self.marketItems.prefix(prefix())
            .filter({ $0.isUp() })
            .sorted(by: { ($0.priceChangePercentage24H ?? .zero) > ($1.priceChangePercentage24H ?? .zero) })
        
        let pmax = positives.first?.priceChangePercentage24H ?? 0.0
        let pmin = positives.last?.priceChangePercentage24H ?? 0.0

        let negativeBubbleModels = negatives
            .map({ BubbleModel(id: $0.id, symbol: $0.symbol,
                               normalizedPercentage: abs($0.priceChangePercentage24H ?? .zero).normalize(min: nmin, max: nmax),
                               percentage: $0.priceChangePercentage24H ?? .zero,
                               isUp: $0.isUp(), image: $0.image, radiusModifier: sw > 1280 ? 1.0 : 0.25)
            })
        
        let positiveBubbleModels = positives
            .map({ BubbleModel(id: $0.id, symbol: $0.symbol,
                               normalizedPercentage: ($0.priceChangePercentage24H ?? .zero).normalize(min: pmin, max: pmax),
                               percentage: $0.priceChangePercentage24H ?? .zero,
                               isUp: $0.isUp(), image: $0.image, radiusModifier: sw > 1280 ? 1.0 : 0.25)
            })
        
        var retval = [BubbleModel]()
        retval.append(contentsOf: negativeBubbleModels)
        retval.append(contentsOf: positiveBubbleModels)
        return retval
    }
    
    init(marketItems: Binding<[MarketItem]>) {
        _marketItems = marketItems
        super.init(size: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupPhysics() {
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.gravity = .zero
        
        self.physicsField?.removeFromParent()
        self.physicsField = SKFieldNode.noiseField(withSmoothness: 0.5, animationSpeed: 0.5)
        self.physicsField?.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.physicsField?.strength = 0.1
        if let physicsField = physicsField {
            addChild(physicsField)
        }
    }
    
    fileprivate func setupBubbles() {
        
        self.removeAllChildren()
        self.removeAllActions()
        self.bubbleNodes.removeAll()
        
        for m in bubbleModels {
            SDWebImageManager.shared.loadImage(with: URL(string: m.image), options: [], progress: nil) { image, data, err, cacheType, success, url in
                DispatchQueue.main.async { [weak self] in
                    if let image = image {
                        let t = SKTexture(image: image)
                        self?.createBubble(bubbleModel: m, texture: t)
                    } else {
                        self?.createBubble(bubbleModel: m, texture: nil)
                    }
                }
            }
        }
        
        let updateBubblesBlock = SKAction.run {

            // update and add new nodes

            for m in self.bubbleModels {
                if let node = self.bubbleNodes.first(where: { $0.name == m.id }) {
                    node.update(bubbleModel: m)
                } else {
                    SDWebImageManager.shared.loadImage(with: URL(string: m.image), options: [], progress: nil) { image, data, err, cacheType, success, url in
                        DispatchQueue.main.async { [weak self] in
                            if let image = image {
                                let t = SKTexture(image: image)
                                self?.createBubble(bubbleModel: m, texture: t)
                            } else {
                                self?.createBubble(bubbleModel: m, texture: nil)
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

            self.setupPhysics()
        }

        run(SKAction.repeatForever(SKAction.sequence([ SKAction.wait(forDuration: 30), updateBubblesBlock ])))
        
    }
    
    override func didMove(to view: SKView) {
        
        #if os(macOS)
        self.view?.window?.delegate = self
        #endif

        setupPhysics()
        setupBubbles()
        
    }
    
    func createBubble(bubbleModel: BubbleModel, texture: SKTexture? = nil) {
        let bubble = BubbleNode(bubbleModel: bubbleModel, texture: texture)
        bubble.position = CGPoint(x: CGFloat.random(in: 100...size.width-100), y: CGFloat.random(in: 100...size.height-100))
        self.bubbleNodes.insert(bubble)
        self.addChild(bubble)
        bubble.applyImpulse()
    }
    
}

#if os(macOS)
extension BubblesScene: NSWindowDelegate {
    
    func windowWillStartLiveResize(_ notification: Notification) {
        print("Started")
    }
    
    func windowDidEndLiveResize(_ notification: Notification) {
        setupPhysics()
        setupBubbles()
    }
    
}
#endif

struct BubbleModel {
    
    let id: String
    let symbol: String
    let normalizedPercentage: Double
    let percentage: Double
    let isUp: Bool
    let image: String
    let radiusModifier: Double
    
    init(id: String, symbol: String, normalizedPercentage: Double,
         percentage: Double, isUp: Bool, image: String,
         radiusModifier: Double) {
        self.id = id
        self.symbol = symbol
        self.normalizedPercentage = normalizedPercentage
        self.percentage = percentage
        self.isUp = isUp
        self.image = image
        self.radiusModifier = radiusModifier
    }
    
}
