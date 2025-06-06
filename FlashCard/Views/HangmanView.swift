import SwiftUI

struct HangmanView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    let cards: [FlashCard]
    
    @State private var currentWord = ""
    @State private var definition = ""
    @State private var guessedLetters: Set<Character> = []
    @State private var remainingGuesses = 6
    @State private var gameOver = false
    @State private var gameWon = false
    @State private var showingDefinition = false
    @State private var currentCardIndex = 0
    @State private var score = 0
    
    private let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    
    private var displayWord: String {
        return currentWord.uppercased().map { letter in
            guessedLetters.contains(letter) ? String(letter) : "_"
        }.joined(separator: " ")
    }
    
    private var incorrectGuesses: Int {
        guessedLetters.filter { !currentWord.uppercased().contains($0) }.count
    }
    
    private var isWordGuessed: Bool {
        currentWord.uppercased().allSatisfy { guessedLetters.contains($0) }
    }
    
    private func startNewWord() {
        if currentCardIndex < cards.count {
            let card = cards[currentCardIndex]
            currentWord = card.word
            definition = card.definition
            guessedLetters.removeAll()
            remainingGuesses = 6
            gameOver = false
            gameWon = false
            showingDefinition = false
        } else {
            gameOver = true
        }
    }
    
    private func makeGuess(_ letter: Character) {
        guard !gameOver && !gameWon else { return }
        
        guessedLetters.insert(letter)
        
        if !currentWord.uppercased().contains(letter) {
            remainingGuesses -= 1
        }
        
        // Check if word is guessed
        if isWordGuessed {
            gameWon = true
            score += 1
        }
        
        // Check if game is over
        if remainingGuesses <= 0 {
            gameOver = true
        }
    }
    
    private func nextWord() {
        currentCardIndex += 1
        if currentCardIndex < cards.count {
            startNewWord()
        } else {
            gameOver = true
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // Progress and Score
                HStack {
                    Text("Word \(currentCardIndex + 1) of \(cards.count)")
                        .font(.headline)
                    Spacer()
                    Text("Score: \(score)")
                        .font(.headline)
                }
                .padding(.horizontal)
                
                // Hangman Drawing
                HangmanDrawing(incorrectGuesses: incorrectGuesses)
                    .frame(width: 200, height: 200)
                    .padding()
                
                // Word Display
                Text(displayWord)
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .padding()
                
                // Definition Button
                Button(action: {
                    showingDefinition.toggle()
                }) {
                    Text(showingDefinition ? definition : "Show Definition")
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Keyboard
                VStack(spacing: 8) {
                    ForEach(0..<3) { row in
                        HStack(spacing: 6) {
                            ForEach(getRowLetters(row), id: \.self) { letter in
                                Button(action: {
                                    makeGuess(letter)
                                }) {
                                    Text(String(letter))
                                        .font(.system(size: 20, weight: .bold))
                                        .frame(width: 35, height: 35)
                                        .background(buttonBackground(for: letter))
                                        .foregroundColor(buttonForeground(for: letter))
                                        .cornerRadius(8)
                                }
                                .disabled(guessedLetters.contains(letter) || gameOver || gameWon)
                            }
                        }
                    }
                }
                .padding()
                
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
                        currentCardIndex = 0
                        score = 0
                        startNewWord()
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
            
            // Game Over / Win Popup
            if gameOver || gameWon {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                
                VStack(spacing: 20) {
                    // Emoji and Title
                    VStack(spacing: 10) {
                        Text(gameWon ? "🎉" : "😔")
                            .font(.system(size: 60))
                        Text(gameWon ? "Congratulations!" : "Game Over!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(gameWon ? .green : .red)
                    }
                    
                    // Word and Definition
                    VStack(spacing: 8) {
                        Text("The word was:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(currentWord)
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text(definition)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Stats
                    HStack(spacing: 30) {
                        VStack {
                            Text("\(score)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Score")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(remainingGuesses)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Guesses Left")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        if currentCardIndex < cards.count - 1 {
                            Button(action: {
                                withAnimation {
                                    nextWord()
                                }
                            }) {
                                Text("Next Word")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Finish Game")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.secondary)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.top)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.horizontal, 40)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            startNewWord()
        }
        .animation(.easeInOut, value: gameOver || gameWon)
    }
    
    private func getRowLetters(_ row: Int) -> [Character] {
        let rowRanges = [0..<9, 9..<18, 18..<26]
        guard row < rowRanges.count else { return [] }
        return Array(alphabet[rowRanges[row]])
    }
    
    private func buttonBackground(for letter: Character) -> Color {
        if !guessedLetters.contains(letter) {
            return Color(.systemGray5)
        }
        return currentWord.uppercased().contains(letter) ? .green : .red
    }
    
    private func buttonForeground(for letter: Character) -> Color {
        if !guessedLetters.contains(letter) {
            return .primary
        }
        return .white
    }
}

struct HangmanDrawing: View {
    let incorrectGuesses: Int
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            Path { path in
                // Base
                path.move(to: CGPoint(x: width * 0.2, y: height * 0.9))
                path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.9))
                
                if incorrectGuesses > 0 {
                    // Vertical pole
                    path.move(to: CGPoint(x: width * 0.3, y: height * 0.9))
                    path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.1))
                }
                
                if incorrectGuesses > 1 {
                    // Top beam
                    path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.1))
                }
                
                if incorrectGuesses > 2 {
                    // Rope
                    path.move(to: CGPoint(x: width * 0.7, y: height * 0.1))
                    path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.2))
                }
                
                if incorrectGuesses > 3 {
                    // Head
                    path.addEllipse(in: CGRect(x: width * 0.65, y: height * 0.2,
                                             width: width * 0.1, height: height * 0.1))
                }
                
                if incorrectGuesses > 4 {
                    // Body
                    path.move(to: CGPoint(x: width * 0.7, y: height * 0.3))
                    path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.5))
                    
                    // Arms
                    path.move(to: CGPoint(x: width * 0.6, y: height * 0.4))
                    path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.4))
                }
                
                if incorrectGuesses > 5 {
                    // Legs
                    path.move(to: CGPoint(x: width * 0.7, y: height * 0.5))
                    path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.7))
                    
                    path.move(to: CGPoint(x: width * 0.7, y: height * 0.5))
                    path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.7))
                }
            }
            .stroke(Color.primary, lineWidth: 3)
        }
    }
} 