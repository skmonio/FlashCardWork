import SwiftUI

struct TrueFalseInfoView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with gradient background
            ZStack {
                LinearGradient(
                    colors: [Color.red.opacity(0.8), Color.red],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("True or False")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Quick decisions: true or false answers")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                            .background(Circle().fill(.white.opacity(0.2)))
                    }
                }
                .padding()
            }
            .frame(height: 80)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Hero icon
                    VStack(spacing: 12) {
                        Image(systemName: "questionmark.diamond")
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
                        
                        Text("Fast-paced true or false questions to test your knowledge")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 16)
                    
                    // How to use section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(.red)
                                .font(.title3)
                            Text("How to Use")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        
                        VStack(spacing: 12) {
                            StepCard(
                                number: "1",
                                title: "Select Your Decks",
                                description: "Choose which card decks to challenge",
                                icon: "square.stack.3d.up.fill",
                                color: .blue
                            )
                            
                            StepCard(
                                number: "2",
                                title: "Answer Quickly",
                                description: "Decide if the statement is true or false",
                                icon: "timer",
                                color: .purple
                            )
                            
                            StepCard(
                                number: "3",
                                title: "Build Speed",
                                description: "Improve your reaction time and accuracy",
                                icon: "speedometer",
                                color: .green
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Game controls section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "hand.thumbsup.fill")
                                .foregroundColor(.red)
                                .font(.title3)
                            Text("Game Controls")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ControlCard(
                                action: "True",
                                icon: "checkmark.circle.fill",
                                color: .green,
                                description: "Statement is correct"
                            )
                            
                            ControlCard(
                                action: "False",
                                icon: "xmark.circle.fill",
                                color: .red,
                                description: "Statement is incorrect"
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Features highlights
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.red)
                                .font(.title3)
                            Text("Game Features")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            FeatureHighlight(
                                icon: "stopwatch",
                                title: "Quick Rounds",
                                description: "Fast-paced gameplay for active learning",
                                color: .red
                            )
                            
                            FeatureHighlight(
                                icon: "chart.bar.fill",
                                title: "Accuracy Tracking",
                                description: "Monitor your true/false success rate",
                                color: .blue
                            )
                            
                            FeatureHighlight(
                                icon: "brain.head.profile",
                                title: "Quick Thinking",
                                description: "Develop faster decision-making skills",
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
        }
    }
}

struct ControlCard: View {
    let action: String
    let icon: String
    let color: Color
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(height: 30)
            
            Text(action)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

#Preview {
    TrueFalseInfoView(viewModel: FlashCardViewModel())
} 