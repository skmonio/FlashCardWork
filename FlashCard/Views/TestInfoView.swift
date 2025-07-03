import SwiftUI

struct TestInfoView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero icon
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.badge.questionmark")
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
                        
                        Text("Test your knowledge with multiple choice questions")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 16)
                    
                    // How to use section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "questionmark.bubble.fill")
                                .foregroundColor(.orange)
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
                                description: "Choose which card decks to test",
                                icon: "square.stack.3d.up.fill",
                                color: .blue
                            )
                            
                            StepCard(
                                number: "2",
                                title: "Answer Questions",
                                description: "Choose the correct definition from 4 options",
                                icon: "list.bullet.circle.fill",
                                color: .purple
                            )
                            
                            StepCard(
                                number: "3",
                                title: "Review Results",
                                description: "See your score and review mistakes",
                                icon: "chart.bar.fill",
                                color: .green
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Game mechanics section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "gamecontroller.fill")
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
                                title: "Multiple Choice",
                                icon: "list.number",
                                color: .blue,
                                description: "4 answer options for each question"
                            )
                            
                            GameMechanicCard(
                                title: "Smart Scoring",
                                icon: "target",
                                color: .green,
                                description: "Points based on accuracy and speed"
                            )
                            
                            GameMechanicCard(
                                title: "Progress Tracking",
                                icon: "chart.line.uptrend.xyaxis",
                                color: .purple,
                                description: "Track your improvement over time"
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
                            Text("Test Features")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            FeatureHighlight(
                                icon: "timer",
                                title: "Timed Questions",
                                description: "Optional time pressure for extra challenge",
                                color: .orange
                            )
                            
                            FeatureHighlight(
                                icon: "icloud.fill",
                                title: "Auto-Save Progress",
                                description: "Resume your test session anytime",
                                color: .blue
                            )
                            
                            FeatureHighlight(
                                icon: "trophy.fill",
                                title: "Performance Stats",
                                description: "Detailed results and improvement suggestions",
                                color: .yellow
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

struct GameMechanicCard: View {
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
    TestInfoView(viewModel: FlashCardViewModel())
} 