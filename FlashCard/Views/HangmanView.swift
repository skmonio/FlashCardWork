import SwiftUI

struct HangmanView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentCardIndex = 0
    @State private var guessedLetters: Set<Character> = []
    @State private var remainingAttempts = 6
    @State private var showingGameOver = false
    @State private var gameWon = false
    @State private var showingNextWord = false
    
    private var currentCard: FlashCard {
        cards[currentCardIndex]
    }
    
    private var word: String {
        currentCard.word.lowercased()
    }
    
    private var maskedWord: String {
        word.map { letter in
            guessedLetters.contains(letter) ? String(letter) : "_"
        }.joined(separator: " ")
    }
    
    private var isWordGuessed: Bool {
        Set(word).isSubset(of: guessedLetters)
    }
    
    private var keyboard: [[Character]] {
        [
            ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
            ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
            ["z", "x", "c", "v", "b", "n", "m"]
        ]
    }
    
    private func letterButton(_ letter: Character) -> some View {
        Button(action: {
            guessLetter(letter)
        }) {
            Text(String(letter).uppercased())
                .font(.system(size: 20, weight: .medium))
                .frame(width: 30, height: 40)
                .background(guessedLetters.contains(letter) ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .disabled(guessedLetters.contains(letter))
    }
    
    private func guessLetter(_ letter: Character) {
        guessedLetters.insert(letter)
        
        if !word.contains(letter) {
            remainingAttempts -= 1
            
            if remainingAttempts == 0 {
                gameWon = false
                showingGameOver = true
            }
        } else if isWordGuessed {
            gameWon = true
            showingGameOver = true
            // Update success count for the card
            if let cardIndex = viewModel.flashCards.firstIndex(where: { $0.id == currentCard.id }) {
                var updatedCards = viewModel.flashCards
                updatedCards[cardIndex].successCount += 1
                viewModel.flashCards = updatedCards
            }
        }
    }
    
    private func nextWord() {
        if currentCardIndex < cards.count - 1 {
            currentCardIndex += 1
            resetGame()
            showingNextWord = false
        } else {
            dismiss()
        }
    }
    
    private func resetGame() {
        guessedLetters.removeAll()
        remainingAttempts = 6
        showingGameOver = false
        gameWon = false
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress and attempts
            HStack {
                Text("Word \(currentCardIndex + 1) of \(cards.count)")
                Spacer()
                Text("Attempts left: \(remainingAttempts)")
            }
            .padding()
            
            // Hangman drawing
            HangmanDrawing(remainingAttempts: remainingAttempts)
                .frame(height: 200)
            
            // Word to guess
            Text(maskedWord)
                .font(.system(size: 30, weight: .bold, design: .monospaced))
                .padding()
            
            // Definition hint
            Text(currentCard.definition)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            // Keyboard
            VStack(spacing: 8) {
                ForEach(keyboard, id: \.self) { row in
                    HStack(spacing: 4) {
                        ForEach(row, id: \.self) { letter in
                            letterButton(letter)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Hangman")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Game Over", isPresented: $showingGameOver) {
            if currentCardIndex < cards.count - 1 {
                Button("Next Word") {
                    showingNextWord = true
                }
            }
            Button("Try Again") {
                resetGame()
            }
            Button("Exit", role: .cancel) {
                dismiss()
            }
        } message: {
            if gameWon {
                Text("Congratulations! You guessed the word!")
            } else {
                Text("Sorry! The word was: \(word)")
            }
        }
        .onChange(of: showingNextWord) { oldValue, newValue in
            if newValue {
                nextWord()
            }
        }
    }
}

struct HangmanDrawing: View {
    let remainingAttempts: Int
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let center = width / 2
            
            Path { path in
                // Base
                path.move(to: CGPoint(x: center - 60, y: height - 20))
                path.addLine(to: CGPoint(x: center + 60, y: height - 20))
                
                // Pole
                path.move(to: CGPoint(x: center, y: height - 20))
                path.addLine(to: CGPoint(x: center, y: 20))
                
                // Top
                path.addLine(to: CGPoint(x: center - 40, y: 20))
                
                // Rope
                path.move(to: CGPoint(x: center - 40, y: 20))
                path.addLine(to: CGPoint(x: center - 40, y: 40))
            }
            .stroke(Color.black, lineWidth: 3)
            
            // Draw hangman based on remaining attempts
            if remainingAttempts <= 5 { // Head
                Circle()
                    .stroke(Color.black, lineWidth: 3)
                    .frame(width: 40, height: 40)
                    .position(x: center - 40, y: 60)
            }
            
            if remainingAttempts <= 4 { // Body
                Path { path in
                    path.move(to: CGPoint(x: center - 40, y: 80))
                    path.addLine(to: CGPoint(x: center - 40, y: 140))
                }
                .stroke(Color.black, lineWidth: 3)
            }
            
            if remainingAttempts <= 3 { // Left arm
                Path { path in
                    path.move(to: CGPoint(x: center - 40, y: 100))
                    path.addLine(to: CGPoint(x: center - 70, y: 120))
                }
                .stroke(Color.black, lineWidth: 3)
            }
            
            if remainingAttempts <= 2 { // Right arm
                Path { path in
                    path.move(to: CGPoint(x: center - 40, y: 100))
                    path.addLine(to: CGPoint(x: center - 10, y: 120))
                }
                .stroke(Color.black, lineWidth: 3)
            }
            
            if remainingAttempts <= 1 { // Left leg
                Path { path in
                    path.move(to: CGPoint(x: center - 40, y: 140))
                    path.addLine(to: CGPoint(x: center - 70, y: 170))
                }
                .stroke(Color.black, lineWidth: 3)
            }
            
            if remainingAttempts == 0 { // Right leg
                Path { path in
                    path.move(to: CGPoint(x: center - 40, y: 140))
                    path.addLine(to: CGPoint(x: center - 10, y: 170))
                }
                .stroke(Color.black, lineWidth: 3)
            }
        }
    }
} 