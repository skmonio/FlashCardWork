//
//  CompletionCelebrationScene.swift
//  FlashCard
//
//  Created by Stephen Cook on 04/06/2025.
//

import SpriteKit
import SwiftUI

class CompletionCelebrationScene: SKScene {
    
    // MARK: - Properties
    private var celebrationActive = false
    private var trophyNode: SKSpriteNode?
    private var completionLabel: SKLabelNode?
    private var scoreLabel: SKLabelNode?
    private var percentageLabel: SKLabelNode?
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        backgroundColor = UIColor.clear
        physicsWorld.gravity = CGVector(dx: 0, dy: -0.3)
        
        print("🏆 CompletionCelebrationScene didMove to view with size: \(size)")
    }
    
    // MARK: - Celebration Animation
    func startCelebration(score: Int, total: Int, gameTitle: String = "Game") {
        guard !celebrationActive else { 
            print("🏆 Celebration already active, skipping")
            return 
        }
        celebrationActive = true
        
        print("🎉 Starting completion celebration - Score: \(score)/\(total)")
        print("🏆 Scene size: \(size), children count before: \(children.count)")
        
        let percentage = total > 0 ? Int((Double(score) / Double(total)) * 100) : 0
        
        // Clear any existing nodes
        removeAllChildren()
        
        // Ensure scene has proper size
        if size.width == 0 || size.height == 0 {
            size = CGSize(width: 400, height: 600)
            print("🏆 Set default scene size: \(size)")
        }
        
        // Start celebration sequence
        performCelebrationSequence(score: score, total: total, percentage: percentage, gameTitle: gameTitle)
    }
    
    private func performCelebrationSequence(score: Int, total: Int, percentage: Int, gameTitle: String) {
        // Step 1: Confetti burst from multiple points
        createConfettiBurst()
        
        // Step 2: Fade in trophy (delayed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.createTrophyAppearance(percentage: percentage)
        }
        
        // Step 3: Animate completion text (delayed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.createCompletionText(gameTitle: gameTitle)
        }
        
        // Step 4: Animate score (delayed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.createScoreAnimation(score: score, total: total)
        }
        
        // Step 5: Animate percentage with celebration effect (delayed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.createPercentageAnimation(percentage: percentage)
        }
        
        // Step 6: Final celebration burst (delayed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.createFinalCelebration(percentage: percentage)
        }
    }
    
    // MARK: - Animation Components
    
    private func createConfettiBurst() {
        print("🎊 Creating confetti burst with scene size: \(size)")
        
        // Create multiple confetti emitters from different positions
        let positions = [
            CGPoint(x: size.width * 0.1, y: size.height * 0.9),
            CGPoint(x: size.width * 0.5, y: size.height * 0.9),
            CGPoint(x: size.width * 0.9, y: size.height * 0.9)
        ]
        
        for (index, position) in positions.enumerated() {
            let emitter = createConfettiEmitter()
            emitter.position = position
            addChild(emitter)
            
            print("🎊 Added confetti emitter \(index + 1) at position: \(position)")
            
            // Remove emitter after particles fade
            let wait = SKAction.wait(forDuration: 8.0)
            let remove = SKAction.removeFromParent()
            emitter.run(SKAction.sequence([wait, remove]))
        }
        
        print("🎊 Total children after confetti: \(children.count)")
    }
    
    private func createConfettiEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = createConfettiTexture()
        emitter.particleBirthRate = 300
        emitter.numParticlesToEmit = 250
        emitter.particleLifetime = 5.0
        emitter.particleLifetimeRange = 2.5
        emitter.emissionAngle = CGFloat.pi / 2
        emitter.emissionAngleRange = CGFloat.pi / 2
        emitter.particleSpeed = 500
        emitter.particleSpeedRange = 300
        emitter.particleScale = 0.6
        emitter.particleScaleRange = 0.4
        emitter.particleRotation = 0
        emitter.particleRotationRange = CGFloat.pi * 2
        emitter.particleRotationSpeed = 4.0
        
        // More vibrant rainbow colors for confetti
        emitter.particleColorSequence = SKKeyframeSequence(keyframeValues: [
            UIColor.systemRed,
            UIColor.systemOrange,
            UIColor.systemYellow,
            UIColor.systemGreen,
            UIColor.systemBlue,
            UIColor.systemPurple,
            UIColor.systemPink,
            UIColor.systemTeal
        ], times: [0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 1.0])
        
        emitter.particleAlpha = 1.0
        emitter.particleAlphaRange = 0.2
        emitter.zPosition = 50
        
        print("🎊 Created confetti emitter with birth rate: \(emitter.particleBirthRate)")
        
        return emitter
    }
    
    private func createTrophyAppearance(percentage: Int) {
        print("🏆 Creating trophy appearance for \(percentage)%")
        
        // Choose trophy icon based on performance
        let trophyColor: UIColor
        let trophyScale: CGFloat
        
        if percentage >= 90 {
            trophyColor = UIColor.systemYellow // Gold
            trophyScale = 1.5 // Increased from 1.0
        } else if percentage >= 70 {
            trophyColor = UIColor.lightGray // Silver
            trophyScale = 1.3 // Increased from 0.9
        } else {
            trophyColor = UIColor.systemBrown // Bronze
            trophyScale = 1.1 // Increased from 0.8
        }
        
        // Create trophy node
        trophyNode = createTrophySprite(color: trophyColor)
        guard let trophy = trophyNode else { return }
        
        trophy.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        trophy.alpha = 0
        trophy.setScale(0.1)
        trophy.zPosition = 100
        addChild(trophy)
        
        print("🏆 Added trophy at position: \(trophy.position)")
        
        // More dramatic appearance animation
        let fadeIn = SKAction.fadeIn(withDuration: 0.4)
        let scaleUp = SKAction.scale(to: trophyScale, duration: 0.6)
        scaleUp.timingMode = .easeOut
        
        // Add a bounce effect
        let bounce = SKAction.sequence([
            SKAction.scale(to: trophyScale * 1.2, duration: 0.1),
            SKAction.scale(to: trophyScale, duration: 0.1)
        ])
        
        let group = SKAction.group([fadeIn, scaleUp])
        let complete = SKAction.sequence([group, bounce])
        trophy.run(complete)
        
        // Add sparkle effect around trophy
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.createSparkleEffect(around: trophy.position)
        }
    }
    
    private func createCompletionText(gameTitle: String) {
        completionLabel = SKLabelNode(text: "\(gameTitle) Complete! 🎉")
        guard let label = completionLabel else { return }
        
        label.fontSize = 32
        label.fontColor = UIColor.systemBlue
        label.fontName = "Helvetica-Bold"
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        label.alpha = 0
        label.setScale(0.5)
        label.zPosition = 100
        
        // Add black outline for better visibility
        let outlineLabel = SKLabelNode(text: "\(gameTitle) Complete! 🎉")
        outlineLabel.fontSize = 32
        outlineLabel.fontColor = .black
        outlineLabel.fontName = "Helvetica-Bold"
        outlineLabel.position = CGPoint.zero
        outlineLabel.zPosition = -1
        label.addChild(outlineLabel)
        
        addChild(label)
        
        // Bouncy fade-in animation
        let fadeIn = SKAction.fadeIn(withDuration: 0.4)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.5)
        scaleUp.timingMode = .easeOut
        
        let group = SKAction.group([fadeIn, scaleUp])
        label.run(group)
    }
    
    private func createScoreAnimation(score: Int, total: Int) {
        scoreLabel = SKLabelNode(text: "Score: \(score) / \(total)")
        guard let label = scoreLabel else { return }
        
        label.fontSize = 24
        label.fontColor = UIColor.systemGreen
        label.fontName = "Helvetica-Bold"
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        label.alpha = 0
        label.zPosition = 100
        
        // Add outline
        let outlineLabel = SKLabelNode(text: "Score: \(score) / \(total)")
        outlineLabel.fontSize = 24
        outlineLabel.fontColor = .black
        outlineLabel.fontName = "Helvetica-Bold"
        outlineLabel.position = CGPoint.zero
        outlineLabel.zPosition = -1
        label.addChild(outlineLabel)
        
        addChild(label)
        
        // Quick snap-in animation
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let scaleUp = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        
        let group = SKAction.group([fadeIn, scaleUp])
        label.run(group)
    }
    
    private func createPercentageAnimation(percentage: Int) {
        percentageLabel = SKLabelNode(text: "\(percentage)%")
        guard let label = percentageLabel else { return }
        
        // Color based on performance
        let color: UIColor
        if percentage >= 90 {
            color = UIColor.systemGreen
        } else if percentage >= 70 {
            color = UIColor.systemOrange
        } else {
            color = UIColor.systemRed
        }
        
        label.fontSize = 48
        label.fontColor = color
        label.fontName = "Helvetica-Bold"
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.35)
        label.alpha = 0
        label.setScale(0.1)
        label.zPosition = 100
        
        // Add outline
        let outlineLabel = SKLabelNode(text: "\(percentage)%")
        outlineLabel.fontSize = 48
        outlineLabel.fontColor = .black
        outlineLabel.fontName = "Helvetica-Bold"
        outlineLabel.position = CGPoint.zero
        outlineLabel.zPosition = -1
        label.addChild(outlineLabel)
        
        addChild(label)
        
        // Dramatic entrance animation
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.6)
        scaleUp.timingMode = .easeOut
        
        let group = SKAction.group([fadeIn, scaleUp])
        label.run(group)
    }
    
    private func createFinalCelebration(percentage: Int) {
        // Create extra celebration for high scores
        if percentage >= 90 {
            createGoldStarBurst()
        } else if percentage >= 70 {
            createSuccessRipple()
        }
        
        // Screen flash effect for any completion
        createScreenFlash()
    }
    
    private func createSparkleEffect(around position: CGPoint) {
        for _ in 0..<8 {
            let sparkle = createSparkleNode()
            sparkle.position = position
            sparkle.zPosition = 75
            addChild(sparkle)
            
            // Random direction and distance
            let angle = Double.random(in: 0...(2 * Double.pi))
            let distance = Double.random(in: 30...80)
            let endX = position.x + CGFloat(cos(angle) * distance)
            let endY = position.y + CGFloat(sin(angle) * distance)
            
            let move = SKAction.move(to: CGPoint(x: endX, y: endY), duration: 1.0)
            let fadeOut = SKAction.fadeOut(withDuration: 1.0)
            let remove = SKAction.removeFromParent()
            
            let sequence = SKAction.sequence([SKAction.group([move, fadeOut]), remove])
            sparkle.run(sequence)
        }
    }
    
    private func createGoldStarBurst() {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        
        for i in 0..<12 {
            let star = createStarNode()
            star.position = center
            star.alpha = 0
            star.setScale(0.5)
            star.zPosition = 60
            addChild(star)
            
            let angle = (Double(i) / 12.0) * 2 * Double.pi
            let distance = 150.0
            let endX = center.x + CGFloat(cos(angle) * distance)
            let endY = center.y + CGFloat(sin(angle) * distance)
            
            let delay = SKAction.wait(forDuration: Double(i) * 0.05)
            let fadeIn = SKAction.fadeIn(withDuration: 0.2)
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
            let move = SKAction.move(to: CGPoint(x: endX, y: endY), duration: 0.8)
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            
            let sequence = SKAction.sequence([
                delay,
                SKAction.group([fadeIn, scaleUp]),
                SKAction.group([move, SKAction.wait(forDuration: 0.3), fadeOut]),
                remove
            ])
            
            star.run(sequence)
        }
    }
    
    private func createSuccessRipple() {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        
        for i in 0..<3 {
            let circle = createCircleNode()
            circle.position = center
            circle.alpha = 0.8
            circle.setScale(0.1)
            circle.zPosition = 40
            addChild(circle)
            
            let delay = SKAction.wait(forDuration: Double(i) * 0.2)
            let scaleUp = SKAction.scale(to: 3.0, duration: 1.0)
            let fadeOut = SKAction.fadeOut(withDuration: 1.0)
            let remove = SKAction.removeFromParent()
            
            let sequence = SKAction.sequence([
                delay,
                SKAction.group([scaleUp, fadeOut]),
                remove
            ])
            
            circle.run(sequence)
        }
    }
    
    private func createScreenFlash() {
        let flashNode = SKSpriteNode(color: .white, size: CGSize(width: size.width, height: size.height))
        flashNode.position = CGPoint(x: size.width/2, y: size.height/2)
        flashNode.alpha = 0.5
        flashNode.zPosition = 200
        addChild(flashNode)
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        flashNode.run(SKAction.sequence([fadeOut, remove]))
    }
    
    // MARK: - Helper Methods for Creating Nodes
    
    private func createTrophySprite(color: UIColor) -> SKSpriteNode {
        let size = CGSize(width: 120, height: 120) // Increased from 80x80
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            
            // Trophy cup (larger)
            let cupRect = CGRect(x: 25, y: 40, width: 70, height: 50) // Increased size
            context.cgContext.fillEllipse(in: cupRect)
            
            // Trophy handles
            let leftHandle = CGRect(x: 15, y: 50, width: 15, height: 30)
            let rightHandle = CGRect(x: 90, y: 50, width: 15, height: 30)
            context.cgContext.fillEllipse(in: leftHandle)
            context.cgContext.fillEllipse(in: rightHandle)
            
            // Trophy base (larger)
            let baseRect = CGRect(x: 30, y: 90, width: 60, height: 15) // Increased size
            context.cgContext.fill(baseRect)
            
            // Trophy stem (larger)
            let stemRect = CGRect(x: 55, y: 80, width: 10, height: 20) // Increased size
            context.cgContext.fill(stemRect)
            
            // Add some shine
            UIColor.white.withAlphaComponent(0.3).setFill()
            let shineRect = CGRect(x: 35, y: 45, width: 20, height: 25)
            context.cgContext.fillEllipse(in: shineRect)
        }
        return SKSpriteNode(texture: SKTexture(image: image))
    }
    
    private func createConfettiTexture() -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 16, height: 12))
        let image = renderer.image { context in
            // Create a more visible rectangle with rounded corners
            UIColor.white.setFill()
            let rect = CGRect(x: 0, y: 0, width: 16, height: 12)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 2)
            path.fill()
        }
        return SKTexture(image: image)
    }
    
    private func createSparkleNode() -> SKSpriteNode {
        let size = CGSize(width: 8, height: 8)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor.systemYellow.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
        return SKSpriteNode(texture: SKTexture(image: image))
    }
    
    private func createStarNode() -> SKSpriteNode {
        let size = CGSize(width: 20, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor.systemYellow.setFill()
            
            // Draw a simple star
            let center = CGPoint(x: 10, y: 10)
            let radius: CGFloat = 8
            let points = 5
            
            let path = UIBezierPath()
            for i in 0..<points * 2 {
                let angle = CGFloat(i) * CGFloat.pi / CGFloat(points)
                let r = (i % 2 == 0) ? radius : radius * 0.5
                let x = center.x + r * cos(angle - CGFloat.pi / 2)
                let y = center.y + r * sin(angle - CGFloat.pi / 2)
                
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            path.close()
            path.fill()
        }
        return SKSpriteNode(texture: SKTexture(image: image))
    }
    
    private func createCircleNode() -> SKSpriteNode {
        let size = CGSize(width: 40, height: 40)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor.systemGreen.setStroke()
            context.cgContext.setLineWidth(3.0)
            context.cgContext.strokeEllipse(in: CGRect(origin: .zero, size: size).insetBy(dx: 2, dy: 2))
        }
        return SKSpriteNode(texture: SKTexture(image: image))
    }
    
    // MARK: - Public Interface
    func reset() {
        celebrationActive = false
        removeAllChildren()
    }
}

// MARK: - SwiftUI Integration
struct CompletionCelebrationView: UIViewRepresentable {
    let scene: CompletionCelebrationScene
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        
        // Configure the view
        view.backgroundColor = UIColor.clear
        view.allowsTransparency = true
        view.ignoresSiblingOrder = true
        view.showsFPS = false
        view.showsNodeCount = false
        
        // Set scene size to match screen
        let screenSize = UIScreen.main.bounds.size
        scene.size = screenSize
        scene.scaleMode = .resizeFill
        
        view.presentScene(scene)
        print("🏆 CompletionCelebrationView created with scene size: \(scene.size)")
        
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        if uiView.scene != scene {
            // Ensure scene size matches current bounds
            let screenSize = UIScreen.main.bounds.size
            scene.size = screenSize
            uiView.presentScene(scene)
            print("🏆 CompletionCelebrationView updated with scene size: \(scene.size)")
        }
    }
} 