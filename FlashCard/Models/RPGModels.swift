import Foundation

struct Player: Identifiable {
    let id = UUID()
    var health: Int
    var maxHealth: Int
    var level: Int
    var experience: Int
    var experienceToNextLevel: Int
    
    init() {
        self.health = 100
        self.maxHealth = 100
        self.level = 1
        self.experience = 0
        self.experienceToNextLevel = 100
    }
    
    mutating func gainExperience(_ amount: Int) -> Bool {
        experience += amount
        if experience >= experienceToNextLevel {
            levelUp()
            return true
        }
        return false
    }
    
    mutating func levelUp() {
        level += 1
        maxHealth += 20
        health = maxHealth
        experience = 0
        experienceToNextLevel = level * 100
    }
    
    mutating func heal(_ amount: Int) {
        health = min(health + amount, maxHealth)
    }
    
    mutating func takeDamage(_ amount: Int) {
        health = max(0, health - amount)
    }
}

struct Enemy: Identifiable {
    let id = UUID()
    let name: String
    var health: Int
    let maxHealth: Int
    let damage: Int
    let experienceValue: Int
    let image: String // SF Symbol name
    
    static func createEnemy(for level: Int) -> Enemy {
        let types = [
            (name: "Goblin", health: 50, damage: 10, exp: 30, image: "face.smiling.fill"),
            (name: "Orc", health: 80, damage: 15, exp: 50, image: "face.dashed.fill"),
            (name: "Dragon", health: 120, damage: 20, exp: 100, image: "flame.fill"),
            (name: "Dark Wizard", health: 100, damage: 25, exp: 80, image: "wand.and.stars"),
            (name: "Ancient Beast", health: 150, damage: 30, exp: 120, image: "pawprint.fill")
        ]
        
        let enemyBase = types[Int.random(in: 0..<types.count)]
        let levelMultiplier = Double(level) * 0.5 + 1.0
        
        return Enemy(
            name: enemyBase.name,
            health: Int(Double(enemyBase.health) * levelMultiplier),
            maxHealth: Int(Double(enemyBase.health) * levelMultiplier),
            damage: Int(Double(enemyBase.damage) * levelMultiplier),
            experienceValue: Int(Double(enemyBase.exp) * levelMultiplier),
            image: enemyBase.image
        )
    }
} 