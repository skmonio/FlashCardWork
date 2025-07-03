import SwiftUI

struct StudyTypeSelectionView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let gameMode: GameMode
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var selectedCardCount: Int = 10
    @StateObject private var saveStateManager = SaveStateManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            UnifiedHeader(
                title: "Study Type",
                onBack: { navigationCoordinator.pop() },
                onProfile: { navigationCoordinator.presentSheet(.userProfile) },
                trailing: {
                    AnyView(
                        Button(action: {
                            navigationCoordinator.presentSheet(.gameInfo(gameMode.gameInfoType))
                        }) {
                            Image(systemName: "info.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    )
                }
            )
            
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 16) {
                Text("Choose Study Type")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("How would you like to study?")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            // Study Type Options
            VStack(spacing: 20) {
                // Quick Study Option
                StudyTypeCard(
                    title: "Quick Study",
                    subtitle: "Random cards from all decks",
                    description: "Perfect for quick practice sessions",
                    icon: "bolt.fill",
                    color: .orange,
                    onTap: {
                        navigationCoordinator.push(NavigationDestination.quickStudy(gameMode, .adaptive, selectedCardCount))
                    }
                )
                
                // Progressive Study Option (hide for memory game)
                if gameMode != .game {
                    StudyTypeCard(
                        title: "Progressive Study",
                        subtitle: "3 levels of increasing difficulty",
                        description: "Start easy, build up to challenging content",
                        icon: "chart.line.uptrend.xyaxis",
                        color: .purple,
                        onTap: {
                            navigationCoordinator.push(NavigationDestination.progressiveStudy(gameMode))
                        }
                    )
                }
                
                // Normal Study Option
                StudyTypeCard(
                    title: "Normal Study",
                    subtitle: "Choose specific decks",
                    description: "Focused study on selected topics",
                    icon: "folder.fill",
                    color: .blue,
                    onTap: {
                        navigationCoordinator.push(NavigationDestination.normalStudy(gameMode, .adaptive))
                    }
                )
            }
            .padding(.horizontal)
            
            Spacer()
                
                // Continue Option (always shown, but greyed out if no save state)
                VStack(spacing: 20) {
                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color(.systemGray4))
                            .frame(height: 1)
                        Text("or")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                        Rectangle()
                            .fill(Color(.systemGray4))
                            .frame(height: 1)
                    }
                    .padding(.horizontal)
                    
                    ContinueGameCard(
                        gameMode: gameMode,
                        savedAt: saveStateManager.getSaveStateInfo(gameType: gameMode.saveStateType),
                        isEnabled: saveStateManager.hasSaveState(gameType: gameMode.saveStateType),
                        onTap: {
                            if saveStateManager.hasSaveState(gameType: gameMode.saveStateType) {
                                navigationCoordinator.push(NavigationDestination.continueGame(gameMode))
                            }
                        }
                    )
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct ContinueGameCard: View {
    let gameMode: GameMode
    let savedAt: Date?
    let isEnabled: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(.title)
                    .foregroundColor(isEnabled ? .green : .gray)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Continue")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(isEnabled ? .primary : .secondary)
                    
                    Text(gameMode.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isEnabled ? .green : .gray)
                    
                    if isEnabled, let savedAt = savedAt {
                        Text("Saved \(timeAgoString(from: savedAt))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("No saved progress")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: isEnabled ? "play.circle.fill" : "play.circle")
                    .font(.title2)
                    .foregroundColor(isEnabled ? .green : .gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEnabled ? Color.green.opacity(0.1) : Color(.systemGray5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isEnabled ? Color.green.opacity(0.3) : Color(.systemGray4), lineWidth: isEnabled ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
        .disabled(!isEnabled)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 60 {
            return "just now"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }
}

struct StudyTypeCard: View {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(color)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
} 