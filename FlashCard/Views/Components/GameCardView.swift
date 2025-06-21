import SwiftUI

struct GameCardView: View {
    let card: FlashCard
    @Binding var isShowingFront: Bool
    @Binding var isShowingExample: Bool
    
    let onSwipeLeft: (() -> Void)?
    let onSwipeRight: (() -> Void)?
    let onSwipeUp: (() -> Void)?
    let onSwipeDown: (() -> Void)?
    let onDragChanged: ((CGFloat) -> Void)?
    let onVerticalDragChanged: ((CGFloat) -> Void)?
    let onDragEnded: (() -> Void)? // New callback for when drag ends
    
    @State private var offset: CGSize = .zero
    @State private var exitSide: ExitSide = .none
    @ObservedObject private var speechService = DutchSpeechService.shared
    @State private var isCurrentTextSpeaking = false
    @State private var swipeDirection: SwipeDirection = .none
    
    enum ExitSide {
        case none, left, right, up, down
    }
    
    enum SwipeDirection {
        case none, horizontal, vertical
    }
    
    // Vibrant colors inspired by the Taal Trek theme
    private let vibrantColors: [Color] = [
        Color(red: 1.0, green: 0.4, blue: 0.2),    // Coral/Orange-Red
        Color(red: 1.0, green: 0.6, blue: 0.0),    // Bright Orange
        Color(red: 1.0, green: 0.8, blue: 0.0),    // Golden Yellow
        Color(red: 0.2, green: 0.8, blue: 0.6),    // Teal/Turquoise
        Color(red: 0.0, green: 0.7, blue: 0.8),    // Cyan Blue
        Color(red: 0.6, green: 0.4, blue: 1.0),    // Purple
        Color(red: 1.0, green: 0.3, blue: 0.6),    // Pink
        Color(red: 0.4, green: 0.9, blue: 0.3),    // Lime Green
    ]
    
    // Generate consistent color based on card content
    private var cardBorderColor: Color {
        guard !card.word.isEmpty && !card.definition.isEmpty else {
            return vibrantColors[0] // Default to first color if card has empty content
        }
        let hash = abs(card.word.hashValue &+ card.definition.hashValue)
        let index = hash % vibrantColors.count
        return vibrantColors[index]
    }
    
    // Computed property for text to speak
    private var textToSpeak: String {
        let word = card.article.isEmpty ? card.word : "\(card.article) \(card.word)"
        return isShowingFront ? word : card.definition
    }
    
    init(
        card: FlashCard,
        isShowingFront: Binding<Bool> = .constant(true),
        isShowingExample: Binding<Bool> = .constant(false),
         onSwipeLeft: (() -> Void)? = nil,
         onSwipeRight: (() -> Void)? = nil,
         onSwipeUp: (() -> Void)? = nil,
         onSwipeDown: (() -> Void)? = nil,
         onDragChanged: ((CGFloat) -> Void)? = nil,
        onVerticalDragChanged: ((CGFloat) -> Void)? = nil,
        onDragEnded: (() -> Void)? = nil
    ) {
        self.card = card
        self._isShowingFront = isShowingFront
        self._isShowingExample = isShowingExample
        self.onSwipeLeft = onSwipeLeft
        self.onSwipeRight = onSwipeRight
        self.onSwipeUp = onSwipeUp
        self.onSwipeDown = onSwipeDown
        self.onDragChanged = onDragChanged
        self.onVerticalDragChanged = onVerticalDragChanged
        self.onDragEnded = onDragEnded
    }

