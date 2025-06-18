import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FlashCardViewModel()
    @StateObject private var streakManager = StreakManager.shared
    @State private var isViewModelReady = false
    @State private var loadingTimeoutReached = false
    
    var body: some View {
        LoadingView(
            minimumDisplayTime: 1.5,
            isReadyCheck: {
                // Check if ViewModel has finished basic initialization
                return isViewModelReady || loadingTimeoutReached
            }
        ) {
            HomeView(viewModel: viewModel, streakManager: streakManager)
        }
        .onAppear {
            // Add a timeout to prevent infinite loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                print("⏰ Loading timeout reached, showing app anyway")
                loadingTimeoutReached = true
            }
            
            // Monitor ViewModel readiness
            checkViewModelReadiness()
        }
    }
    
    private func checkViewModelReadiness() {
        // Check every 100ms if ViewModel is ready
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            // Consider ready when we have at least the basic system decks
            // (which should be created even if no user data exists)
            let hasBasicDecks = viewModel.decks.count >= 4 // Uncategorized, Learnt, Learning, Review
            
            if hasBasicDecks {
                print("✅ ViewModel ready with \(viewModel.decks.count) decks")
                timer.invalidate()
                isViewModelReady = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CardRow: View {
    let card: FlashCard
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(card.word)
                    .font(.headline)
                Text(card.definition)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if !card.example.isEmpty {
                    Text("Example: \(card.example)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
            
            Spacer()
            
            // Learning percentage on the right
            LearningPercentageView(percentage: card.learningPercentage)
        }
    }
} 
