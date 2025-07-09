import Foundation
import SwiftUI

// MARK: - Achievement System
struct Achievement: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let xpRequired: Int
    let levelRequired: Int
    let type: AchievementType
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    init(title: String, description: String, icon: String, xpRequired: Int, levelRequired: Int, type: AchievementType) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.icon = icon
        self.xpRequired = xpRequired
        self.levelRequired = levelRequired
        self.type = type
        self.isUnlocked = false
        self.unlockedDate = nil
    }
}

enum AchievementType: String, Codable, CaseIterable {
    case xp = "xp"
    case level = "level"
    case streak = "streak"
    case sessions = "sessions"
    case perfect = "perfect"
    case accuracy = "accuracy"
    
    var color: Color {
        switch self {
        case .xp: return .yellow
        case .level: return .blue
        case .streak: return .orange
        case .sessions: return .green
        case .perfect: return .purple
        case .accuracy: return .teal
        }
    }
}

// MARK: - Level Reward System
struct LevelReward: Identifiable, Codable {
    let id = UUID()
    let level: Int
    let title: String
    let description: String
    let icon: String
    let type: LevelRewardType
    let value: Int
    var isClaimed: Bool
    
    init(level: Int, title: String, description: String, icon: String, type: LevelRewardType, value: Int) {
        self.level = level
        self.title = title
        self.description = description
        self.icon = icon
        self.type = type
        self.value = value
        self.isClaimed = false
    }
}

enum LevelRewardType: String, Codable, CaseIterable {
    case xp = "xp"
    case streak = "streak"
    case feature = "feature"
    case cosmetic = "cosmetic"
    
    var color: Color {
        switch self {
        case .xp: return .yellow
        case .streak: return .orange
        case .feature: return .blue
        case .cosmetic: return .purple
        }
    }
}

// MARK: - User Profile Manager
class UserProfileManager: ObservableObject {
    static let shared = UserProfileManager()
    
    // MARK: - Published Properties
    @Published var username: String = "Learner"
    @Published var selectedAvatar: String = "person.crop.circle.fill"
    @Published var profileImageData: Data?
    @Published var xp: Int = 0
    @Published var level: Int = 1
    @Published var achievements: [Achievement] = []
    @Published var levelRewards: [LevelReward] = []
    
    // MARK: - Notification State
    @Published var showingAchievementNotification = false
    @Published var levelUpMessage = ""
    @Published var lastUnlockedAchievement: Achievement?
    
    // MARK: - Private Properties
    private let userDefaultsKey = "UserProfile"
    private let achievementsKey = "UserAchievements"
    private let levelRewardsKey = "LevelRewards"
    
    // Track achievements unlocked in current session to prevent duplicate notifications
    private var achievementsUnlockedThisSession: Set<UUID> = []
    
    private init() {
        loadUserProfile()
        initializeAchievements()
        initializeLevelRewards()
    }
    
    // MARK: - Profile Management
    
    func updateProfile(username: String, avatar: String) {
        self.username = username
        self.selectedAvatar = avatar
        saveUserProfile()
    }
    
    func setProfileImage(_ imageData: Data?) {
        self.profileImageData = imageData
        saveUserProfile()
    }
    
    // MARK: - XP and Level Management
    
    func addXP(_ amount: Int) {
        let oldLevel = level
        xp += amount
        
        // Check for level up
        let newLevel = calculateLevel()
        if newLevel > oldLevel {
            levelUp(to: newLevel)
        }
        
        // Check for achievements
        checkAchievements()
        
        saveUserProfile()
    }
    
    func resetXP() {
        xp = 0
        level = 1
        
        // Reset all achievements
        for i in achievements.indices {
            achievements[i].isUnlocked = false
            achievements[i].unlockedDate = nil
        }
        
        // Reset all level rewards
        for i in levelRewards.indices {
            levelRewards[i].isClaimed = false
        }
        
        // Reset session achievement tracking
        achievementsUnlockedThisSession.removeAll()
        
        // Trigger UI update
        objectWillChange.send()
        
        saveUserProfile()
        saveAchievements()
        saveLevelRewards()
    }
    
