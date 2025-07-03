import SwiftUI

struct MemoryGameInfoView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero icon
                    VStack(spacing: 12) {
                        Image(systemName: "brain.filled.head.profile")
                            .font(.system(size: 50, weight: .light))
                            .foregroundColor(.orange)
                            .frame(width: 80, height: 80)
                            .background(
                                Circle()
                                    .fill(Color.orange.opacity(0.1))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                                    )
                            )
                        
                        Text("Classic memory matching game to strengthen recall skills")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 16)
                    
                    // How to use section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "gamecontroller.fill")
                                .foregroundColor(.orange)
                                .font(.title3)
                            Text("How to Play")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        
                        VStack(spacing: 12) {
                            StepCard(
                                number: "1",
                                title: "Select Your Decks",
                                description: "Choose cards to include in memory game",
                                icon: "square.stack.3d.up.fill",
                                color: .blue
                            )
                            
                            StepCard(
                                number: "2",
                                title: "Find Matches",
                                description: "Tap cards to reveal and match pairs",
                                icon: "rectangle.2.swap",
                                color: .purple
                            )
                            
                            StepCard(
                                number: "3",
                                title: "Clear the Board",
                                description: "Match all pairs to complete the level",
                                icon: "trophy.fill",
                                color: .yellow
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Game mechanics section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "puzzlepiece.extension.fill")
                                .foregroundColor(.orange)
                                .font(.title3)
                            Text("Game Mechanics")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            GameMechanicCard(
                                title: "Card Matching",
                                icon: "rectangle.on.rectangle",
                                color: .blue,
                                description: "Match Dutch words with their definitions"
                            )
                            
                            GameMechanicCard(
                                title: "Memory Challenge",
                                icon: "brain.head.profile",
                                color: .purple,
                                description: "Remember card positions for better scores"
                            )
                            
                            GameMechanicCard(
                                title: "Progressive Difficulty",
                                icon: "chart.line.uptrend.xyaxis",
                                color: .green,
                                description: "More cards as you improve"
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Features highlights
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.orange)
                                .font(.title3)
                            Text("Memory Benefits")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            FeatureHighlight(
                                icon: "brain.fill",
                                title: "Working Memory",
                                description: "Strengthens short-term memory skills",
                                color: .orange
                            )
                            
                            FeatureHighlight(
                                icon: "arrow.triangle.2.circlepath",
                                title: "Pattern Recognition",
                                description: "Improves visual memory and recall",
                                color: .blue
                            )
                            
                            FeatureHighlight(
                                icon: "target",
                                title: "Focus Training",
                                description: "Enhances concentration and attention",
                                color: .purple
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Bottom padding
                    Spacer(minLength: 20)
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
}

#Preview {
    MemoryGameInfoView(viewModel: FlashCardViewModel())
} 