import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private let settingsManager = SettingsManager.shared
    
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
} 