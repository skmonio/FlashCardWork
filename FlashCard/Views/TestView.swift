import SwiftUI

struct TestView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @State private var cards: [FlashCard]
    @State private var currentIndex = 0
    @State private var showingResults = false
    @State private var correctAnswers = 0
    @State private var selectedAnswer: String?
    @State private var hasAnswered = false
    @State private var shuffledOptions: [String] = []
    @State private var showingCloseConfirmation = false
    @Environment(\.dismiss) private var dismiss
    @State private var incorrectCards: Set<UUID> = []
    
    init(viewModel: FlashCardViewModel, cards: [FlashCard]) {
        self.viewModel = viewModel
        _cards = State(initialValue: cards.shuffled())
    }
    
    private var currentCard: FlashCard {
        cards[currentIndex]
    }
    
    private func generateOptions() -> [String] {
        var options = [currentCard.definition] // Correct answer
        
        // Get all available decks for the current card
        let cardDecks = viewModel.decks.filter { deck in
            deck.cards.contains { $0.id == currentCard.id }
        }
        
        // Get all cards from the same decks (excluding current card)
        var poolOfOptions = Set<String>()
        for deck in cardDecks {
            let deckDefinitions = deck.cards
                .filter { $0.id != currentCard.id }
                .map { $0.definition }
            poolOfOptions.formUnion(deckDefinitions)
        }
        
        // If we don't have enough options from the same decks, use other cards
        if poolOfOptions.count < 3 {
            let otherDefinitions = viewModel.flashCards
                .filter { $0.id != currentCard.id }
                .map { $0.definition }
            poolOfOptions.formUnion(otherDefinitions)
        }
        
        // Add random definitions until we have 4 total options
        let additionalOptions = Array(poolOfOptions)
            .shuffled()
            .prefix(3)
        
        options.append(contentsOf: additionalOptions)
        return options.shuffled()
    }
    
    private func handleAnswer(_ option: String) {
        if !hasAnswered {
            selectedAnswer = option
            hasAnswered = true
            if option == currentCard.definition {
                correctAnswers += 1
                HapticManager.shared.correctAnswer()
            } else {
                incorrectCards.insert(currentCard.id)
                HapticManager.shared.wrongAnswer()
            }
            
            // Automatically move to next question after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                moveToNextQuestion()
            }
        }
    }
    
    private func moveToNextQuestion() {
        HapticManager.shared.questionAdvance()
        if currentIndex < cards.count - 1 {
            currentIndex += 1
            selectedAnswer = nil
            hasAnswered = false
            shuffledOptions = generateOptions()
        } else {
            HapticManager.shared.gameComplete()
            showingResults = true
        }
    }
    
    private func resetTest(onlyIncorrect: Bool = false) {
        if onlyIncorrect {
            cards = cards.filter { incorrectCards.contains($0.id) }
        } else {
            cards = cards.shuffled()
        }
        currentIndex = 0
        correctAnswers = 0
        showingResults = false
        selectedAnswer = nil
        hasAnswered = false
        incorrectCards.removeAll()
        shuffledOptions = generateOptions()
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
    
    var body: some View {
        VStack(spacing: 0) {
            if cards.isEmpty {
                emptyStateView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if showingResults {
                resultsView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                testView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Bottom Navigation Bar
            HStack {
                Button(action: {
                    if currentIndex > 0 && !showingResults {
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
                    currentIndex = 0
                    showingResults = false
                    correctAnswers = 0
                    incorrectCards.removeAll()
                    cards = cards.shuffled()
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
        .navigationBarHidden(true)
        .alert(isPresented: $showingCloseConfirmation) {
            Alert(
                title: Text("Are you sure you want to exit?"),
                message: Text("You will lose your progress."),
                primaryButton: .destructive(Text("Exit")) {
                    dismissToRoot()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private var testView: some View {
        VStack(spacing: 30) {
            // Progress - with top padding for status bar
            HStack {
                Text("\(currentIndex + 1) of \(cards.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Correct: \(correctAnswers)")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            .padding(.horizontal)
            .padding(.top, 50) // Add top padding for status bar
            
            // Question
            VStack(spacing: 20) {
                Text("What does this word mean?")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(currentCard.word)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 5)
                
                Text("Choose one of the following:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Answer options
                VStack(spacing: 12) {
                    ForEach(shuffledOptions, id: \.self) { option in
                        Button(action: {
                            handleAnswer(option)
                        }) {
                            Text(option)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    Group {
                                        if hasAnswered {
                                            if option == currentCard.definition {
                                                Color.green.opacity(0.2)
                                            } else if option == selectedAnswer {
                                                Color.red.opacity(0.2)
                                            } else {
                                                Color(.systemGray6)
                                            }
                                        } else {
                                            Color(.systemGray6)
                                        }
                                    }
                                )
                                .cornerRadius(10)
                        }
                        .disabled(hasAnswered)
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .onAppear {
            shuffledOptions = generateOptions()
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 20) {
            Text("Test Complete! 🎉")
                .font(.title)
                .multilineTextAlignment(.center)
            
            Text("Score: \(correctAnswers) / \(cards.count)")
                .font(.title2)
            
            Text("\(Int((Double(correctAnswers) / Double(cards.count)) * 100))%")
                .font(.largeTitle)
                .bold()
                .foregroundColor(
                    Double(correctAnswers) / Double(cards.count) >= 0.7 ? .green : .red
                )
            
            VStack(spacing: 16) {
                Button(action: {
                    resetTest()
                }) {
                    Text("Test All Cards Again")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                if !incorrectCards.isEmpty {
                    Button(action: {
                        resetTest(onlyIncorrect: true)
                    }) {
                        Text("Review Incorrect Answers (\(incorrectCards.count))")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
                
                Button(action: {
                    dismissToRoot()
                }) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.top)
        }
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No cards to test")
                .font(.title2)
            Text("Add some cards to get started!")
                .foregroundColor(.secondary)
        }
    }
} 