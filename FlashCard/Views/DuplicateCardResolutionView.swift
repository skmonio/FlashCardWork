import SwiftUI

struct DuplicateCardResolutionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    
    let existingCard: FlashCard
    let newCardData: NewCardData
    let comparison: FlashCardViewModel.CardComparison
    let onResolution: (ResolutionAction) -> Void
    
    struct NewCardData {
        let word: String
        let definition: String
        let example: String
        let deckIds: Set<UUID>
        let article: String
        let plural: String
        let pastTense: String
        let futureTense: String
        let pastParticiple: String
    }
    
    enum ResolutionAction {
        case keepExisting
        case replaceWithNew
        case mergeAdditionalFields
        case cancel
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Header with word
                    VStack(alignment: .center, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        
                        Text("Duplicate Card Found")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("The word \"\(existingCard.word)\" already exists")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)
                    
                    // Statistics
                    HStack(spacing: 20) {
                        StatCard(
                            icon: "doc.text.fill",
                            title: "Existing Card",
                            subtitle: "\(comparison.existingFilledFields) fields filled"
                        )
                        
                        StatCard(
                            icon: "doc.badge.plus",
                            title: "New Card",
                            subtitle: "\(comparison.newFilledFields) fields filled"
                        )
                        
                        if comparison.newFieldsCount > 0 {
                            StatCard(
                                icon: "plus.circle.fill",
                                title: "New Info",
                                subtitle: "\(comparison.newFieldsCount) additional fields",
                                color: .green
                            )
                        }
                    }
                    
                    // Field comparison
                    if !comparison.fieldDifferences.isEmpty {
                        Text("Field Differences")
                            .font(.headline)
                            .padding(.top)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(Array(comparison.fieldDifferences.keys.sorted()), id: \.self) { fieldKey in
                                if let difference = comparison.fieldDifferences[fieldKey] {
                                    FieldComparisonRow(
                                        fieldName: fieldDisplayName(fieldKey),
                                        existingValue: difference.existing,
                                        newValue: difference.new
                                    )
                                }
                            }
                        }
                    }
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Text("Choose an action:")
                            .font(.headline)
                            .padding(.top)
                        
                        ActionButton(
                            icon: "checkmark.circle.fill",
                            title: "Keep Existing",
                            subtitle: "Keep the current card unchanged",
                            color: .blue
                        ) {
                            onResolution(.keepExisting)
                            dismiss()
                        }
                        
                        if comparison.hasMoreInformation {
                            ActionButton(
                                icon: "arrow.up.arrow.down.circle.fill",
                                title: "Merge Additional Fields",
                                subtitle: "Add new information to empty fields",
                                color: .green
                            ) {
                                onResolution(.mergeAdditionalFields)
                                dismiss()
                            }
                        }
                        
                        ActionButton(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Replace with New",
                            subtitle: "Replace all information with new data",
                            color: .orange
                        ) {
                            onResolution(.replaceWithNew)
                            dismiss()
                        }
                        
                        ActionButton(
                            icon: "xmark.circle.fill",
                            title: "Cancel",
                            subtitle: "Don't add this card",
                            color: .red
                        ) {
                            onResolution(.cancel)
                            dismiss()
                        }
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Duplicate Card")
            .navigationBarItems(trailing: Button("Cancel") {
                onResolution(.cancel)
                dismiss()
            })
        }
    }
    
    private func fieldDisplayName(_ fieldKey: String) -> String {
        switch fieldKey {
        case "definition": return "Translation"
        case "example": return "Example"
        case "article": return "Article"
        case "plural": return "Plural"
        case "pastTense": return "Past Tense"
        case "futureTense": return "Future Tense"
        case "pastParticiple": return "Past Participle"
        default: return fieldKey.capitalized
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let subtitle: String
    var color: Color = .blue
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct FieldComparisonRow: View {
    let fieldName: String
    let existingValue: String
    let newValue: String
    
    private var hasExistingValue: Bool {
        !existingValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var hasNewValue: Bool {
        !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(fieldName)
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack(alignment: .top, spacing: 12) {
                // Existing value
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(hasExistingValue ? existingValue : "Empty")
                        .font(.body)
                        .foregroundColor(hasExistingValue ? .primary : .secondary)
                        .italic(!hasExistingValue)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(6)
                }
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                // New value
                VStack(alignment: .leading, spacing: 4) {
                    Text("New")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(hasNewValue ? newValue : "Empty")
                        .font(.body)
                        .foregroundColor(hasNewValue ? .primary : .secondary)
                        .italic(!hasNewValue)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(hasNewValue ? Color.green.opacity(0.1) : Color(UIColor.systemGray6))
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(UIColor.systemGray4), lineWidth: 1)
        )
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let viewModel = FlashCardViewModel()
    let existingCard = FlashCard(
        word: "eten",
        definition: "to eat",
        example: "Ik ga eten.",
        article: "het",
        plural: ""
    )
    
    let newCardData = DuplicateCardResolutionView.NewCardData(
        word: "eten",
        definition: "to eat",
        example: "Ik ga vanavond eten.",
        deckIds: [],
        article: "het",
        plural: "etens",
        pastTense: "at",
        futureTense: "zal eten",
        pastParticiple: "gegeten"
    )
    
    let comparison = FlashCardViewModel.CardComparison(
        existingFilledFields: 3,
        newFilledFields: 6,
        fieldDifferences: [
            "example": ("Ik ga eten.", "Ik ga vanavond eten."),
            "plural": ("", "etens"),
            "pastTense": ("", "at")
        ],
        newFieldsCount: 4
    )
    
    return DuplicateCardResolutionView(
        viewModel: viewModel,
        existingCard: existingCard,
        newCardData: newCardData,
        comparison: comparison
    ) { action in
        print("Resolution: \(action)")
    }
} 