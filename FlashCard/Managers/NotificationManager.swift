import Foundation
import UserNotifications
import SwiftUI

// MARK: - Notification Types
enum NotificationType {
    case achievement
    case levelUp
    case xpGain
    case reward
    case info
    
    var icon: String {
        switch self {
        case .achievement: return "star.fill"
        case .levelUp: return "arrow.up.circle.fill"
        case .xpGain: return "bolt.fill"
        case .reward: return "gift.fill"
        case .info: return "info.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .achievement: return .yellow
        case .levelUp: return .blue
        case .xpGain: return .green
        case .reward: return .purple
        case .info: return .gray
        }
    }
}

// MARK: - Notification Model
struct AppNotification: Identifiable {
    let id = UUID()
    let type: NotificationType
    let title: String
    let message: String
    let duration: TimeInterval
    
    init(type: NotificationType, title: String, message: String, duration: TimeInterval = 3.0) {
        self.type = type
        self.title = title
        self.message = message
        self.duration = duration
    }
}

// MARK: - Notification Manager
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private let settingsManager = SettingsManager.shared
    
    @Published var currentNotification: AppNotification?
    @Published var isShowing = false
    
    private init() {
        requestNotificationPermission()
    }
    
    // MARK: - Permission Request
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void = { _ in }) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("🔔 Notification permission granted")
                } else {
                    print("🔔 Notification permission denied: \(error?.localizedDescription ?? "Unknown error")")
                }
                completion(granted)
            }
        }
    }
    
    // MARK: - Notification Management
    
    func scheduleNotifications() {
        guard settingsManager.isNotificationsEnabled else {
            cancelAllNotifications()
            return
        }
        
        // Cancel existing notifications first
        cancelAllNotifications()
        
        // Schedule new notifications based on frequency
        switch settingsManager.notificationFrequency {
        case .daily:
            scheduleDailyNotifications()
        case .everyOtherDay:
            scheduleEveryOtherDayNotifications()
        case .weekly:
            scheduleWeeklyNotifications()
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🔔 All notifications cancelled")
    }
    
    // MARK: - Scheduling Methods
    
    private func scheduleDailyNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Time to Study! 📚"
        content.body = "Keep your Dutch learning streak going. Practice a few cards today!"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: settingsManager.notificationTime)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyStudyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("🔔 Error scheduling daily notification: \(error)")
            } else {
                print("🔔 Daily notification scheduled for \(components.hour ?? 0):\(components.minute ?? 0)")
            }
        }
    }
    
    private func scheduleEveryOtherDayNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Study Reminder! 📚"
        content.body = "Don't forget to practice your Dutch vocabulary today!"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: settingsManager.notificationTime)
        
        // Schedule for every other day
        var dateComponents = components
        dateComponents.weekday = calendar.component(.weekday, from: Date())
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "everyOtherDayStudyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("🔔 Error scheduling every other day notification: \(error)")
            } else {
                print("🔔 Every other day notification scheduled")
            }
        }
    }
    
    private func scheduleWeeklyNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Weekly Study Check-in! 📚"
        content.body = "It's been a week! Time to review your Dutch vocabulary progress."
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: settingsManager.notificationTime)
        
        // Schedule for the same day of the week
        var dateComponents = components
        dateComponents.weekday = calendar.component(.weekday, from: Date())
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "weeklyStudyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("🔔 Error scheduling weekly notification: \(error)")
            } else {
                print("🔔 Weekly notification scheduled")
            }
        }
    }
    
    // MARK: - Status Check
    
    func checkNotificationStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
    
    func showNotification(_ notification: AppNotification) {
        DispatchQueue.main.async {
            self.currentNotification = notification
            self.isShowing = true
            
            // Auto-dismiss after duration
            DispatchQueue.main.asyncAfter(deadline: .now() + notification.duration) {
                self.dismissNotification()
            }
        }
    }
    
    func dismissNotification() {
        withAnimation(.easeInOut(duration: 0.3)) {
            self.isShowing = false
        }
        
        // Clear the notification after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.currentNotification = nil
        }
    }
    
    // Convenience methods
    func showAchievement(title: String, message: String) {
        let notification = AppNotification(
            type: .achievement,
            title: title,
            message: message,
            duration: 4.0
        )
        showNotification(notification)
    }
    
    func showLevelUp(level: Int) {
        let notification = AppNotification(
            type: .levelUp,
            title: "🎉 Level \(level) Unlocked!",
            message: "Congratulations! You've reached a new level.",
            duration: 4.0
        )
        showNotification(notification)
    }
    
    func showXPGain(amount: Int) {
        let notification = AppNotification(
            type: .xpGain,
            title: "+\(amount) XP",
            message: "Great job! You earned experience points.",
            duration: 3.0
        )
        showNotification(notification)
    }
    
    func showReward(title: String, message: String) {
        let notification = AppNotification(
            type: .reward,
            title: title,
            message: message,
            duration: 4.0
        )
        showNotification(notification)
    }
} 