import SwiftUI

struct CardView: View {
    let card: FlashCard
    @Binding var isShowingFront: Bool
    @Binding var isShowingExample: Bool
    @State private var offset: CGSize = .zero
    @State private var exitSide: ExitSide = .none
    @State private var hasAudio: Bool = false
    
    let onSwipeLeft: (() -> Void)?
    let onSwipeRight: (() -> Void)?
    let onDragChanged: ((CGFloat) -> Void)?
    
    private enum ExitSide {
        case none, left, right
    }
    
    private var rotationDegrees: Double {
        isShowingFront ? 0 : 180
    }
    
    init(card: FlashCard, 
         isShowingFront: Binding<Bool>,
         isShowingExample: Binding<Bool>,
         onSwipeLeft: (() -> Void)? = nil,
         onSwipeRight: (() -> Void)? = nil,
         onDragChanged: ((CGFloat) -> Void)? = nil) {
        self.card = card
        self._isShowingFront = isShowingFront
        self._isShowingExample = isShowingExample
        self.onSwipeLeft = onSwipeLeft
        self.onSwipeRight = onSwipeRight
        self.onDragChanged = onDragChanged
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
            
            // Audio control overlay (only on front side with word)
            if isShowingFront && hasAudio {
                VStack {
                    HStack {
                        Spacer()
                        AudioControlView(cardId: card.id, mode: .studyMode)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.9))
                                    .shadow(radius: 2)
                            )
                            .padding(.trailing, 30)
                    }
                    Spacer()
                }
                .allowsHitTesting(true) // Ensure audio button is tappable even with card gestures
            }
        }
        .onAppear {
            // Safely check for audio existence in background
            DispatchQueue.global(qos: .background).async {
                do {
                    let audioExists = AudioManager.shared.audioExists(for: card.id)
                    DispatchQueue.main.async {
                        hasAudio = audioExists
                    }
                } catch {
                    print("CardView: Error checking audio existence: \(error)")
                    DispatchQueue.main.async {
                        hasAudio = false
                    }
                }
            }
        }
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
                                .padding(.trailing, 16)
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
                                .padding(.trailing, 16)
                        }
                        Spacer()
                    }
                }
            )
    }
} 