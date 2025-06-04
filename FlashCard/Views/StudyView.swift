import SwiftUI

struct StudyView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    @State private var currentIndex = 0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            if cards.isEmpty {
                emptyStateView
            } else {
                studyView
            }
        }
        .navigationTitle("Study Cards")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No cards to study")
                .font(.title2)
            Text("Add some cards to get started!")
                .foregroundColor(.secondary)
        }
    }
    
    private var studyView: some View {
        VStack {
            // Progress indicator
            Text("\(currentIndex + 1) of \(cards.count)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top)
            
            // Card
            CardView(card: cards[currentIndex])
                .padding()
            
            // Navigation buttons
            HStack(spacing: 50) {
                Button(action: previousCard) {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.system(size: 44))
                }
                .disabled(currentIndex == 0)
                .opacity(currentIndex == 0 ? 0.3 : 1)
                
                Button(action: nextCard) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 44))
                }
                .disabled(currentIndex == cards.count - 1)
                .opacity(currentIndex == cards.count - 1 ? 0.3 : 1)
            }
            .foregroundColor(.blue)
            .padding(.bottom)
        }
    }
    
    private func nextCard() {
        withAnimation {
            if currentIndex < cards.count - 1 {
                currentIndex += 1
            }
        }
    }
    
    private func previousCard() {
        withAnimation {
            if currentIndex > 0 {
                currentIndex -= 1
            }
        }
    }
} 