    // Reset session achievement tracking for new sessions
    func resetSessionAchievementTracking() {
        achievementsUnlockedThisSession.removeAll()
    }
    
    private func calculateLevel() -> Int {
        var currentLevel = 1
        
        // Check each level to see if we have enough XP
        while true {
            let nextLevelXP = xpForLevel(currentLevel + 1)
            if xp < nextLevelXP {
                break
            }
            currentLevel += 1
        }
        
        return currentLevel
    }
    
    func xpForLevel(_ level: Int) -> Int {
        // Correct progression: Level 1 = 0 XP, Level 2 = 100 XP, Level 3 = 300 XP, etc.
        if level <= 1 {
            return 0
        }
        // Cumulative XP: Level 2 needs 100 XP, Level 3 needs 300 XP, Level 4 needs 600 XP, etc.
        return (level - 1) * level * 50 // This gives: Level 2 = 100, Level 3 = 300, Level 4 = 600, etc.
    }
    
    var progressToNextLevel: Double {
        let currentLevelXP = xpForLevel(level)
        let nextLevelXP = xpForLevel(level + 1)
        let xpInCurrentLevel = xp - currentLevelXP
        let xpNeededForNextLevel = nextLevelXP - currentLevelXP
        
        if xpNeededForNextLevel <= 0 {
            return 1.0
        }
        
        let progress = Double(xpInCurrentLevel) / Double(xpNeededForNextLevel)
        return max(0.0, min(1.0, progress)) // Clamp between 0 and 1
    }
    
    private func levelUp(to newLevel: Int) {
        level = newLevel
        levelUpMessage = "🎉 Level \(newLevel) Unlocked!"
        
        // No notification banner for level up
        // NotificationManager.shared.showLevelUp(level: newLevel)
        
        // Check for level rewards
        checkLevelRewards()
    }
    
    // MARK: - Achievement System
    
