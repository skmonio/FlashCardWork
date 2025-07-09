import SwiftUI

struct DeckDropdownChecklist: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Binding var selectedDeckIds: Set<UUID>
    @State private var isExpanded: Bool = false
    
    var availableCards: [FlashCard] {
        if selectedDeckIds.isEmpty {
            return []
        } else {
            var uniqueCards: Set<FlashCard> = []
            for deckId in selectedDeckIds {
                if let deck = viewModel.decks.first(where: { $0.id == deckId }) {
                    // Add cards from this deck
                    uniqueCards.formUnion(deck.cards)
                    
                    // Add cards from all sub-decks
                    let subDecks = viewModel.getSubDecks(for: deck.id)
                    for subDeck in subDecks {
                        uniqueCards.formUnion(subDeck.cards)
                    }
                }
            }
            return Array(uniqueCards)
        }
    }
    
    var autoIncludedParentDecks: [Deck] {
        var autoIncluded: [Deck] = []
        for deckId in selectedDeckIds {
            if let deck = viewModel.decks.first(where: { $0.id == deckId }),
               let parentId = deck.parentId,
               !selectedDeckIds.contains(parentId),
               let parentDeck = viewModel.decks.first(where: { $0.id == parentId }) {
                autoIncluded.append(parentDeck)
            }
        }
        return autoIncluded
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
                HapticManager.shared.lightImpact()
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Selected Decks")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if selectedDeckIds.isEmpty {
                            Text("Tap to select decks")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            let autoIncludedCount = autoIncludedParentDecks.count
                            if autoIncludedCount > 0 {
                                Text("\(selectedDeckIds.count) deck\(selectedDeckIds.count == 1 ? "" : "s") • \(availableCards.count) cards • \(autoIncludedCount) parent\(autoIncludedCount == 1 ? "" : "s") auto-included")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("\(selectedDeckIds.count) deck\(selectedDeckIds.count == 1 ? "" : "s") • \(availableCards.count) cards")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded content
            if isExpanded {
                VStack(spacing: 0) {
                    // Select All / Deselect All button
                    Button(action: {
                        if !selectedDeckIds.isEmpty {
                            selectedDeckIds.removeAll()
                        } else {
                            selectedDeckIds = Set(viewModel.getAllDecksHierarchical().map { $0.id })
                        }
                        HapticManager.shared.lightImpact()
                    }) {
                        HStack {
                            Text(selectedDeckIds.isEmpty ? "Select All Decks" : "Deselect All")
                                .foregroundColor(.blue)
                            Spacer()
                            Text("\(availableCards.count) cards")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider()
                    
                    // Show auto-included parent decks note
                    if !autoIncludedParentDecks.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Note: Parent decks will be automatically included when exporting sub-decks")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            
                            ForEach(autoIncludedParentDecks) { parentDeck in
                                HStack {
                                    Text("    ↳ Auto-including: \(parentDeck.name)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 2)
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        
                        Divider()
                    }
                    
                    // Deck list
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.getAllDecksHierarchical()) { deck in
                            DeckRow(
                                deck: deck,
                                isSelected: selectedDeckIds.contains(deck.id),
                                onToggle: {
                                    if selectedDeckIds.contains(deck.id) {
                                        selectedDeckIds.remove(deck.id)
                                    } else {
                                        selectedDeckIds.insert(deck.id)
                                    }
                                    HapticManager.shared.lightImpact()
                                }
                            )
                            
                            if deck.id != viewModel.getAllDecksHierarchical().last?.id {
                                Divider()
                                    .padding(.leading, deck.isSubDeck ? 40 : 16)
                            }
                        }
                    }
                }
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.top, 8)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
            }
        }
    }
}

struct DeckRow: View {
    let deck: Deck
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                // Checkbox
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.system(size: 20))
                
                // Deck info
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        if deck.isSubDeck {
                            Text("    ↳")
                                .foregroundColor(.secondary)
                        }
                        Text(deck.name)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    
                    if !deck.isSubDeck {
                        Text("\(deck.cards.count) cards")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Card count for sub-decks
                if deck.isSubDeck {
                    Text("\(deck.cards.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DeckDropdownChecklist_Previews: PreviewProvider {
    static var previews: some View {
        DeckDropdownChecklist(
            viewModel: FlashCardViewModel(),
            selectedDeckIds: .constant(Set())
        )
        .padding()
    }
} 