import SwiftUI

struct DeHetGameView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @State private var cards: [FlashCard]
    @State private var currentIndex = 0
    @State private var correctAnswers = 0
    @State private var totalAnswers = 0
    @State private var showingResults = false
    @State private var lastAnswerCorrect: Bool? = nil
    @State private var showingAnswer = false
    @State private var showingCloseConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    // Filter cards to only include those with articles
    private var filteredCards: [FlashCard] {
        return cards.filter { $0.article != nil }
    }
    
    private var currentCard: FlashCard? {
        guard currentIndex < filteredCards.count else { return nil }
        return filteredCards[currentIndex]
    }
    
    init(viewModel: FlashCardViewModel, cards: [FlashCard]) {
        self.viewModel = viewModel
        let articleCards = cards.filter { $0.article != nil }
        _cards = State(initialValue: articleCards.shuffled())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if filteredCards.isEmpty {
                emptyStateView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if showingResults {
                resultsView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                gameView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Bottom Navigation Bar
            bottomNavigationBar
        }
        .navigationBarHidden(true)
        .alert("Close Game?", isPresented: $showingCloseConfirmation) {
            Button("Close", role: .destructive) {
                dismissToRoot()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to close? Your progress will be lost.")
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.diamond")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Cards with Articles")
                .font(.title2)
                .bold()
            
            Text("This game requires cards that have 'de' or 'het' articles. Add some cards with articles to play this game.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
    }
    
    private var gameView: some View {
        VStack(spacing: 50) {
            // Progress indicator - with top padding for status bar
            HStack {
                Text("Question \(currentIndex + 1) of \(filteredCards.count)")
                    .font(.headline)
                Spacer()
                Text("Score: \(correctAnswers)/\(totalAnswers)")
                    .font(.headline)
                    .foregroundColor(totalAnswers > 0 ? (Double(correctAnswers)/Double(totalAnswers) >= 0.7 ? .green : .orange) : .primary)
            }
            .padding(.horizontal)
            .padding(.top, 50) // Add top padding for status bar
            
            // Card word display
            if let card = currentCard {
                VStack(spacing: 30) {
                    Text(card.word)
                        .font(.system(size: 48, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(radius: 5)
                        )
                        .padding(.horizontal)
                    
                    // Show definition as hint
                    Text(card.definition)
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Answer feedback
                if showingAnswer {
                    VStack(spacing: 15) {
                        if let lastCorrect = lastAnswerCorrect {
                            HStack {
                                Image(systemName: lastCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(lastCorrect ? .green : .red)
                                    .font(.title2)
                                
                                Text(lastCorrect ? "Correct!" : "Incorrect")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(lastCorrect ? .green : .red)
                            }
                        }
                        
                        Text("The correct article is: \(card.article ?? "")")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.blue)
                        
                        Button("Next") {
                            nextCard()
                        }
                        .buttonStyle(.borderedProminent)
                        .font(.headline)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .padding(.horizontal)
                } else {
                    // Answer buttons
                    HStack(spacing: 60) {
                        Button(action: {
                            checkAnswer("de")
                        }) {
                            Text("de")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 120, height: 80)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.blue)
                                )
                        }
                        
                        Button(action: {
                            checkAnswer("het")
                        }) {
                            Text("het")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 120, height: 80)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.orange)
                                )
                        }
                    }
                }
            }
            
            Spacer()
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 30) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Game Complete!")
                .font(.largeTitle)
                .bold()
            
            VStack(spacing: 15) {
                Text("Final Score")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("\(correctAnswers) / \(totalAnswers)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Double(correctAnswers)/Double(totalAnswers) >= 0.7 ? .green : .orange)
                
                let percentage = totalAnswers > 0 ? Int((Double(correctAnswers) / Double(totalAnswers)) * 100) : 0
                Text("\(percentage)%")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            
            Button("Play Again") {
                resetGame()
            }
            .buttonStyle(.borderedProminent)
            .font(.headline)
        }
    }
    
    private var bottomNavigationBar: some View {
        HStack {
            Button(action: {
                if totalAnswers > 0 && !showingResults {
                    showingCloseConfirmation = true
                } else {
                    dismiss()
                }
            }) {
                VStack {
                    Image(systemName: "chevron.backward")
                    Text("Back")
                }
            }
            .frame(maxWidth: .infinity)
            
            Button(action: {
                resetGame()
            }) {
                VStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Reset")
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray)
                .opacity(0.2),
            alignment: .top
        )
    }
    
    private func checkAnswer(_ selectedArticle: String) {
        guard let card = currentCard else { return }
        
        let isCorrect = card.article == selectedArticle
        lastAnswerCorrect = isCorrect
        totalAnswers += 1
        
        if isCorrect {
            correctAnswers += 1
            HapticManager.shared.correctAnswer()
        } else {
            HapticManager.shared.wrongAnswer()
        }
        
        showingAnswer = true
    }
    
    private func nextCard() {
        showingAnswer = false
        lastAnswerCorrect = nil
        
        if currentIndex < filteredCards.count - 1 {
            currentIndex += 1
        } else {
            showingResults = true
            HapticManager.shared.gameComplete()
        }
    }
    
    private func resetGame() {
        cards = cards.shuffled()
        currentIndex = 0
        correctAnswers = 0
        totalAnswers = 0
        showingResults = false
        lastAnswerCorrect = nil
        showingAnswer = false
    }
    
    private func dismissToRoot() {
        // Send notification to dismiss all views
        NotificationCenter.default.post(name: NSNotification.Name("DismissToRoot"), object: nil)
        
        // Also trigger ViewModel navigation
        viewModel.navigateToRoot()
        
        // Fallback with multiple dismissals
        dismiss()
        for i in 1...8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                dismiss()
            }
        }
    }
} 