import SwiftUI

struct DuplicateSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    
    let cardEntries: [CardEntry]
    let duplicateResults: [Int: FlashCardViewModel.DuplicateCheckResult]
    let selectedDeckIds: Set<UUID>
    let onResolution: ([CardEntry]) -> Void
    
    @State private var resolutionChoices: [Int: ResolutionChoice] = [:]
    
    enum ResolutionChoice {
        case skipCard
        case keepExisting
        case replaceWithNew
        case mergeAdditionalFields
    }
    
    private var duplicateIndices: [Int] {
        Array(duplicateResults.keys).sorted()
    }
    
    private var nonDuplicateEntries: [CardEntry] {
        cardEntries.enumerated().compactMap { index, entry in
            duplicateResults[index] == nil ? entry : nil
        }
    }
    
    private var canProceed: Bool {
        duplicateIndices.allSatisfy { resolutionChoices[$0] != nil }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Header
                    VStack(alignment: .center, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        
                        Text("Duplicate Cards Found")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("\(duplicateIndices.count) duplicate(s) found out of \(cardEntries.count) cards")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)
                    
                    // Summary stats
                    HStack(spacing: 20) {
                        StatCard(
                            icon: "checkmark.circle.fill",
                            title: "Ready to Add",
                            subtitle: "\(nonDuplicateEntries.count) cards",
                            color: .green
                        )
                        
                        StatCard(
                            icon: "exclamationmark.triangle.fill",
                            title: "Need Review",
                            subtitle: "\(duplicateIndices.count) duplicates",
                            color: .orange
                        )
                    }
                    
                    // Bulk actions
                    if !duplicateIndices.isEmpty {
                        Text("Bulk Actions")
                            .font(.headline)
                            .padding(.top)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            BulkActionButton(
                                title: "Skip All Duplicates",
                                icon: "xmark.circle",
                                color: .red
                            ) {
                                for index in duplicateIndices {
                                    resolutionChoices[index] = .skipCard
                                }
                            }
                            
                            BulkActionButton(
                                title: "Keep All Existing",
                                icon: "checkmark.circle",
                                color: .blue
                            ) {
                                for index in duplicateIndices {
                                    resolutionChoices[index] = .keepExisting
                                }
                            }
                            
                            BulkActionButton(
                                title: "Merge All Additional",
                                icon: "arrow.up.arrow.down.circle",
                                color: .green
                            ) {
                                for index in duplicateIndices {
                                    if case .partialMatch(_, let comparison) = duplicateResults[index],
                                       comparison.hasMoreInformation {
                                        resolutionChoices[index] = .mergeAdditionalFields
                                    } else {
                                        resolutionChoices[index] = .keepExisting
                                    }
                                }
                            }
                            
                            BulkActionButton(
                                title: "Replace All",
                                icon: "arrow.triangle.2.circlepath",
                                color: .orange
                            ) {
                                for index in duplicateIndices {
                                    resolutionChoices[index] = .replaceWithNew
                                }
                            }
                        }
                    }
                    
                    // Individual duplicates
                    if !duplicateIndices.isEmpty {
                        Text("Individual Duplicates")
                            .font(.headline)
                            .padding(.top)
                        
                        LazyVStack(spacing: 16) {
                            ForEach(duplicateIndices, id: \.self) { index in
                                if let result = duplicateResults[index] {
                                    DuplicateCardRow(
                                        cardEntry: cardEntries[index],
                                        duplicateResult: result,
                                        selectedChoice: $resolutionChoices[index]
                                    )
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Resolve Duplicates")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Apply") {
                    applyResolutions()
                }
                .disabled(!canProceed)
            )
        }
    }
    
    private func applyResolutions() {
        var finalEntries = nonDuplicateEntries
        
        for index in duplicateIndices {
            guard let choice = resolutionChoices[index],
                  let result = duplicateResults[index] else { continue }
            
            switch choice {
            case .skipCard:
                // Don't add this card
                break
                
            case .keepExisting:
                // Don't add this card, but merge deck associations
                if case .partialMatch(let existingCard, _) = result {
                    viewModel.mergeCardData(
                        existingCard: existingCard,
                        newDefinition: existingCard.definition,
                        newExample: existingCard.example,
                        newDeckIds: selectedDeckIds,
                        newArticle: existingCard.article,
                        newPlural: existingCard.plural,
                        newPastTense: existingCard.pastTense,
                        newFutureTense: existingCard.futureTense,
                        newPastParticiple: existingCard.pastParticiple,
                        mergeStrategy: .keepExisting
                    )
                }
                
            case .replaceWithNew:
                // Replace existing card with new data
                if case .partialMatch(let existingCard, _) = result {
                    let entry = cardEntries[index]
                    viewModel.mergeCardData(
                        existingCard: existingCard,
                        newDefinition: entry.definition,
                        newExample: entry.example,
                        newDeckIds: selectedDeckIds,
                        newArticle: entry.article,
                        newPlural: entry.plural,
                        newPastTense: entry.pastTense,
                        newFutureTense: entry.futureTense,
                        newPastParticiple: entry.pastParticiple,
                        mergeStrategy: .replaceWithNew
                    )
                }
                
            case .mergeAdditionalFields:
                // Merge additional fields
                if case .partialMatch(let existingCard, _) = result {
                    let entry = cardEntries[index]
                    viewModel.mergeCardData(
                        existingCard: existingCard,
                        newDefinition: entry.definition,
                        newExample: entry.example,
                        newDeckIds: selectedDeckIds,
                        newArticle: entry.article,
                        newPlural: entry.plural,
                        newPastTense: entry.pastTense,
                        newFutureTense: entry.futureTense,
                        newPastParticiple: entry.pastParticiple,
                        mergeStrategy: .mergeAdditionalFields
                    )
                }
            }
        }
        
        onResolution(finalEntries)
    }
}

