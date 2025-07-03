import SwiftUI

struct WritingInfoView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero icon
                    VStack(spacing: 12) {
                        Image(systemName: "pencil.and.scribble")
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
                        
                        Text("Improve spelling and writing skills with hands-on practice")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 16)
                    
                    // How to use section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "keyboard.fill")
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
                                description: "Choose which card decks to practice writing",
                                icon: "square.stack.3d.up.fill",
                                color: .blue
                            )
                            
                            StepCard(
                                number: "2",
                                title: "Type the Word",
                                description: "Write the Dutch word from the definition",
                                icon: "textformat.abc",
                                color: .purple
                            )
                            
                            StepCard(
                                number: "3",
                                title: "Check Spelling",
                                description: "Get instant feedback on your writing",
                                icon: "checkmark.seal.fill",
                                color: .green
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Writing features section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "text.cursor")
                                .foregroundColor(.orange)
                                .font(.title3)
                            Text("Writing Features")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            WritingFeatureCard(
                                title: "Auto-Complete",
                                icon: "lightbulb.fill",
                                color: .yellow,
                                description: "Smart suggestions as you type"
                            )
                            
                            WritingFeatureCard(
                                title: "Spell Check",
                                icon: "textformat.abc.dottedunderline",
                                color: .blue,
                                description: "Instant feedback on spelling accuracy"
                            )
                            
                            WritingFeatureCard(
                                title: "Article Practice",
                                icon: "a.square.fill",
                                color: .purple,
                                description: "Learn correct articles (de/het) too"
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Benefits section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.orange)
                                .font(.title3)
                            Text("Learning Benefits")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            FeatureHighlight(
                                icon: "hand.write.fill",
                                title: "Active Learning",
                                description: "Writing reinforces memory better than reading",
                                color: .orange
                            )
                            
                            FeatureHighlight(
                                icon: "abc",
                                title: "Spelling Mastery",
                                description: "Perfect your Dutch spelling skills",
                                color: .blue
                            )
                            
                            FeatureHighlight(
                                icon: "brain.fill",
                                title: "Memory Boost",
                                description: "Motor memory helps long-term retention",
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

struct WritingFeatureCard: View {
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
    WritingInfoView(viewModel: FlashCardViewModel())
} 