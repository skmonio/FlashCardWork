import SwiftUI

struct DutchGrammarInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "book.pages.fill")
                                .font(.largeTitle)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Dutch Grammar")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("A1-B1 Level Rules")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        Text("Master the fundamentals of Dutch grammar with our comprehensive guide covering essential rules and patterns for beginners to intermediate learners.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // What's Included Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What's Included")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            FeatureRow(
                                icon: "textformat.abc",
                                title: "Basic Grammar Rules",
                                description: "Articles, nouns, adjectives, and basic sentence structure"
                            )
                            
                            FeatureRow(
                                icon: "arrow.left.and.right",
                                title: "Word Order",
                                description: "Dutch sentence structure and word placement rules"
                            )
                            
                            FeatureRow(
                                icon: "person.2.fill",
                                title: "Verb Conjugation",
                                description: "Present, past, and future tense verb forms"
                            )
                            
                            FeatureRow(
                                icon: "questionmark.circle.fill",
                                title: "Question Formation",
                                description: "How to ask questions in Dutch"
                            )
                            
                            FeatureRow(
                                icon: "arrow.triangle.2.circlepath",
                                title: "Negation",
                                description: "How to form negative sentences"
                            )
                            
                            FeatureRow(
                                icon: "link",
                                title: "Connectors",
                                description: "Linking words and conjunctions"
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // How to Use Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How to Use")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            InstructionRow(
                                number: "1",
                                title: "Browse Rules",
                                description: "Explore grammar rules organized by difficulty level"
                            )
                            
                            InstructionRow(
                                number: "2",
                                title: "Study Examples",
                                description: "Learn from clear examples and explanations"
                            )
                            
                            InstructionRow(
                                number: "3",
                                title: "Practice",
                                description: "Use the rules to create your own flashcards"
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Tips Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Learning Tips")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            GrammarTipRow(
                                icon: "graduationcap.fill",
                                title: "Start with Basics",
                                description: "Begin with A1 level rules before moving to more complex topics"
                            )
                            
                            GrammarTipRow(
                                icon: "repeat.circle.fill",
                                title: "Practice Regularly",
                                description: "Review grammar rules frequently to reinforce learning"
                            )
                            
                            GrammarTipRow(
                                icon: "pencil.and.scribble",
                                title: "Create Examples",
                                description: "Write your own sentences using the grammar rules you learn"
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .navigationTitle("Dutch Grammar Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct InstructionRow: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Color.blue)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct GrammarTipRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct DutchGrammarInfoView_Previews: PreviewProvider {
    static var previews: some View {
        DutchGrammarInfoView()
    }
} 