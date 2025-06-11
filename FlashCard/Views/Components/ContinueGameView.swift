import SwiftUI

struct ContinueGameView: View {
    let gameType: GameSaveState.SavedGameType
    let deckIds: [UUID]
    let cardCount: Int
    let onContinue: () -> Void
    let onStartFresh: () -> Void
    let onCancel: () -> Void
    
    @State private var saveDate: Date?
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: gameType.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("Continue Game?")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(gameType.displayName)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(.top)
            
            // Save State Info
            if let date = saveDate {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                        Text("Last played: \(formatDate(date))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "rectangle.stack")
                            .foregroundColor(.secondary)
                        Text("\(cardCount) cards selected")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            // Action Buttons
            VStack(spacing: 12) {
                // Continue Button
                Button(action: {
                    HapticManager.shared.buttonTap()
                    onContinue()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Continue Game")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                }
                
                // Start Fresh Button
                Button(action: {
                    HapticManager.shared.buttonTap()
                    onStartFresh()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Start Fresh")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                
                // Cancel Button
                Button(action: {
                    HapticManager.shared.buttonTap()
                    onCancel()
                }) {
                    HStack {
                        Image(systemName: "xmark")
                        Text("Cancel")
                    }
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
        .onAppear {
            loadSaveStateInfo()
        }
    }
    
    private func loadSaveStateInfo() {
        saveDate = SaveStateManager.shared.getSaveStateInfo(gameType: gameType)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Continue Game Overlay
struct ContinueGameOverlay: View {
    let gameType: GameSaveState.SavedGameType
    let deckIds: [UUID]
    let cardCount: Int
    let onContinue: () -> Void
    let onStartFresh: () -> Void
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isPresented = false
                    }
                }
            
            // Continue Game View
            ContinueGameView(
                gameType: gameType,
                deckIds: deckIds,
                cardCount: cardCount,
                onContinue: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isPresented = false
                        onContinue()
                    }
                },
                onStartFresh: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isPresented = false
                        onStartFresh()
                    }
                },
                onCancel: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isPresented = false
                    }
                }
            )
            .transition(.scale.combined(with: .opacity))
        }
        .opacity(isPresented ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: isPresented)
    }
}

// MARK: - Preview
struct ContinueGameView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            ContinueGameView(
                gameType: .memoryGame,
                deckIds: [UUID(), UUID()],
                cardCount: 25,
                onContinue: { print("Continue") },
                onStartFresh: { print("Start Fresh") },
                onCancel: { print("Cancel") }
            )
        }
    }
} 