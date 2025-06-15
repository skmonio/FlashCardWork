import Foundation

class StreakManager: ObservableObject {
    static let shared = StreakManager()
    
    @Published var currentStreak: Int = 0
    @Published var lastActivityDate: Date?
    
    private let streakKey = "UserStreak"
    private let lastActivityKey = "LastActivityDate"
    
    private init() {
        loadStreak()
    }
    
    // MARK: - Public Interface
    
    /// Record that a game was completed today
    func recordGameCompletion() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Check if we already recorded activity today
        if let lastActivity = lastActivityDate,
           Calendar.current.isDate(lastActivity, inSameDayAs: today) {
            // Already recorded today, no need to update streak
            print("🔥 Game completion already recorded for today")
            return
        }
        
        // Check if this continues the streak or breaks it
        if let lastActivity = lastActivityDate {
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            
            if Calendar.current.isDate(lastActivity, inSameDayAs: yesterday) {
                // Continues streak
                currentStreak += 1
                print("🔥 Streak continued! Now at \(currentStreak) days")
            } else if Calendar.current.isDate(lastActivity, inSameDayAs: today) {
                // Same day, no change needed
                print("🔥 Same day activity, streak remains \(currentStreak)")
                return
            } else {
                // Streak broken, start new streak
                currentStreak = 1
                print("🔥 Streak broken, starting fresh at 1 day")
            }
        } else {
            // First time recording activity
            currentStreak = 1
            print("🔥 First streak recorded! Starting at 1 day")
        }
        
        lastActivityDate = today
        saveStreak()
    }
    
    /// Get the current streak count
    func getCurrentStreak() -> Int {
        // Check if streak should be reset due to inactivity
        checkStreakValidity()
        return currentStreak
    }
    
    /// Reset the streak (for testing or user request)
    func resetStreak() {
        currentStreak = 0
        lastActivityDate = nil
        saveStreak()
        print("🔥 Streak reset to 0")
    }
    
    // MARK: - Private Methods
    
    private func loadStreak() {
        currentStreak = UserDefaults.standard.integer(forKey: streakKey)
        
        if let lastActivityTimestamp = UserDefaults.standard.object(forKey: lastActivityKey) as? Date {
            lastActivityDate = lastActivityTimestamp
        }
        
        // Check if streak is still valid
        checkStreakValidity()
        
        print("🔥 Loaded streak: \(currentStreak) days, last activity: \(lastActivityDate?.description ?? "never")")
    }
    
    private func saveStreak() {
        UserDefaults.standard.set(currentStreak, forKey: streakKey)
        
        if let lastActivity = lastActivityDate {
            UserDefaults.standard.set(lastActivity, forKey: lastActivityKey)
        } else {
            UserDefaults.standard.removeObject(forKey: lastActivityKey)
        }
        
        print("🔥 Saved streak: \(currentStreak) days")
    }
    
    private func checkStreakValidity() {
        guard let lastActivity = lastActivityDate else {
            // No previous activity, streak should be 0
            if currentStreak > 0 {
                currentStreak = 0
                saveStreak()
            }
            return
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        // If last activity was not today or yesterday, streak is broken
        if !Calendar.current.isDate(lastActivity, inSameDayAs: today) &&
           !Calendar.current.isDate(lastActivity, inSameDayAs: yesterday) {
            print("🔥 Streak expired - last activity was \(lastActivity), resetting to 0")
            currentStreak = 0
            lastActivityDate = nil
            saveStreak()
        }
    }
} 