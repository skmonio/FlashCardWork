import SwiftUI

struct StudyInfoView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with gradient background
            ZStack {
                LinearGradient(
                    colors: [Color.teal.opacity(0.8), Color.teal],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Study Your Cards")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Learn efficiently with smart ordering")
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
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 50, weight: .light))
                            .foregroundColor(.teal)
                            .frame(width: 80, height: 80)
                            .background(
                                Circle()
                                    .fill(Color.teal.opacity(0.1))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.teal.opacity(0.3), lineWidth: 2)
                                    )
                            )
                        
                        Text("Smart learning with AI-powered card ordering")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 16)
                    
                    // How to use section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "hand.tap.fill")
                                .foregroundColor(.teal)
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
                                description: "Choose which card decks to study",
                                icon: "square.stack.3d.up.fill",
                                color: .blue
                            )
                            
                            StepCard(
                                number: "2",
                                title: "Swipe to Learn",
                                description: "Use gestures to mark your progress",
                                icon: "hand.draw.fill",
                                color: .purple
                            )
                            
                            StepCard(
                                number: "3",
                                title: "Tap for Features",
                                description: "Access pronunciation and examples",
                                icon: "speaker.wave.2.fill",
                                color: .orange
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Swipe gestures section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "arrow.left.and.right")
                                .foregroundColor(.teal)
                                .font(.title3)
                            Text("Swipe Gestures")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            SwipeCard(
                                direction: "Right",
                                icon: "arrow.right.circle.fill",
                                color: .green,
                                description: "I know this"
                            )
                            
                            SwipeCard(
                                direction: "Left",
                                icon: "arrow.left.circle.fill",
                                color: .red,
                                description: "Need practice"
                            )
                            
                            SwipeCard(
                                direction: "Up",
                                icon: "arrow.up.circle.fill",
                                color: .orange,
                                description: "Review later"
                            )
                            
                            SwipeCard(
                                direction: "Down",
                                icon: "arrow.down.circle.fill",
                                color: .gray,
                                description: "Skip for now"
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Tap features section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "hand.point.up.left.fill")
                                .foregroundColor(.teal)
                                .font(.title3)
                            Text("Tap Features")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            TapFeatureCard(
                                taps: "Single Tap",
                                icon: "speaker.wave.2",
                                color: .blue,
                                description: "Hear Dutch pronunciation"
                            )
                            
                            TapFeatureCard(
                                taps: "Double Tap",
                                icon: "arrow.2.circlepath",
                                color: .purple,
                                description: "Flip card to see definition"
                            )
                            
                            TapFeatureCard(
                                taps: "Triple Tap",
                                icon: "text.quote",
                                color: .orange,
                                description: "Show example sentence"
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Features highlights
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.teal)
                                .font(.title3)
                            Text("Smart Features")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            FeatureHighlight(
                                icon: "arrow.triangle.2.circlepath",
                                title: "Intelligent Ordering",
                                description: "Cards you struggle with appear more frequently",
                                color: .teal
                            )
                            
                            FeatureHighlight(
                                icon: "icloud.fill",
                                title: "Auto-Save Progress",
                                description: "Resume your study session anytime",
                                color: .blue
                            )
                            
                            FeatureHighlight(
                                icon: "waveform",
                                title: "Dutch Pronunciation",
                                description: "Native speaker audio for all words",
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

struct StepCard: View {
    let number: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            // Number circle
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Text(number)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            // Icon
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            // Content
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
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct SwipeCard: View {
    let direction: String
    let icon: String
    let color: Color
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(height: 30)
            
            Text(direction)
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

struct TapFeatureCard: View {
    let taps: String
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
                Text(taps)
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

struct FeatureHighlight: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
            }
            
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
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    StudyInfoView(viewModel: FlashCardViewModel())
} 