import SwiftUI

struct GameCardView: View {
    let card: FlashCard
    @Binding var isShowingFront: Bool
    @Binding var isShowingExample: Bool
    @State private var offset: CGSize = .zero
    @State private var exitSide: ExitSide = .none
    
    // Audio service
    @ObservedObject private var speechService = DutchSpeechService.shared
    
    // Swipe actions
    let onSwipeLeft: (() -> Void)?
    let onSwipeRight: (() -> Void)?
    let onSwipeUp: (() -> Void)?
    let onSwipeDown: (() -> Void)?
    let onDragChanged: ((CGFloat) -> Void)?
    let onVerticalDragChanged: ((CGFloat) -> Void)?
    
    private enum ExitSide {
        case none, left, right
    }
    
    private var rotationDegrees: Double {
        isShowingFront ? 0 : 180
    }
    
    private var rotationOffset: Double {
        offset.width / 10
    }
    
    // Determine what text to speak based on current card state
    private var textToSpeak: String {
        if isShowingFront {
            // On front side, speak just the word (no article in games)
            return card.word
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
         onSwipeUp: (() -> Void)? = nil,
         onSwipeDown: (() -> Void)? = nil,
         onDragChanged: ((CGFloat) -> Void)? = nil,
         onVerticalDragChanged: ((CGFloat) -> Void)? = nil) {
        self.card = card
        self._isShowingFront = isShowingFront
        self._isShowingExample = isShowingExample
        self.onSwipeLeft = onSwipeLeft
        self.onSwipeRight = onSwipeRight
        self.onSwipeUp = onSwipeUp
        self.onSwipeDown = onSwipeDown
        self.onDragChanged = onDragChanged
        self.onVerticalDragChanged = onVerticalDragChanged
    }

    var body: some View {
        VStack(spacing: 16) {
            // Card container
            ZStack {
                // Card content
                ZStack {
                    // Front of card (Word without article)
                    frontView
                        .opacity(isShowingFront ? 1 : 0)
                        .rotation3DEffect(.degrees(rotationDegrees), axis: (x: 0, y: 1, z: 0))
                    
                    // Back of card (Definition only)
                    backView
                        .opacity(isShowingFront ? 0 : 1)
                        .rotation3DEffect(.degrees(rotationDegrees - 180), axis: (x: 0, y: 1, z: 0))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.secondarySystemGroupedBackground))
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 20)
                .offset(x: offset.width, y: offset.height)
                .rotationEffect(.degrees(rotationOffset))
            }
            .gesture(cardGesture)
            .onTapGesture(count: 3) {
                // Triple tap to flip card
                HapticManager.shared.cardFlip()
                withAnimation(.easeInOut(duration: 0.5)) {
                    isShowingFront.toggle()
                    isShowingExample = false
                }
            }
            .onTapGesture(count: 2) {
                // Double tap to show/hide example
                HapticManager.shared.lightImpact()
                withAnimation(.easeInOut(duration: 0.3)) {
                    isShowingExample.toggle()
                }
            }
            .onTapGesture(count: 1) {
                // Single tap to play audio
                HapticManager.shared.lightImpact()
                speakCurrentText()
            }
        }
        .onChange(of: isShowingFront) { newValue in
            // Removed automatic audio playback when flipping to definition
            // Audio is now only triggered by manual single taps
        }
    }
    
    // MARK: - Card Views
    
    private var frontView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            // Word (no article) - centered
            Text(card.word)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
            
            // Example (if showing) - plain text, centered
            if isShowingExample && !card.example.isEmpty {
                Text(card.example)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .transition(.opacity.combined(with: .scale))
            }
            
            Spacer()
        }
        .padding(24)
    }
    
    private var backView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            // Definition only - centered
            Text(card.definition)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(5)
            
            Spacer()
        }
        .padding(24)
    }
    
    // MARK: - Gesture
    
    private var cardGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                guard exitSide == .none else { return }
                
                let previousOffset = offset.width
                offset = gesture.translation
                onDragChanged?(gesture.translation.width)
                onVerticalDragChanged?(gesture.translation.height)
                
                // Haptic feedback when crossing thresholds
                if abs(gesture.translation.width) > 100 || abs(gesture.translation.height) > 100 {
                    if abs(previousOffset) <= 100 {
                        HapticManager.shared.mediumImpact()
                    }
                }
                
                if abs(gesture.translation.width - previousOffset) > 50 {
                    HapticManager.shared.lightImpact()
                }
            }
            .onEnded { gesture in
                guard exitSide == .none else { return }
                
                let horizontalDistance = abs(gesture.translation.width)
                let verticalDistance = abs(gesture.translation.height)
                
                if horizontalDistance > verticalDistance && horizontalDistance > 100 {
                    // Horizontal swipe
                    if gesture.translation.width < -100 {
                        // Swipe left - Don't know
                        exitSide = .left
                        HapticManager.shared.heavyImpact()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            offset.width = -1000
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSwipeLeft?()
                        }
                    } else if gesture.translation.width > 100 {
                        // Swipe right - Know it
                        exitSide = .right
                        HapticManager.shared.heavyImpact()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            offset.width = 1000
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSwipeRight?()
                        }
                    }
                } else if verticalDistance > horizontalDistance && verticalDistance > 100 {
                    // Vertical swipe - SWAPPED as requested
                    if gesture.translation.height < -100 {
                        // Swipe up - Add to review (was skip)
                        HapticManager.shared.heavyImpact()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            offset = CGSize(width: 0, height: -1000)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSwipeUp?()
                        }
                    } else if gesture.translation.height > 100 {
                        // Swipe down - Skip (was review)
                        HapticManager.shared.heavyImpact()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            offset = CGSize(width: 0, height: 1000)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSwipeDown?()
                        }
                    }
                } else {
                    // Reset if not swiped far enough
                    HapticManager.shared.lightImpact()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        offset = .zero
                        onDragChanged?(0)
                        onVerticalDragChanged?(0)
                    }
                }
            }
    }
    
    // MARK: - Helper Methods
    
    private func speakCurrentText() {
        speechService.speakDutch(textToSpeak)
    }
}

// Preview
struct GameCardView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCard = FlashCard(
            word: "Boek",
            definition: "Book", 
            example: "Ik lees een boek.",
            article: "het"
        )
        
        GameCardView(
            card: sampleCard,
            isShowingFront: .constant(true),
            isShowingExample: .constant(false)
        )
        .previewLayout(.sizeThatFits)
    }
} 