import SwiftUI

struct TestView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    @Environment(\.dismiss) private var dismiss
    @State private var currentQuestionIndex = 0
    @State private var userAnswer = ""
    @State private var showingResult = false
    @State private var score = 0
    @State private var incorrectAnswers: [(FlashCard, String)] = []
    @State private var isTestComplete = false
    
    var body: some View {
        VStack {
            if cards.isEmpty {
                emptyStateView
            } else if isTestComplete {
                testResultView
            } else {
                testQuestionView
            }
        }
        .navigationTitle("Test Mode")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No cards to test")
                .font(.title2)
            Text("Add some cards to get started!")
                .foregroundColor(.secondary)
        }
    }
    
    private var testQuestionView: some View {
        VStack(spacing: 20) {
            // Progress
            Text("Question \(currentQuestionIndex + 1) of \(cards.count)")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Question Card
            VStack(alignment: .leading, spacing: 16) {
                Text("Definition:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(cards[currentQuestionIndex].definition)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                
                if !cards[currentQuestionIndex].example.isEmpty {
                    Text("Example:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(cards[currentQuestionIndex].example)
                        .font(.body)
                        .italic()
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                }
                
                Text("What's the word?")
                    .font(.headline)
                    .padding(.top)
                
                TextField("Enter your answer", text: $userAnswer)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                Button(action: submitAnswer) {
                    Text("Submit Answer")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(userAnswer.isEmpty)
            }
            .padding()
        }
        .alert("Answer Result", isPresented: $showingResult) {
            Button("Continue") {
                moveToNextQuestion()
            }
        } message: {
            Text(getResultMessage())
        }
    }
    
    private var testResultView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Score Display
                Text("Test Complete!")
                    .font(.title)
                    .bold()
                
                Text("Score: \(score) / \(cards.count)")
                    .font(.title2)
                
                // Score percentage
                let percentage = Double(score) / Double(cards.count) * 100
                Text(String(format: "%.1f%%", percentage))
                    .font(.title)
                    .foregroundColor(percentage >= 70 ? .green : .red)
                    .padding(.bottom)
                
                if !incorrectAnswers.isEmpty {
                    Text("Review Incorrect Answers:")
                        .font(.headline)
                        .padding(.top)
                    
                    ForEach(incorrectAnswers, id: \.0.id) { card, userAnswer in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Word: \(card.word)")
                                .font(.headline)
                            Text("Your answer: \(userAnswer)")
                                .foregroundColor(.red)
                            Text("Definition: \(card.definition)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                
                Button(action: restartTest) {
                    Text("Take Test Again")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top)
            }
            .padding()
        }
    }
    
    private func submitAnswer() {
        let currentCard = cards[currentQuestionIndex]
        let isCorrect = userAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ==
            currentCard.word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isCorrect {
            score += 1
        } else {
            incorrectAnswers.append((currentCard, userAnswer))
        }
        
        showingResult = true
    }
    
    private func getResultMessage() -> String {
        let currentCard = cards[currentQuestionIndex]
        let isCorrect = userAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ==
            currentCard.word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        return isCorrect ? "Correct! 🎉" : "Incorrect. The correct word was: \(currentCard.word)"
    }
    
    private func moveToNextQuestion() {
        userAnswer = ""
        if currentQuestionIndex < cards.count - 1 {
            currentQuestionIndex += 1
        } else {
            isTestComplete = true
        }
    }
    
    private func restartTest() {
        currentQuestionIndex = 0
        score = 0
        userAnswer = ""
        incorrectAnswers = []
        isTestComplete = false
    }
} 