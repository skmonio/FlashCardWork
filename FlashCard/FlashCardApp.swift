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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(settingsManager.getCurrentColorScheme())
                .onAppear {
                    // Lock orientation to portrait
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                }
        }
    }
}
