import SwiftUI

struct SavedGamesView: View {
    @ObservedObject private var saveStateManager = SaveStateManager.shared
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingClearAllConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack {
                if saveStateManager.availableSaveStates.isEmpty {
                    emptyStateView
                } else {
                    savedGamesList
                }
            }
            .navigationTitle("Saved Games")
            .navigationBarTitleDisplayMode(.large)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                if !saveStateManager.availableSaveStates.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear All") {
                            showingClearAllConfirmation = true
                        }
                        .foregroundColor(.red)
                    }
                }
            })
            .alert("Clear All Saved Games?", isPresented: $showingClearAllConfirmation) {
                Button("Clear All", role: .destructive) {
                    saveStateManager.clearAllSaveStates()
                    HapticManager.shared.successNotification()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently delete all saved game progress. This action cannot be undone.")
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Saved Games")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("When you save progress in games, they'll appear here.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var savedGamesList: some View {
        List {
            ForEach(groupedSaveStates.keys.sorted { $0.displayName < $1.displayName }, id: \.self) { gameType in
                Section(header: gameTypeHeader(gameType)) {
                    ForEach(groupedSaveStates[gameType] ?? [], id: \.id) { saveState in
                        SavedGameRow(
                            saveState: saveState,
                            viewModel: viewModel,
                            onDelete: {
                                deleteSaveState(saveState)
                            }
                        )
                    }
                }
            }
        }
    }
    
    private var groupedSaveStates: [GameSaveState.SavedGameType: [GameSaveState]] {
        Dictionary(grouping: saveStateManager.availableSaveStates) { $0.gameType }
    }
    
    private func gameTypeHeader(_ gameType: GameSaveState.SavedGameType) -> some View {
        HStack {
            Image(systemName: gameType.icon)
                .foregroundColor(.blue)
            Text(gameType.displayName)
                .font(.headline)
        }
    }
    
    private func deleteSaveState(_ saveState: GameSaveState) {
        saveStateManager.deleteSaveState(gameType: saveState.gameType)
        HapticManager.shared.lightImpact()
    }
}

struct SavedGameRow: View {
    let saveState: GameSaveState
    @ObservedObject var viewModel: FlashCardViewModel
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(saveState.gameType.displayName)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("Saved \(formatDate(saveState.savedAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: saveState.gameType.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.title3)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Preview
struct SavedGamesView_Previews: PreviewProvider {
    static var previews: some View {
        SavedGamesView(viewModel: FlashCardViewModel())
    }
} 