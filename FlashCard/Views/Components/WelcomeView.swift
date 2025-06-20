import SwiftUI

struct WelcomeView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with app name and icon
                    VStack(spacing: 16) {
                        // App icon placeholder (you can replace with actual icon)
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 1.0, green: 0.6, blue: 0.0),
                                            Color(red: 0.2, green: 0.8, blue: 0.6)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            Text("🃏")
                                .font(.system(size: 40))
                        }
                        
                        Text("Welcome to Taal Trek!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Your Dutch learning companion")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // App overview sections
                    LazyVStack(spacing: 20) {
                        // Home View Section
                        WelcomeSection(
                            icon: "house.fill",
                            iconColor: .blue,
                            title: "Home View",
                            description: "Your learning dashboard where you can:",
                            features: [
                                "View your learning streak",
                                "See quick stats and progress",
                                "Access all main features",
                                "Start studying your cards"
                            ]
                        )
                        
                        // Cards Section
                        WelcomeSection(
                            icon: "rectangle.stack.fill",
                            iconColor: .green,
                            title: "Cards View",
                            description: "Manage your flashcard collection:",
                            features: [
                                "Add new Dutch words and definitions",
                                "Edit existing cards",
                                "Organize cards into decks",
                                "Import/export your vocabulary"
                            ]
                        )
                        
                        // Study Mode Section
                        WelcomeSection(
                            icon: "brain.head.profile",
                            iconColor: .orange,
                            title: "Study Your Cards",
                            description: "Interactive learning experience:",
                            features: [
                                "Swipe right if you know the word",
                                "Swipe left if you don't know it",
                                "Swipe up to review later",
                                "Swipe down to skip",
                                "Double tap to flip cards",
                                "Tap once to hear pronunciation"
                            ]
                        )
                        
                        // Settings Section
                        WelcomeSection(
                            icon: "gearshape.fill",
                            iconColor: .purple,
                            title: "Settings",
                            description: "Customize your experience:",
                            features: [
                                "Adjust speech settings",
                                "Manage your data",
                                "Export/import cards",
                                "Configure app preferences"
                            ]
                        )
                        
                        // Tips Section
                        WelcomeSection(
                            icon: "lightbulb.fill",
                            iconColor: .yellow,
                            title: "Pro Tips",
                            description: "Get the most out of Taal Trek:",
                            features: [
                                "Study a little bit every day",
                                "Use the audio feature to improve pronunciation",
                                "Review unknown cards regularly",
                                "Add example sentences for context"
                            ]
                        )
                    }
                    
                    // Get Started Button
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Let's Start Learning!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.6, blue: 0.0),
                                        Color(red: 0.2, green: 0.8, blue: 0.6)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                    .padding(.top)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct WelcomeSection: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let features: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(features, id: \.self) { feature in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(iconColor)
                            .padding(.top, 2)
                        
                        Text(feature)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                }
            }
            .padding(.leading, 42)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

// Preview
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(isPresented: .constant(true))
    }
} 