    private func initializeAchievements() {
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let savedAchievements = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = savedAchievements
        } else {
            // Create default achievements
            achievements = [
                // XP Achievements
                Achievement(title: "First Steps", description: "Earn your first 100 XP", icon: "star.fill", xpRequired: 100, levelRequired: 1, type: .xp),
                Achievement(title: "XP Collector", description: "Earn 500 XP", icon: "star.circle.fill", xpRequired: 500, levelRequired: 2, type: .xp),
                Achievement(title: "XP Master", description: "Earn 1000 XP", icon: "star.square.fill", xpRequired: 1000, levelRequired: 3, type: .xp),
                Achievement(title: "XP Legend", description: "Earn 5000 XP", icon: "star.square.on.square.fill", xpRequired: 5000, levelRequired: 10, type: .xp),
                
                // Level Achievements
                Achievement(title: "Rising Star", description: "Reach Level 5", icon: "arrow.up.circle.fill", xpRequired: 0, levelRequired: 5, type: .level),
                Achievement(title: "Level Master", description: "Reach Level 10", icon: "arrow.up.circle", xpRequired: 0, levelRequired: 10, type: .level),
                Achievement(title: "Level Legend", description: "Reach Level 20", icon: "arrow.up.square.fill", xpRequired: 0, levelRequired: 20, type: .level),
                
                // Streak Achievements
                Achievement(title: "Consistent Learner", description: "Maintain a 3-day streak", icon: "flame.fill", xpRequired: 0, levelRequired: 1, type: .streak),
                Achievement(title: "Dedicated Student", description: "Maintain a 7-day streak", icon: "flame.circle.fill", xpRequired: 0, levelRequired: 2, type: .streak),
                Achievement(title: "Learning Champion", description: "Maintain a 30-day streak", icon: "flame.square.fill", xpRequired: 0, levelRequired: 5, type: .streak),
                
                // Session Achievements
                Achievement(title: "First Session", description: "Complete your first study session", icon: "book.fill", xpRequired: 0, levelRequired: 1, type: .sessions),
                Achievement(title: "Regular Learner", description: "Complete 10 study sessions", icon: "book.circle.fill", xpRequired: 0, levelRequired: 2, type: .sessions),
                Achievement(title: "Study Master", description: "Complete 50 study sessions", icon: "book.square.fill", xpRequired: 0, levelRequired: 5, type: .sessions),
                
                // Perfect Session Achievements
                Achievement(title: "Perfect Start", description: "Complete a perfect study session", icon: "checkmark.circle.fill", xpRequired: 0, levelRequired: 1, type: .perfect),
                Achievement(title: "Perfectionist", description: "Complete 5 perfect sessions", icon: "checkmark.circle", xpRequired: 0, levelRequired: 3, type: .perfect),
                Achievement(title: "Perfect Master", description: "Complete 20 perfect sessions", icon: "checkmark.square.fill", xpRequired: 0, levelRequired: 8, type: .perfect),
                
                // Accuracy Achievements
                Achievement(title: "Sharp Shooter", description: "Achieve 90% accuracy", icon: "target", xpRequired: 0, levelRequired: 2, type: .accuracy),
                Achievement(title: "Accuracy Master", description: "Achieve 95% accuracy", icon: "target.fill", xpRequired: 0, levelRequired: 5, type: .accuracy)
            ]
            saveAchievements()
        }
    }
    
    private func checkAchievements() {
        let statsManager = StatisticsManager.shared
        
        for i in achievements.indices {
            guard !achievements[i].isUnlocked else { continue }
            
            var shouldUnlock = false
            
            switch achievements[i].type {
            case .xp:
                shouldUnlock = xp >= achievements[i].xpRequired && level >= achievements[i].levelRequired
            case .level:
                shouldUnlock = level >= achievements[i].levelRequired
            case .streak:
                let requiredStreak = achievements[i].title.contains("3") ? 3 : 
                                   achievements[i].title.contains("7") ? 7 : 30
                shouldUnlock = StreakManager.shared.currentStreak >= requiredStreak
            case .sessions:
                let requiredSessions = achievements[i].title.contains("First") ? 1 :
                                      achievements[i].title.contains("10") ? 10 : 50
                shouldUnlock = statsManager.studySessions.count >= requiredSessions
            case .perfect:
                let requiredPerfect = achievements[i].title.contains("First") ? 1 :
                                     achievements[i].title.contains("5") ? 5 : 20
                shouldUnlock = statsManager.getPerfectSessionCount() >= requiredPerfect
            case .accuracy:
                // Only unlock if enough questions have been answered
                let minQuestions = 20
                shouldUnlock = statsManager.getOverallAccuracy() >= 0.9 && statsManager.getTotalQuestionsAnswered() >= minQuestions
            }
            
            if shouldUnlock {
                achievements[i].isUnlocked = true
                achievements[i].unlockedDate = Date()
                
                // Only show notification if this achievement wasn't already unlocked this session
                if !achievementsUnlockedThisSession.contains(achievements[i].id) {
                    achievementsUnlockedThisSession.insert(achievements[i].id)
                    
                    // Show notification banner
                    NotificationManager.shared.showAchievement(
                        title: achievements[i].title,
                        message: achievements[i].description
                    )
                }
                
                saveAchievements()
            }
        }
    }
    
    func getAchievements(of type: AchievementType) -> [Achievement] {
        return achievements.filter { $0.type == type }
    }
    
    var unlockedAchievementsCount: Int {
        return achievements.filter { $0.isUnlocked }.count
    }
    
    var totalAchievementsCount: Int {
        return achievements.count
    }
    
    // MARK: - Level Reward System
    
    private func initializeLevelRewards() {
        if let data = UserDefaults.standard.data(forKey: levelRewardsKey),
           let savedRewards = try? JSONDecoder().decode([LevelReward].self, from: data) {
            levelRewards = savedRewards
        } else {
            // Create default level rewards
            levelRewards = [
                LevelReward(level: 2, title: "Bonus XP", description: "Earn 50 bonus XP", icon: "star.fill", type: .xp, value: 50),
                LevelReward(level: 3, title: "Streak Protection", description: "One free streak protection", icon: "shield.fill", type: .streak, value: 1),
                LevelReward(level: 5, title: "Advanced Features", description: "Unlock progressive study mode", icon: "brain.head.profile", type: .feature, value: 1),
                LevelReward(level: 7, title: "XP Multiplier", description: "1.2x XP bonus for 24 hours", icon: "bolt.fill", type: .xp, value: 20),
                LevelReward(level: 10, title: "Custom Avatar", description: "Unlock premium avatars", icon: "person.crop.circle.badge.plus", type: .cosmetic, value: 1),
                LevelReward(level: 15, title: "Master Status", description: "Unlock all features", icon: "crown.fill", type: .feature, value: 1)
            ]
            saveLevelRewards()
        }
    }
    
    private func checkLevelRewards() {
        // Check if any new rewards are available
        for i in levelRewards.indices {
            if level >= levelRewards[i].level && !levelRewards[i].isClaimed {
                // Reward is available but not claimed
                print("🎁 Level reward available: \(levelRewards[i].title)")
            }
        }
    }
    
    func claimLevelReward(_ reward: LevelReward) {
        guard let index = levelRewards.firstIndex(where: { $0.id == reward.id }) else { return }
        guard level >= reward.level && !reward.isClaimed else { return }
        
        levelRewards[index].isClaimed = true
        saveLevelRewards()
        
        // Apply reward effect
        applyRewardEffect(reward)
    }
    
    private func applyRewardEffect(_ reward: LevelReward) {
        switch reward.type {
        case .xp:
            addXP(reward.value)
        case .streak:
            // Add streak protection
            print("🛡️ Streak protection activated")
        case .feature:
            // Unlock features
            print("🔓 Feature unlocked: \(reward.title)")
        case .cosmetic:
            // Unlock cosmetics
            print("🎨 Cosmetic unlocked: \(reward.title)")
        }
    }
    
    var availableLevelRewards: [LevelReward] {
        return levelRewards.filter { level >= $0.level && !$0.isClaimed }
    }
    
    var allLevelRewards: [LevelReward] {
        return levelRewards
    }
    
    // MARK: - Data Persistence
    
    private func saveUserProfile() {
        let profileData = [
            "username": username,
            "selectedAvatar": selectedAvatar,
            "xp": xp,
            "level": level
        ] as [String: Any]
        
        UserDefaults.standard.set(profileData, forKey: userDefaultsKey)
        
        if let imageData = profileImageData {
            UserDefaults.standard.set(imageData, forKey: "ProfileImageData")
        }
    }
    
    private func loadUserProfile() {
        if let profileData = UserDefaults.standard.dictionary(forKey: userDefaultsKey) {
            username = profileData["username"] as? String ?? "Learner"
            selectedAvatar = profileData["selectedAvatar"] as? String ?? "person.crop.circle.fill"
            xp = profileData["xp"] as? Int ?? 0
            level = profileData["level"] as? Int ?? 1
        }
        
        if let imageData = UserDefaults.standard.data(forKey: "ProfileImageData") {
            profileImageData = imageData
        }
    }
    
    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(data, forKey: achievementsKey)
        }
    }
    
    private func saveLevelRewards() {
        if let data = try? JSONEncoder().encode(levelRewards) {
            UserDefaults.standard.set(data, forKey: levelRewardsKey)
        }
    }
    
    func calculateLevel(forXP xp: Int) -> Int {
        var currentLevel = 1
        while true {
            let nextLevelXP = xpForLevel(currentLevel + 1)
            if xp < nextLevelXP {
                break
            }
            currentLevel += 1
        }
        return currentLevel
    }
} 