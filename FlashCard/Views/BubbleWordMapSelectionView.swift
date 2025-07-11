import SwiftUI

struct BubbleWordMapSelectionView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @StateObject private var bubbleManager: BubbleWordManager
    @State private var showingCreateMap = false
    @State private var newMapName = ""
    @State private var selectedMapId: UUID?
    @State private var mapToDelete: BubbleWordMap?
    @State private var showingDeleteAlert = false
    @State private var mapToRename: BubbleWordMap?
    @State private var showingRenameAlert = false
    @State private var renameText = ""
    
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    
    init(viewModel: FlashCardViewModel, bubbleManager: BubbleWordManager? = nil) {
        self.viewModel = viewModel
        self._bubbleManager = StateObject(wrappedValue: bubbleManager ?? BubbleWordManager.shared)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Standard Header
            UnifiedHeader(
                title: "Bubble Word Maps",
                showBackButton: true,
                onBack: {
                    navigationCoordinator.pop()
                }
            )
            
            // Main content
            VStack(spacing: 0) {
                // Create new map button
                VStack(spacing: 16) {
                    Button(action: {
                        showingCreateMap = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Create New Map")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.green, .teal],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
                
                // Maps list
                if bubbleManager.maps.isEmpty {
                    emptyStateView
                } else {
                    mapsListView
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingCreateMap) {
            createMapSheet
        }
        .alert("Delete Map", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let map = mapToDelete {
                    bubbleManager.deleteMap(map.id)
                }
                mapToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                mapToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this map? This action cannot be undone.")
        }
        .alert("Rename Map", isPresented: $showingRenameAlert) {
            TextField("Map name", text: $renameText)
            Button("Rename") {
                if let map = mapToRename, !renameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    renameMap(map, to: renameText.trimmingCharacters(in: .whitespacesAndNewlines))
                }
                mapToRename = nil
                renameText = ""
            }
            Button("Cancel", role: .cancel) {
                mapToRename = nil
                renameText = ""
            }
        } message: {
            Text("Enter a new name for your map:")
        }
    }
    
    // MARK: - Views
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .teal],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 12) {
                Text("No Maps Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Create your first bubble word map to start organizing your vocabulary visually")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
    }
    
    private var mapsListView: some View {
        List {
            ForEach(bubbleManager.maps) { map in
                mapCardView(for: map)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
    }
    
    private func mapCardView(for map: BubbleWordMap) -> some View {
        Button(action: {
            bubbleManager.selectMap(map.id)
            selectedMapId = map.id
            // Set navigation path to [mapSelection, map]
            var path = NavigationPath()
            path.append(NavigationDestination.bubbleWordMapSelection)
            path.append(NavigationDestination.bubbleWord)
            navigationCoordinator.navigationPath = path
        }) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(map.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        HStack(spacing: 16) {
                            Label("\(map.nodes.count) words", systemImage: "bubble.left.and.bubble.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Label("\(map.connections.count) connections", systemImage: "line.diagonal")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    if bubbleManager.selectedMapId == map.id {
                        Text("Current")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                // Preview of nodes (if any)
                if !map.nodes.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(Array(map.nodes.prefix(5))) { node in
                            Text(node.word)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: node.color)?.opacity(0.2) ?? Color.blue.opacity(0.2))
                                .foregroundColor(Color(hex: node.color) ?? .blue)
                                .cornerRadius(8)
                        }
                        if map.nodes.count > 5 {
                            Text("+\(map.nodes.count - 5)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                mapToDelete = map
                showingDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
            Button {
                mapToRename = map
                renameText = map.name
                showingRenameAlert = true
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
    
    private var createMapSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .teal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Create New Map")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Give your bubble word map a name to get started")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Map Name")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter map name...", text: $newMapName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingCreateMap = false
                        newMapName = ""
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createNewMap()
                    }
                    .disabled(newMapName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func createNewMap() {
        let trimmedName = newMapName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let newMap = bubbleManager.createMap(name: trimmedName)
        showingCreateMap = false
        newMapName = ""
        
        // Select and open the new map
        selectedMapId = newMap.id
        bubbleManager.selectMap(newMap.id)
        var path = NavigationPath()
        path.append(NavigationDestination.bubbleWordMapSelection)
        path.append(NavigationDestination.bubbleWord)
        navigationCoordinator.navigationPath = path
    }
    
    private func renameMap(_ map: BubbleWordMap, to newName: String) {
        guard let index = bubbleManager.maps.firstIndex(where: { $0.id == map.id }) else { return }
        bubbleManager.maps[index].name = newName
        bubbleManager.maps[index].lastModified = Date()
        bubbleManager.saveData()
    }
}

// MARK: - Preview
struct BubbleWordMapSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleWordMapSelectionView(viewModel: FlashCardViewModel())
    }
} 