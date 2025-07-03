//
//  FlashCardApp.swift
//  FlashCard
//
//  Created by Stephen Cook on 04/06/2025.
//

import SwiftUI
import SpriteKit

@main
struct FlashCardApp: App {
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(NavigationCoordinator.shared)
                .preferredColorScheme(settingsManager.getCurrentColorScheme())
                .onAppear {
                    // Lock orientation to portrait
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                    
                    // Initialize notification manager and schedule notifications
                    notificationManager.scheduleNotifications()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    // Force portrait orientation when device rotates
                    if UIDevice.current.orientation != .portrait {
                        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                    }
                }
        }
    }
}