    var body: some View {
        VStack(spacing: 16) {
            // Card container - bigger, more card-like design
            ZStack {
                // Single card content that flips
                if isShowingFront {
                    frontView
                } else {
                    backView
                }
                }
                .frame(maxWidth: .infinity)
            .frame(height: 450) // Increased from 300 to 450
                .background(
                RoundedRectangle(cornerRadius: 24) // Slightly more rounded for card feel
                        .fill(Color(.secondarySystemGroupedBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        cardBorderColor,
                                        cardBorderColor.opacity(0.7)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 5 // Slightly thicker border
                            )
                    )
                    .shadow(color: cardBorderColor.opacity(0.3), radius: 12, x: 0, y: 6)
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                )
            .padding(.horizontal, 16) // Reduced padding for bigger cards
                .offset(x: offset.width, y: offset.height)
                .rotationEffect(.degrees(rotationOffset))
            .rotation3DEffect(.degrees(isShowingFront ? 0 : 180), axis: (x: 0, y: 1, z: 0))
            .gesture(cardGesture)
            .onTapGesture(count: 3) {
                // Triple tap to show/hide example (only on front side)
                if isShowingFront {
                    HapticManager.shared.lightImpact()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowingExample.toggle()
                    }
                }
            }
            .onTapGesture(count: 2) {
                // Double tap to flip card
                HapticManager.shared.cardFlip()
                withAnimation(.easeInOut(duration: 0.6)) {
                    isShowingFront.toggle()
                    isShowingExample = false
                }
            }
            .onTapGesture(count: 1) {
                // Single tap to play audio
                HapticManager.shared.lightImpact()
                speakCurrentText()
            }
        }
    }
    
    // MARK: - Card Views
    
    private var frontView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Word - prominent display (removed article)
            Text(card.word)
                .font(.system(size: 42, weight: .bold, design: .rounded)) // Increased from 32
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
            
            // Example (if showing) - plain text, centered
            if isShowingExample && !card.example.isEmpty {
                Text(card.example)
                    .font(.title3) // Increased from .body
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .padding(.top, 12)
                    .transition(.opacity.combined(with: .scale))
            }
            
            Spacer()
        }
        .padding(32) // Increased padding
    }
    
    private var backView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Definition - prominent display
            Text(card.definition)
                .font(.system(size: 36, weight: .semibold, design: .rounded)) // Increased from 28
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(6) // Increased from 5
            
            Spacer()
        }
        .padding(32) // Increased padding
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)) // Flip the text back to readable
    }
    
    // MARK: - Gesture
    
    private var cardGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                guard exitSide == .none else { return }
                
                // For visual offset, adjust based on card orientation so card moves correctly
                let visualTranslation = isShowingFront ? gesture.translation : CGSize(
                    width: -gesture.translation.width,
                    height: gesture.translation.height
                )
                
                // For action logic, always use original translation so actions stay consistent
                let actionTranslation = gesture.translation
                
                let horizontalDistance = abs(actionTranslation.width)
                let verticalDistance = abs(actionTranslation.height)
                
                // Lock to direction on first significant movement
                if swipeDirection == .none && (horizontalDistance > 20 || verticalDistance > 20) {
                    swipeDirection = horizontalDistance > verticalDistance ? .horizontal : .vertical
                }
                
                // Use visual translation for offset, action translation for callbacks
                switch swipeDirection {
                case .horizontal:
                    offset = CGSize(width: visualTranslation.width, height: 0)
                    onDragChanged?(actionTranslation.width)
                case .vertical:
                    offset = CGSize(width: 0, height: visualTranslation.height)
                    onVerticalDragChanged?(actionTranslation.height)
                case .none:
                    break
                }
                
                // Haptic feedback when crossing thresholds
                let currentDistance = swipeDirection == .horizontal ? horizontalDistance : verticalDistance
                if currentDistance > 100 {
                    HapticManager.shared.mediumImpact()
                }
            }
            .onEnded { gesture in
                guard exitSide == .none else { return }
                
                // For actions, always use original translation so actions stay consistent
                let actionTranslation = gesture.translation
                
                let horizontalDistance = abs(actionTranslation.width)
                let verticalDistance = abs(actionTranslation.height)
                let threshold: CGFloat = 120 // Increased threshold for more intentional swipes
                
                var swipeCompleted = false
                
                if swipeDirection == .horizontal && horizontalDistance > threshold {
                    if actionTranslation.width < 0 {
                        // Swipe left - Don't know
                        exitSide = .left
                        HapticManager.shared.heavyImpact()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            // Exit in the visual direction (left when showing front, right when showing back)
                            offset.width = isShowingFront ? -1000 : 1000
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSwipeLeft?()
                        }
                        swipeCompleted = true
                    } else {
                        // Swipe right - Known
                        exitSide = .right
                        HapticManager.shared.heavyImpact()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            // Exit in the visual direction (right when showing front, left when showing back)
                            offset.width = isShowingFront ? 1000 : -1000
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSwipeRight?()
                        }
                        swipeCompleted = true
                    }
                } else if swipeDirection == .vertical && verticalDistance > threshold {
                    if actionTranslation.height < 0 {
                        // Swipe up - Review
                        exitSide = .up
                        HapticManager.shared.heavyImpact()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            offset = CGSize(width: 0, height: -1000)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSwipeUp?()
                        }
                        swipeCompleted = true
                    } else {
                        // Swipe down - Skip
                        exitSide = .down
                        HapticManager.shared.heavyImpact()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            offset = CGSize(width: 0, height: 1000)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSwipeDown?()
                        }
                        swipeCompleted = true
                    }
                }
                
                if !swipeCompleted {
                    // Reset if not swiped far enough
                    HapticManager.shared.lightImpact()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        offset = .zero
                        swipeDirection = .none
                        onDragChanged?(0)
                        onVerticalDragChanged?(0)
                    }
                }
                
                // Always call onDragEnded to reset parent state
                onDragEnded?()
            }
    }
    
    // MARK: - Helper Methods
    
    private func speakCurrentText() {
        speechService.speakDutch(textToSpeak, rate: 0.4)
    }
    
    private var rotationOffset: Double {
        return offset.width / 20  // Subtle rotation while dragging
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