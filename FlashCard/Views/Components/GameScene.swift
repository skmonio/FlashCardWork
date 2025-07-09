//
//  GameScene.swift
//  FlashCard
//
//  Created by Stephen Cook on 04/06/2025.
//

import SpriteKit
import SwiftUI

class GameScene: SKScene {
    
    // MARK: - Properties
    var onCardMatched: (() -> Void)?
    var onCardMissed: (() -> Void)?
    var onParticleEffectComplete: (() -> Void)?
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        backgroundColor = UIColor.clear
        physicsWorld.gravity = CGVector(dx: 0, dy: -0.8)
        
        // Debug output
        print("🎮 GameScene didMove to view with size: \(size)")
        
        // Add a simple test node to verify the scene is working
        let testLabel = SKLabelNode(text: "SpriteKit Ready")
        testLabel.fontSize = 16
        testLabel.fontColor = .blue
        testLabel.position = CGPoint(x: size.width/2, y: size.height - 30)
        testLabel.zPosition = 1000
        addChild(testLabel)
        
        // Fade out the test label after 2 seconds
        let wait = SKAction.wait(forDuration: 2.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let remove = SKAction.removeFromParent()
        testLabel.run(SKAction.sequence([wait, fadeOut, remove]))
    }
    
    // MARK: - Particle Effects
    func createSuccessParticles(at position: CGPoint) {
        print("🎆 Creating success particles at: \(position)")
        
        // Create confetti-like particles for successful matches
        let emitter = SKEmitterNode()
        emitter.particleTexture = createSparkParticleTexture()
        emitter.particleBirthRate = 150
        emitter.numParticlesToEmit = 100
        emitter.particleLifetime = 3.0
        emitter.particleLifetimeRange = 1.0
        emitter.emissionAngle = CGFloat.pi / 2
        emitter.emissionAngleRange = CGFloat.pi * 2
        emitter.particleSpeed = 300
        emitter.particleSpeedRange = 150
        emitter.particleScale = 0.5
        emitter.particleScaleRange = 0.3
        emitter.particleColorSequence = SKKeyframeSequence(keyframeValues: [
            UIColor.systemGreen,
            UIColor.systemBlue,
            UIColor.systemPurple,
            UIColor.systemOrange,
            UIColor.systemYellow
        ], times: [0, 0.25, 0.5, 0.75, 1.0])
        emitter.particleAlpha = 1.0
        emitter.particleAlphaRange = 0.5
        emitter.particleRotation = 0
        emitter.particleRotationRange = CGFloat.pi * 2
        
        emitter.position = position
        emitter.zPosition = 100
        addChild(emitter)
        
        print("🎆 Added emitter to scene with \(children.count) total children")
        
        // Remove emitter after particles fade
        let wait = SKAction.wait(forDuration: 5.0)
        let remove = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([wait, remove]))
        
