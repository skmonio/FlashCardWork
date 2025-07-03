import SwiftUI

struct WordScrambleInfoView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero icon
                    VStack(spacing: 12) {
                        Image(systemName: "textformat.abc")
                            .font(.system(size: 50, weight: .light))
                            .foregroundColor(.red)
                            .frame(width: 80, height: 80)
                            .background(
                                Circle()
                                    .fill(Color.red.opacity(0.1))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.red.opacity(0.3), lineWidth: 2)
                                    )
                            )
                        
                        Text("Unscramble mixed-up letters to form the correct Dutch words")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 16)
                    
                    // How to use section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "shuffle")
                                .foregroundColor(.red)
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
                                description: "Choose cards for the word scramble",
                                icon: "square.stack.3d.up.fill",
                                color: .blue
                            )
                            
                            StepCard(
                                number: "2",
                                title: "Unscramble Letters",
                                description: "Rearrange jumbled letters correctly",
                                icon: "arrow.triangle.swap",
                                color: .purple
                            )
                            
                            StepCard(
                                number: "3",
                                title: "Form Words",
                                description: "Create the correct Dutch word",
                                icon: "checkmark.circle.fill",
                                color: .green
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Scramble features section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "tornado")
                                .foregroundColor(.red)
                                .font(.title3)
                            Text("Scramble Features")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ScrambleFeatureCard(
                                title: "Letter Mixing",
                                icon: "shuffle.circle.fill",
                                color: .red,
                                description: "Letters are randomly scrambled each time"
                            )
                            
                            ScrambleFeatureCard(
                                title: "Hint System",
                                icon: "lightbulb.circle.fill",
                                color: .yellow,
                                description: "Get hints when you're stuck"
                            )
                            
                            ScrambleFeatureCard(
                                title: "Difficulty Levels",
                                icon: "chart.bar.fill",
                                color: .blue,
                                description: "Shorter to longer words as you progress"
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Learning benefits
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.red)
                                .font(.title3)
                            Text("Learning Benefits")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            FeatureHighlight(
                                icon: "textformat.abc",
                                title: "Letter Recognition",
                                description: "Improves spelling and letter patterns",
                                color: .red
                            )
                            
                            FeatureHighlight(
                                icon: "brain.head.profile",
                                title: "Problem Solving",
                                description: "Develops analytical thinking skills",
                                color: .blue
                            )
                            
                            FeatureHighlight(
                                icon: "eye.fill",
                                title: "Visual Processing",
                                description: "Enhances pattern recognition abilities",
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

struct ScrambleFeatureCard: View {
    let title: String
    let icon: String
    let color: Color
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

#Preview {
    WordScrambleInfoView(viewModel: FlashCardViewModel())
} 