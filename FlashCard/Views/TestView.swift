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
    @State private var showingFeedback = false
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
            showingFeedback = true
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
    
    var body: some View {
        VStack {
            if cards.isEmpty {
                emptyStateView
            } else if showingResults {
                resultsView
            } else {
                testView
            }
            
            Spacer()
            
            // Bottom Navigation Bar
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    VStack {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                }
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    dismiss()
                }) {
                    VStack {
                        Image(systemName: "house")
                        Text("Home")
                    }
                }
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    resetTest()
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
    }
    
    private var testView: some View {
        VStack(spacing: 20) {
            // Progress
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
            
            // Question
            VStack(spacing: 16) {
                Text("What does this word mean?")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.top)
                
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
                    .padding(.top)
                
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
            
            Spacer()
        }
        .onAppear {
            shuffledOptions = generateOptions()
        }
        .alert(isPresented: $showingFeedback) {
            Alert(
                title: Text(selectedAnswer == currentCard.definition ? "Correct! 🎉" : "Incorrect"),
                message: Text(getFeedbackMessage()),
                dismissButton: .default(Text("Next")) {
                    moveToNextQuestion()
                }
            )
        }
    }
    
    private func getFeedbackMessage() -> String {
        if selectedAnswer == currentCard.definition {
            var message = "'\(currentCard.word)' means:\n\(currentCard.definition)"
            if !currentCard.example.isEmpty {
                message += "\n\nExample:\n\(currentCard.example)"
            }
            return message
        } else {
            return "'\(currentCard.word)'\n\nYour answer:\n\(selectedAnswer ?? "")\n\nCorrect answer:\n\(currentCard.definition)"
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
                    dismiss()
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