        // Trigger completion callback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.onParticleEffectComplete?()
        }
    }
    
    func createErrorEffect(at position: CGPoint) {
        print("❌ Creating error effect at: \(position)")
        
        // Create red particles for wrong answers
        let particleEmitter = SKEmitterNode()
        particleEmitter.particleTexture = createRedParticleTexture()
        particleEmitter.particleBirthRate = 50
        particleEmitter.numParticlesToEmit = 20
        particleEmitter.particleLifetime = 1.0
        particleEmitter.particleLifetimeRange = 0.5
        particleEmitter.particleSpeed = 100
        particleEmitter.particleSpeedRange = 50
        particleEmitter.particleAlpha = 0.8
        particleEmitter.particleAlphaRange = 0.2
        particleEmitter.particleScale = 1.0
        particleEmitter.particleScaleRange = 0.5
        particleEmitter.particleColor = UIColor.systemRed
        particleEmitter.particleColorBlendFactor = 1.0
        particleEmitter.particleColorBlendFactorRange = 0.3
        particleEmitter.emissionAngle = 0
        particleEmitter.emissionAngleRange = .pi * 2
        particleEmitter.position = position
        particleEmitter.zPosition = 200
        
        addChild(particleEmitter)
        
        // Remove after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            particleEmitter.removeFromParent()
        }
        
        // Add screen shake effect
        let shake = SKAction.sequence([
            SKAction.moveBy(x: 10, y: 0, duration: 0.05),
            SKAction.moveBy(x: -20, y: 0, duration: 0.05),
            SKAction.moveBy(x: 10, y: 0, duration: 0.05)
        ])
        let shake3 = SKAction.repeat(shake, count: 3)
        
        // Apply shake to the scene
        run(shake3)
    }
    
    func createFloatingScore(score: String, at position: CGPoint, color: UIColor = .systemGreen) {
        print("💯 Creating floating score '\(score)' at: \(position)")
        
        let scoreLabel = SKLabelNode(text: score)
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = color
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.position = position
        scoreLabel.zPosition = 200
        
        // Add outline for better visibility
        let outlineLabel = SKLabelNode(text: score)
        outlineLabel.fontSize = 28
        outlineLabel.fontColor = .black
        outlineLabel.fontName = "Helvetica-Bold"
        outlineLabel.position = CGPoint.zero
        outlineLabel.zPosition = -1
        scoreLabel.addChild(outlineLabel)
        
        addChild(scoreLabel)
        
        // Animate the score floating up and fading out
        let moveUp = SKAction.moveBy(x: 0, y: 120, duration: 1.5)
        let fadeOut = SKAction.fadeOut(withDuration: 1.5)
        let scale = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        let remove = SKAction.removeFromParent()
        
        let group = SKAction.group([moveUp, fadeOut])
        let sequence = SKAction.sequence([scale, group, remove])
        
        scoreLabel.run(sequence)
    }
    
    // MARK: - Helper Methods
    private func createRedParticleTexture() -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 8, height: 8))
        let image = renderer.image { context in
            UIColor.systemRed.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: 8, height: 8))
        }
        return SKTexture(image: image)
    }
    
    private func createSparkParticleTexture() -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 8, height: 8))
        let image = renderer.image { context in
            UIColor.systemGreen.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: 8, height: 8))
        }
        return SKTexture(image: image)
    }
    
    // Card flip animation effect
    func animateCardFlip(from startPosition: CGPoint, to endPosition: CGPoint, completion: @escaping () -> Void) {
        let cardSprite = SKSpriteNode(color: UIColor.systemBlue, size: CGSize(width: 100, height: 140))
        cardSprite.position = startPosition
        cardSprite.zPosition = 50
        
        addChild(cardSprite)
        
        // Create flip animation
        let scaleX = SKAction.scaleX(to: 0, duration: 0.15)
        let move = SKAction.move(to: endPosition, duration: 0.3)
        let scaleBackX = SKAction.scaleX(to: 1, duration: 0.15)
        let remove = SKAction.removeFromParent()
        
        let flipSequence = SKAction.sequence([scaleX, scaleBackX])
        let group = SKAction.group([flipSequence, move])
        let fullSequence = SKAction.sequence([group, remove])
        
        cardSprite.run(fullSequence) {
            completion()
        }
    }
}

// MARK: - SKAction Extensions
extension SKAction {
    static func shake(duration: TimeInterval, amplitudeX: Float, amplitudeY: Float) -> SKAction {
        let numberOfShakes = duration / 0.04
        var actions: [SKAction] = []
        
        for _ in 0..<Int(numberOfShakes) {
            let moveX = Float.random(in: -amplitudeX...amplitudeX)
            let moveY = Float.random(in: -amplitudeY...amplitudeY)
            let shakeAction = SKAction.moveBy(x: CGFloat(moveX), y: CGFloat(moveY), duration: 0.02)
            let reverseAction = shakeAction.reversed()
            actions.append(shakeAction)
            actions.append(reverseAction)
        }
        
        return SKAction.sequence(actions)
    }
}

// MARK: - SwiftUI Integration
struct SpriteKitGameView: UIViewRepresentable {
    let scene: GameScene
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        
        // Configure the view properly
        view.backgroundColor = UIColor.clear
        view.allowsTransparency = true
        view.ignoresSiblingOrder = true
        view.showsFPS = false
        view.showsNodeCount = false
        
        // Ensure scene is properly sized before presenting
        if scene.size.width == 0 || scene.size.height == 0 {
            scene.size = CGSize(width: 400, height: 400)
        }
        
        // Present the scene
        view.presentScene(scene)
        
        print("🎮 SpriteKitGameView created with scene size: \(scene.size)")
        
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        // Ensure scene is still presented
        if uiView.scene != scene {
            uiView.presentScene(scene)
            print("🎮 Re-presented scene in updateUIView")
        }
    }
} 