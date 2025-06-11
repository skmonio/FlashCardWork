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
    @State private var showingCloseConfirmation = false
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
                // Record failed word attempt
                viewModel.recordCardShown(currentCard.id, isCorrect: false)
            }
        } else {
            HapticManager.shared.lightImpact()
            
            if isWordGuessed {
                gameWon = true
                HapticManager.shared.gameComplete()
                showingGameOver = true
                // Record successful word completion
                viewModel.recordCardShown(currentCard.id, isCorrect: true)
            }
        }
    }
    
    private func nextWord() {
        if currentCardIndex < cards.count - 1 {
            currentCardIndex += 1
            resetGame()
            showingNextWord = false
        } else {
            dismissToRoot()
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
            ZStack {
                VStack(spacing: 20) {
                    // Progress and attempts - with top padding for status bar
                    HStack {
                        Text("Word \(currentCardIndex + 1) of \(cards.count)")
                            .font(.headline)
                        Spacer()
                        Text("Attempts left: \(remainingAttempts)")
                            .font(.headline)
                            .foregroundColor(remainingAttempts <= 2 ? .red : .primary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 50) // Add top padding for status bar
                    
                    // Hangman drawing
                    HangmanDrawing(remainingAttempts: remainingAttempts)
                        .frame(height: 180)
                    
                    // Word to guess - larger and more spaced
                    VStack(spacing: 15) {
                        Text(maskedWord)
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .padding(.horizontal)
                        
                        // Show guessed letters
                        if !guessedLetters.isEmpty {
                            VStack(spacing: 6) {
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
                    VStack(spacing: 6) {
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
            
            // Bottom Navigation Bar
            HStack {
                Button(action: {
                    if !guessedLetters.isEmpty && !showingGameOver {
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
        .navigationBarHidden(true)
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
                dismissToRoot()
            }
        } message: {
            if gameWon {
                Text("Congratulations! You guessed the word: \(word)")
            } else {
                Text("Sorry! The word was: \(word)")
            }
        }
        .alert("Close Game?", isPresented: $showingCloseConfirmation) {
            Button("Close", role: .destructive) {
                dismissToRoot()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to close? Your progress will be lost.")
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