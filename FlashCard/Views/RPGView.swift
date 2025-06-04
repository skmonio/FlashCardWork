import SwiftUI

struct RPGView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: FlashCardViewModel
    @State private var currentEnemy = Enemy.createEnemy(for: 1)
    @State private var player = Player()
    @State private var currentCard: FlashCard?
    @State private var showingGameOver = false
    @State private var message = ""
    @State private var isAttacking = false
    @State private var showDamageNumber = false
    @State private var damageAmount = 0
    @State private var options: [String] = []
    @State private var showingLevelUp = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.1).ignoresSafeArea()
            
            VStack {
                // Enemy Section
                VStack {
                    Text(currentEnemy.name)
                        .font(.title2)
                        .foregroundColor(.red)
                    
                    // Enemy sprite
                    Image(systemName: currentEnemy.image)
                        .font(.system(size: 100))
                        .foregroundColor(.red)
                        .scaleEffect(isAttacking ? 0.8 : 1.0)
                        .offset(x: isAttacking ? -20 : 0)
                        .animation(.easeInOut(duration: 0.3), value: isAttacking)
                    
                    // Enemy health bar
                    HealthBarView(current: currentEnemy.health, maximum: currentEnemy.maxHealth)
                        .frame(height: 20)
                        .padding()
                    
                    if showDamageNumber {
                        Text("-\(damageAmount)")
                            .font(.title)
                            .foregroundColor(.red)
                            .transition(.scale.combined(with: .move(edge: .top)))
                    }
                }
                
                // Current card display
                if let card = currentCard {
                    VStack(spacing: 10) {
                        Text("Translate:")
                            .font(.headline)
                        Text(card.word)
                            .font(.title)
                            .padding()
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                    
                    // Multiple choice options
                    VStack(spacing: 15) {
                        ForEach(options, id: \.self) { option in
                            Button(action: {
                                checkAnswer(option)
                            }) {
                                Text(option)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                }
                
                // Player stats
                VStack(spacing: 8) {
                    HealthBarView(current: player.health, maximum: player.maxHealth)
                        .frame(height: 20)
                    
                    HStack {
                        Text("Level: \(player.level)")
                        Spacer()
                        Text("XP: \(player.experience)/\(player.experienceToNextLevel)")
                    }
                    .font(.headline)
                }
                .padding()
                
                if !message.isEmpty {
                    Text(message)
                        .foregroundColor(.green)
                        .padding()
                }
            }
            .padding()
            
            // Level up overlay
            if showingLevelUp {
                VStack {
                    Text("Level Up!")
                        .font(.largeTitle)
                        .foregroundColor(.yellow)
                    Text("You reached level \(player.level)!")
                        .font(.title2)
                    Text("Health restored!")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
                .transition(.scale.combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showingLevelUp = false
                        }
                    }
                }
            }
        }
        .navigationBarTitle("RPG Battle", displayMode: .inline)
        .onAppear(perform: setupGame)
        .alert("Game Over", isPresented: $showingGameOver) {
            Button("Try Again") {
                setupGame()
            }
            Button("Exit") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text(player.health <= 0 ? "You were defeated!" : "You won!")
        }
    }
    
    private func setupGame() {
        player = Player()
        currentEnemy = Enemy.createEnemy(for: player.level)
        selectNewCard()
    }
    
    private func selectNewCard() {
        guard !viewModel.flashCards.isEmpty else { return }
        currentCard = viewModel.flashCards.randomElement()
        generateOptions()
    }
    
    private func generateOptions() {
        guard let correctAnswer = currentCard?.definition else { return }
        options = [correctAnswer]
        
        // Add 3 random wrong answers
        while options.count < 4 && options.count < viewModel.flashCards.count {
            if let randomCard = viewModel.flashCards.randomElement(),
               randomCard.definition != correctAnswer,
               !options.contains(randomCard.definition) {
                options.append(randomCard.definition)
            }
        }
        
        // Shuffle the options
        options.shuffle()
    }
    
    private func checkAnswer(_ selectedAnswer: String) {
        guard let card = currentCard else { return }
        
        if selectedAnswer == card.definition {
            // Correct answer
            damageAmount = 20 + player.level * 5
            withAnimation {
                isAttacking = true
                showDamageNumber = true
                currentEnemy.health -= damageAmount
            }
            
            message = "Correct! Enemy took \(damageAmount) damage!"
            
            // Reset animations
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAttacking = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    showDamageNumber = false
                }
            }
            
            // Check if enemy is defeated
            if currentEnemy.health <= 0 {
                let leveledUp = player.gainExperience(currentEnemy.experienceValue)
                if leveledUp {
                    withAnimation {
                        showingLevelUp = true
                    }
                }
                showingGameOver = true
            }
        } else {
            // Wrong answer
            player.takeDamage(currentEnemy.damage)
            message = "Wrong! You took \(currentEnemy.damage) damage!"
            
            if player.health <= 0 {
                showingGameOver = true
            }
        }
        
        if !showingGameOver {
            selectNewCard()
        }
    }
}

struct HealthBarView: View {
    let current: Int
    let maximum: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.3))
                
                Rectangle()
                    .foregroundColor(.green)
                    .frame(width: CGFloat(current) / CGFloat(maximum) * geometry.size.width)
            }
            .cornerRadius(5)
            .overlay(
                Text("\(current)/\(maximum)")
                    .foregroundColor(.white)
                    .shadow(radius: 1)
            )
        }
    }
} 