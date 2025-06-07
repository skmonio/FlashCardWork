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
    @State private var currentGuess = ""
    @FocusState private var isKeyboardFocused: Bool
    
    private var currentCard: FlashCard {
        cards[currentCardIndex]
    }
    
    private var word: String {
        currentCard.word.lowercased()
    }
    
    private var maskedWord: String {
        word.map { letter in
            if letter == " " {
                return "  " // Show spaces as larger gaps
            } else if guessedLetters.contains(letter) {
                return String(letter)
            } else {
                return "_"
            }
        }.joined(separator: " ")
    }
    
    private var isWordGuessed: Bool {
        // Only check letters, ignore spaces and punctuation
        let lettersToGuess = Set(word.filter { $0.isLetter })
        return lettersToGuess.isSubset(of: guessedLetters)
    }
    
    private func guessLetter(_ letter: Character) {
        // Only process actual letters
        guard letter.isLetter else { return }
        
        // Don't process if already guessed
        guard !guessedLetters.contains(letter) else { return }
        
        guessedLetters.insert(letter)
        
        if !word.contains(letter) {
            HapticManager.shared.wrongAnswer()
            remainingAttempts -= 1
            
            if remainingAttempts == 0 {
                gameWon = false
                HapticManager.shared.errorNotification()
                showingGameOver = true
            }
        } else {
            HapticManager.shared.lightImpact()
            
            if isWordGuessed {
                gameWon = true
                HapticManager.shared.gameComplete()
                showingGameOver = true
                // Update success count for the card
                if let cardIndex = viewModel.flashCards.firstIndex(where: { $0.id == currentCard.id }) {
                    var updatedCards = viewModel.flashCards
                    updatedCards[cardIndex].successCount += 1
                    viewModel.flashCards = updatedCards
                }
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
        currentGuess = ""
        isKeyboardFocused = true // Refocus keyboard after reset
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                // Progress and attempts
                HStack {
                    Text("Word \(currentCardIndex + 1) of \(cards.count)")
                        .font(.headline)
                    Spacer()
                    Text("Attempts left: \(remainingAttempts)")
                        .font(.headline)
                        .foregroundColor(remainingAttempts <= 2 ? .red : .primary)
                }
                .padding(.horizontal)
                
                // Hangman drawing
                HangmanDrawing(remainingAttempts: remainingAttempts)
                    .frame(height: 200)
                
                // Word to guess - larger and more spaced
                VStack(spacing: 20) {
                    Text(maskedWord)
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .padding(.horizontal)
                    
                    // Show guessed letters
                    if !guessedLetters.isEmpty {
                        VStack(spacing: 8) {
                            Text("Guessed letters:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(guessedLetters.sorted().map(String.init).joined(separator: ", "))
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Definition hint
                Text(currentCard.definition)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                // Instruction text
                VStack(spacing: 8) {
                    Text("Type letters to guess the word")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Text("Tap anywhere to bring up keyboard")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
            }
            
            // Hidden text field for keyboard input
            TextField("", text: $currentGuess)
                .focused($isKeyboardFocused)
                .opacity(0.01) // Nearly invisible but still functional
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .keyboardType(.alphabet)
                .onChange(of: currentGuess) { oldValue, newValue in
                    // Process new letters
                    let newLetters = Set(newValue.lowercased())
                    let oldLetters = Set(oldValue.lowercased())
                    let addedLetters = newLetters.subtracting(oldLetters)
                    
                    for letter in addedLetters {
                        if letter.isLetter && !guessedLetters.contains(letter) {
                            guessLetter(letter)
                        }
                    }
                    
                    // Clear the text field to allow repeated letters
                    if !newValue.isEmpty {
                        currentGuess = ""
                    }
                }
        }
        .navigationTitle("Hangman")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Focus the keyboard when view appears
            isKeyboardFocused = true
        }
        .onTapGesture {
            // Tap anywhere to focus keyboard
            isKeyboardFocused = true
        }
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