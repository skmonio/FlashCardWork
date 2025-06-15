import SwiftUI

struct CardView: View {
    let card: FlashCard
    @Binding var isShowingFront: Bool
    @Binding var isShowingExample: Bool
    @State private var offset: CGSize = .zero
    @State private var exitSide: ExitSide = .none
    
    // Replace audio manager with speech service
    @StateObject private var speechService = DutchSpeechService.shared
    
    let onSwipeLeft: (() -> Void)?
    let onSwipeRight: (() -> Void)?
    let onDragChanged: ((CGFloat) -> Void)?
    let onGoBack: (() -> Void)?  // Add back functionality
    
    private enum ExitSide {
        case none, left, right
    }
    
    private var rotationDegrees: Double {
        isShowingFront ? 0 : 180
    }
    
    // Determine what text to speak based on current card state
    private var textToSpeak: String {
        if isShowingFront {
            // On front side, speak the word with article if available
            return card.article.isEmpty ? card.word : "\(card.article) \(card.word)"
        } else {
            // On back side, speak the definition
            return card.definition
        }
    }
    
    // Check if current text is being spoken
    private var isCurrentTextSpeaking: Bool {
        return speechService.isSpeaking && speechService.currentlySpeaking == textToSpeak
    }
    
    init(card: FlashCard, 
         isShowingFront: Binding<Bool>,
         isShowingExample: Binding<Bool>,
         onSwipeLeft: (() -> Void)? = nil,
         onSwipeRight: (() -> Void)? = nil,
         onDragChanged: ((CGFloat) -> Void)? = nil,
         onGoBack: (() -> Void)? = nil) {
        self.card = card
        self._isShowingFront = isShowingFront
        self._isShowingExample = isShowingExample
        self.onSwipeLeft = onSwipeLeft
        self.onSwipeRight = onSwipeRight
        self.onDragChanged = onDragChanged
        self.onGoBack = onGoBack
    }