struct BulkActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DuplicateCardRow: View {
    let cardEntry: CardEntry
    let duplicateResult: FlashCardViewModel.DuplicateCheckResult
    @Binding var selectedChoice: DuplicateSummaryView.ResolutionChoice?
    
    private var existingCard: FlashCard? {
        switch duplicateResult {
        case .exactMatch(let card), .partialMatch(let card, _):
            return card
        case .noDuplicate:
            return nil
        }
    }
    
    private var comparison: FlashCardViewModel.CardComparison? {
        if case .partialMatch(_, let comp) = duplicateResult {
            return comp
        }
        return nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Card info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(cardEntry.word)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(cardEntry.definition)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let comparison = comparison {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Existing: \(comparison.existingFilledFields) fields")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("New: \(comparison.newFilledFields) fields")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if comparison.newFieldsCount > 0 {
                            Text("+\(comparison.newFieldsCount) additional")
                                .font(.caption)
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            
            // Resolution choices
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ChoiceButton(
                    title: "Skip",
                    icon: "xmark.circle",
                    color: .red,
                    isSelected: selectedChoice == .skipCard
                ) {
                    selectedChoice = .skipCard
                }
                
                ChoiceButton(
                    title: "Keep Existing",
                    icon: "checkmark.circle",
                    color: .blue,
                    isSelected: selectedChoice == .keepExisting
                ) {
                    selectedChoice = .keepExisting
                }
                
                if let comparison = comparison, comparison.hasMoreInformation {
                    ChoiceButton(
                        title: "Merge Fields",
                        icon: "arrow.up.arrow.down.circle",
                        color: .green,
                        isSelected: selectedChoice == .mergeAdditionalFields
                    ) {
                        selectedChoice = .mergeAdditionalFields
                    }
                }
                
                ChoiceButton(
                    title: "Replace",
                    icon: "arrow.triangle.2.circlepath",
                    color: .orange,
                    isSelected: selectedChoice == .replaceWithNew
                ) {
                    selectedChoice = .replaceWithNew
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

struct ChoiceButton: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color(UIColor.systemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let viewModel = FlashCardViewModel()
    let entries = [
        CardEntry(word: "eten", definition: "to eat", example: "Ik ga eten."),
        CardEntry(word: "drinken", definition: "to drink", example: "")
    ]
    
    let duplicateResults: [Int: FlashCardViewModel.DuplicateCheckResult] = [
        0: .partialMatch(
            FlashCard(word: "eten", definition: "to eat", example: ""),
            differences: FlashCardViewModel.CardComparison(
                existingFilledFields: 2,
                newFilledFields: 3,
                fieldDifferences: ["example": ("", "Ik ga eten.")],
                newFieldsCount: 1
            )
        )
    ]
    
    return DuplicateSummaryView(
        viewModel: viewModel,
        cardEntries: entries,
        duplicateResults: duplicateResults,
        selectedDeckIds: []
    ) { finalEntries in
        print("Final entries: \(finalEntries.count)")
    }
} 