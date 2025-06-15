//
//  FlashCardApp.swift
//  FlashCard
//
//  Created by Stephen Cook on 04/06/2025.
//

import SwiftUI

@main
struct FlashCardApp: App {
    @StateObject private var settingsManager = SettingsManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(settingsManager.getCurrentColorScheme())
        }
    }
}
