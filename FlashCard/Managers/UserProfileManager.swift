import Foundation
import SwiftUI

class UserProfileManager: ObservableObject {
    static let shared = UserProfileManager()
    
    @Published var xp: Int {
        didSet { saveProfile() }
    }
    @Published var level: Int {
        didSet { saveProfile() }
    }
    @Published var username: String {
        didSet { saveProfile() }
    }
    @Published var selectedAvatar: String {
        didSet { saveProfile() }
    }
    @Published var profileImageData: Data? {
        didSet { saveProfile() }
    }
    
    // XP required for each level (simple exponential curve)
    func xpForLevel(_ level: Int) -> Int {
        // Level 1: 0 XP, Level 2: 100 XP, Level 3: 250 XP, Level 4: 450 XP, etc.
        return Int(Double(level) * 100.0 + Double(level * level) * 25.0)
    }
    
    // Progress to next level (0.0 - 1.0)
    var progressToNextLevel: Double {
        let currentLevelXP = xpForLevel(level)
        let nextLevelXP = xpForLevel(level + 1)
        guard nextLevelXP > currentLevelXP else { return 1.0 }
        return Double(xp - currentLevelXP) / Double(nextLevelXP - currentLevelXP)
    }
    
    // Persistence keys
    private let xpKey = "UserXP"
    private let levelKey = "UserLevel"
    private let usernameKey = "UserUsername"
    private let avatarKey = "UserAvatar"
    private let profileImageKey = "UserProfileImage"
    
    private init() {
        self.xp = UserDefaults.standard.integer(forKey: xpKey)
        self.level = UserDefaults.standard.integer(forKey: levelKey)
        self.username = UserDefaults.standard.string(forKey: usernameKey) ?? "Language Learner"
        self.selectedAvatar = UserDefaults.standard.string(forKey: avatarKey) ?? "person.crop.circle.fill"
        self.profileImageData = UserDefaults.standard.data(forKey: profileImageKey)
        if self.level < 1 { self.level = 1 }
    }
    
    // Add XP and handle level up
    func addXP(_ amount: Int) {
        xp += amount
        while xp >= xpForLevel(level + 1) {
            level += 1
            // Optionally: trigger level up animation/notification
        }
    }
    
    // Update profile data
    func updateProfile(username: String, avatar: String) {
        self.username = username
        self.selectedAvatar = avatar
    }
    
    // Set profile image
    func setProfileImage(_ imageData: Data?) {
        self.profileImageData = imageData
    }
    
    // Save to UserDefaults
    private func saveProfile() {
        UserDefaults.standard.set(xp, forKey: xpKey)
        UserDefaults.standard.set(level, forKey: levelKey)
        UserDefaults.standard.set(username, forKey: usernameKey)
        UserDefaults.standard.set(selectedAvatar, forKey: avatarKey)
        if let imageData = profileImageData {
            UserDefaults.standard.set(imageData, forKey: profileImageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: profileImageKey)
        }
    }
    
    // Reset profile (for testing/debug)
    func resetProfile() {
        xp = 0
        level = 1
        username = "Language Learner"
        selectedAvatar = "person.crop.circle.fill"
        profileImageData = nil
        saveProfile()
    }
} 