import SwiftUI

struct CardView: View {
    let card: FlashCard
    @Binding var isShowingFront: Bool
    @Binding var isShowingExample: Bool
    @State private var offset = CGSize.zero
    @State private var exitSide: ExitSide = .none
    var onSwipeLeft: (() -> Void)?
    var onSwipeRight: (() -> Void)?
    var onDragChanged: ((CGFloat) -> Void)?
    
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
                        offset = gesture.translation
                        onDragChanged?(gesture.translation.width)
                    }
                    .onEnded { gesture in
                        guard exitSide == .none else { return }
                        if gesture.translation.width < -100 {
                            // Swipe left - Don't know
                            exitSide = .left
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                offset.width = -1000
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onSwipeLeft?()
                            }
                        } else if gesture.translation.width > 100 {
                            // Swipe right - Know it
                            exitSide = .right
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                offset.width = 1000
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onSwipeRight?()
                            }
                        } else {
                            // Reset if not swiped far enough
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                offset = .zero
                                onDragChanged?(0)
                            }
                        }
                    }
            )
            .onTapGesture {
                // Single tap to show example
                withAnimation(.easeInOut(duration: 0.3)) {
                    isShowingExample.toggle()
                }
            }
            .onTapGesture(count: 2) {
                // Double tap to flip
                withAnimation(.easeInOut(duration: 0.5)) {
                    isShowingFront.toggle()
                    isShowingExample = false // Reset example state when flipping
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
                VStack(spacing: 16) {
                    Text(card.word)
                        .font(.title)
                        .bold()
                        .foregroundColor(.black)
                    
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
            )
    }
    
    private var backView: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white)
            .shadow(radius: 5)
            .overlay(
                VStack(spacing: 16) {
                    Text(card.definition)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                }
                .padding()
            )
    }
} 