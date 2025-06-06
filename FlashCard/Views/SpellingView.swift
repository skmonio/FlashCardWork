import SwiftUI

struct SpellingView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    let cards: [FlashCard]
    
    @State private var currentCardIndex = 0
    @State private var userInput = ""
    @State private var showingWord = true
    @State private var showingResult = false
    @State private var isCorrect = false
    @State private var score = 0
    @State private var showingDefinition = false
    
    private var currentCard: FlashCard {
        cards[currentCardIndex]
    }
    
    private var progress: Double {
        Double(currentCardIndex) / Double(cards.count)
    }
    
    private func checkSpelling() {
        isCorrect = userInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == 
                   currentCard.word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if isCorrect {
            score += 1
        }
        showingResult = true
    }
    
    private func nextWord() {
        if currentCardIndex < cards.count - 1 {
            currentCardIndex += 1
            resetCard()
        } else {
            showFinalScore()
        }
    }
    
    private func resetCard() {
        userInput = ""
        showingWord = true
        showingResult = false
        showingDefinition = false
    }
    
    private func showFinalScore() {
        // The final score will be shown in the popup
        showingResult = true
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
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .foregroundColor(Color(.systemGray5))
                            .frame(width: geometry.size.width, height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .foregroundColor(.blue)
                            .frame(width: geometry.size.width * progress, height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal)
                
                Spacer()
                
                // Word Display
                if showingWord {
                    VStack(spacing: 16) {
                        Text("Study the word:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(currentCard.word)
                            .font(.system(size: 36, weight: .bold))
                        
                        Button(action: {
                            showingDefinition.toggle()
                        }) {
                            Text(showingDefinition ? currentCard.definition : "Show Definition")
                                .foregroundColor(.blue)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            withAnimation {
                                showingWord = false
                            }
                        }) {
                            Text("Ready to Write")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                } else {
                    VStack(spacing: 16) {
                        Text("Write the word:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("Type here...", text: $userInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        Button(action: {
                            checkSpelling()
                        }) {
                            Text("Check Spelling")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .disabled(userInput.isEmpty)
                        
                        Button(action: {
                            withAnimation {
                                showingWord = true
                            }
                        }) {
                            Text("Show Word Again")
                                .foregroundColor(.blue)
                        }
                    }
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
                        currentCardIndex = 0
                        score = 0
                        resetCard()
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
            
            // Result Popup
            if showingResult {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                
                VStack(spacing: 20) {
                    // Result Header
                    VStack(spacing: 10) {
                        Text(isCorrect ? "🎉" : "😔")
                            .font(.system(size: 60))
                        Text(isCorrect ? "Correct!" : "Not Quite")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(isCorrect ? .green : .red)
                    }
                    
                    // Word Comparison
                    VStack(spacing: 8) {
                        if !isCorrect {
                            Text("Your spelling:")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text(userInput)
                                .font(.title2)
                                .foregroundColor(.red)
                                .strikethrough()
                        }
                        
                        Text("Correct spelling:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(currentCard.word)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(currentCard.definition)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Stats (only show on final card)
                    if currentCardIndex == cards.count - 1 {
                        VStack(spacing: 8) {
                            Text("Final Score")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("\(score) / \(cards.count)")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("(\(Int((Double(score) / Double(cards.count)) * 100))%)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top)
                    }
                    
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
                            Text("Finish Practice")
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
        .animation(.easeInOut, value: showingResult)
    }
} 