    var body: some View {
        ZStack {
            // Card
            ZStack {
                // Front of card (Word)
                frontView
                    .opacity(isShowingFront ? 1 : 0)
                    .rotation3DEffect(.degrees(rotationDegrees), axis: (x: 0, y: 1, z: 0))
                
                // Back of card (Definition)
                backView
                    .opacity(isShowingFront ? 0 : 1)
                    .rotation3DEffect(.degrees(rotationDegrees - 180), axis: (x: 0, y: 1, z: 0))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .padding(.horizontal)
            .offset(x: offset.width, y: 0)
            .rotationEffect(.degrees(rotationOffset))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        guard exitSide == .none else { return }
                        
                        let previousOffset = offset.width
                        offset = gesture.translation
                        onDragChanged?(gesture.translation.width)
                        
                        // Haptic feedback when crossing thresholds
                        if abs(gesture.translation.width) > 100 {
                            // Crossed the swipe threshold
                            if abs(previousOffset) <= 100 {
                                HapticManager.shared.mediumImpact() // Feedback when crossing threshold
                            }
                        }
                        
                        // Light haptic during significant drag changes
                        if abs(gesture.translation.width - previousOffset) > 50 {
                            HapticManager.shared.lightImpact()
                        }
                    }
                    .onEnded { gesture in
                        guard exitSide == .none else { return }
                        if gesture.translation.width < -100 {
                            // Swipe left - Don't know
                            exitSide = .left
                            HapticManager.shared.heavyImpact() // Strong feedback for commit to swipe
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                offset.width = -1000
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onSwipeLeft?()
                            }
                        } else if gesture.translation.width > 100 {
                            // Swipe right - Know it
                            exitSide = .right
                            HapticManager.shared.heavyImpact() // Strong feedback for commit to swipe
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                offset.width = 1000
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onSwipeRight?()
                            }
                        } else {
                            // Reset if not swiped far enough
                            HapticManager.shared.lightImpact() // Light feedback for card returning
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                offset = .zero
                                onDragChanged?(0)
                            }
                        }
                    }
            )
            .onTapGesture {
                // Single tap to show example
                HapticManager.shared.lightImpact() // Light feedback for tap
                withAnimation(.easeInOut(duration: 0.3)) {
                    isShowingExample.toggle()
                }
            }
            .onTapGesture(count: 2) {
                // Double tap to flip
                HapticManager.shared.cardFlip() // Card flip feedback
                withAnimation(.easeInOut(duration: 0.5)) {
                    isShowingFront.toggle()
                    isShowingExample = false // Reset example state when flipping
                }
            }
            
            // Pronunciation control overlay
            pronunciationOverlay
        }
        .onAppear {
            // Auto-play pronunciation when card appears (front side only)
            if isShowingFront && !card.word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    speakCurrentText()
                }
            }
        }
        .onChange(of: isShowingFront) { newValue in
            // Auto-play when flipping to definition side
            if !newValue && !card.definition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    speakCurrentText()
                }
            }
        }
    }
    
    // MARK: - Pronunciation Overlay
    private var pronunciationOverlay: some View {
        VStack {
            HStack {
                // Back button on the left
                if let onGoBack = onGoBack {
                    backButton
                        .padding(.leading, 20)
                        .padding(.top, 20)
                } else {
                    Spacer().frame(width: 64) // Maintain spacing when no back button
                }
                
                Spacer()
                
                // Pronunciation button on the right
                pronunciationButton
                    .padding(.trailing, 20)
                    .padding(.top, 20)
            }
            Spacer()
        }
        .allowsHitTesting(true) // Ensure buttons are tappable even with card gestures
    }
    
    private var backButton: some View {
        Button(action: {
            onGoBack?()
            HapticManager.shared.lightImpact()
        }) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 44, height: 44)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .buttonStyle(.plain)
    }
    
    private var pronunciationButton: some View {
        Button(action: {
            if isCurrentTextSpeaking {
                speechService.stopSpeaking()
            } else {
                speakCurrentText()
            }
            HapticManager.shared.lightImpact()
        }) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 44, height: 44)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                Image(systemName: isCurrentTextSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .scaleEffect(isCurrentTextSpeaking ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isCurrentTextSpeaking)
            }
        }
        .buttonStyle(.plain)
        .disabled(textToSpeak.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    // MARK: - Speech Functions
    private func speakCurrentText() {
        let text = textToSpeak.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // Use slower speech rate for learning
        speechService.speakDutch(text, rate: 0.4)
    }

    private var rotationOffset: Double {
        return offset.width / 20  // Subtle rotation while dragging
    }
    
    private var frontView: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white)
            .shadow(radius: 5)
            .overlay(
                ZStack {
                    VStack(spacing: 16) {
                        // Word with optional article
                        VStack(spacing: 4) {
                            if !card.article.isEmpty {
                                Text(card.article)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .bold()
                            }
                            Text(card.word)
                                .font(.title)
                                .bold()
                                .foregroundColor(.black)
                        }
                        
                        if !card.example.isEmpty && isShowingExample {
                            Divider()
                            Text(card.example)
                                .font(.body)
                                .italic()
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .transition(.opacity)
                        }
                    }
                    .padding()
                    
                    // Learning percentage in top right
                    VStack {
                        HStack {
                            Spacer()
                            LearningPercentageView(percentage: card.learningPercentage)
                                .padding(.top, 16)
                                .padding(.leading, 60) // Make room for pronunciation button
                        }
                        Spacer()
                    }
                }
            )
    }
    
    private var backView: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white)
            .shadow(radius: 5)
            .overlay(
                ZStack {
                    VStack(spacing: 16) {
                        Text(card.definition)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                        
                        // Show grammatical information if available
                        if !card.article.isEmpty || !card.plural.isEmpty || !card.pastTense.isEmpty || !card.futureTense.isEmpty || !card.pastParticiple.isEmpty {
                            Divider()
                            VStack(spacing: 8) {
                                if !card.article.isEmpty {
                                    HStack {
                                        Text("Article:")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(card.article)
                                            .font(.callout)
                                            .bold()
                                        Spacer()
                                    }
                                }
                                if !card.plural.isEmpty {
                                    HStack {
                                        Text("Plural:")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(card.plural)
                                            .font(.callout)
                                            .bold()
                                        Spacer()
                                    }
                                }
                                if !card.pastTense.isEmpty {
                                    HStack {
                                        Text("Past tense:")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(card.pastTense)
                                            .font(.callout)
                                            .bold()
                                        Spacer()
                                    }
                                }
                                if !card.futureTense.isEmpty {
                                    HStack {
                                        Text("Future tense:")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(card.futureTense)
                                            .font(.callout)
                                            .bold()
                                        Spacer()
                                    }
                                }
                                if !card.pastParticiple.isEmpty {
                                    HStack {
                                        Text("Past participle:")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(card.pastParticiple)
                                            .font(.callout)
                                            .bold()
                                        Spacer()
                                    }
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                    .padding()
                    
                    // Learning percentage in top right
                    VStack {
                        HStack {
                            Spacer()
                            LearningPercentageView(percentage: card.learningPercentage)
                                .padding(.top, 16)
                                .padding(.leading, 60) // Make room for pronunciation button
                        }
                        Spacer()
                    }
                }
            )
    }
} 