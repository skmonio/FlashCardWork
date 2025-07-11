import SwiftUI

struct BubbleWordView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @StateObject private var bubbleManager: BubbleWordManager
    @State private var newWord = ""
    @State private var newNoteColorValue: Color = .blue
    @State private var newDefinition = "" // Add definition field
    @State private var showingAddWord = false
    @State private var showingAddTypeSheet = false // For action sheet
    @State private var showingAddExistingCard = false // For card picker
    @State private var searchText = ""
    @State private var nodeToDelete: UUID? = nil
    @State private var selectedNodeForEdit: WordNode? = nil
    @State private var showingEditCard = false
    @State private var previousSelectedNodeId: UUID? = nil
    @State private var dragStartPositions: [UUID: CGPoint] = [:] // Track drag start positions
    @State private var pendingDeleteConnection: WordConnection? = nil // For connection delete confirmation
    
    // State for editing
    @State private var editedWord: String = ""
    @State private var editedColorValue: Color = .blue
    // Color palette
    private let noteColors: [NoteColor] = [.blue, .green, .orange, .purple, .red, .pink, .yellow, .mint, .indigo]
    enum NoteColor: String, CaseIterable {
        case blue, green, orange, purple, red, pink, yellow, mint, indigo
        var swiftUIColor: Color {
            switch self {
            case .blue: return .blue
            case .green: return .green
            case .orange: return .orange
            case .purple: return .purple
            case .red: return .red
            case .pink: return .pink
            case .yellow: return .yellow
            case .mint: return .mint
            case .indigo: return .indigo
            }
        }
    }
    
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var showingSavePrompt = false
    
    // MARK: - Initializers
    
    init(viewModel: FlashCardViewModel, bubbleManager: BubbleWordManager? = nil, initialMapId: UUID? = nil) {
        self.viewModel = viewModel
        self._bubbleManager = StateObject(wrappedValue: bubbleManager ?? BubbleWordManager.shared)
        
        // If an initial map ID is provided, select it
        if let mapId = initialMapId {
            // Select the map immediately
            self._bubbleManager = StateObject(wrappedValue: {
                let manager = bubbleManager ?? BubbleWordManager.shared
                manager.selectMap(mapId)
                return manager
            }())
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            // Main content
            VStack {
                bubbleArea
                Spacer()
            }
            
            // Floating action button for adding words - positioned in top right
            // VStack {
            //     HStack {
            //         Spacer()
            //         VStack(spacing: 12) {
            //             // Add bubble button (now at top)
            //             Button(action: {
            //                 showingAddTypeSheet = true
            //             }) {
            //                 Image(systemName: "plus")
            //                     .font(.title)
            //                     .fontWeight(.bold)
            //                     .foregroundColor(.white)
            //                     .frame(width: 50, height: 50)
            //                     .background(
            //                         Circle()
            //                             .fill(
            //                                 LinearGradient(
            //                                     colors: [.green, .teal],
            //                                     startPoint: .topLeading,
            //                                     endPoint: .bottomTrailing
            //                                 )
            //                             )
            //                     )
            //                     .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
            //             }
            //             
            //             // Redo button
            //             Button(action: {
            //                 bubbleManager.redo()
            //             }) {
            //                 Image(systemName: "arrow.uturn.forward")
            //                     .font(.title2)
            //                     .fontWeight(.bold)
            //                     .foregroundColor(.white)
            //                     .frame(width: 40, height: 40)
            //                     .background(
            //                         Circle()
            //                             .fill(
            //                                 LinearGradient(
            //                                     colors: [.purple, .blue],
            //                                     startPoint: .topLeading,
            //                                     endPoint: .bottomTrailing
            //                                 )
            //                             )
            //                     )
            //                     .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            //             }
            //             .disabled(!bubbleManager.canRedo())
            //             .opacity(bubbleManager.canRedo() ? 1.0 : 0.5)
            //             
            //             // Undo button (now at bottom)
            //             Button(action: {
            //                 bubbleManager.undo()
            //             }) {
            //                 Image(systemName: "arrow.uturn.backward")
            //                     .font(.title2)
            //                     .fontWeight(.bold)
            //                     .foregroundColor(.white)
            //                     .frame(width: 40, height: 40)
            //                     .background(
            //                         Circle()
            //                             .fill(
            //                                 LinearGradient(
            //                                     colors: [.orange, .red],
            //                                     startPoint: .topLeading,
            //                                     endPoint: .bottomTrailing
            //                                 )
            //                             )
            //                     )
            //                     .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            //             }
            //             .disabled(!bubbleManager.canUndo())
            //             .opacity(bubbleManager.canUndo() ? 1.0 : 0.5)
            //         }
            //         .padding(.trailing, 20)
            //         .padding(.top, 12)
            //     }
            //     Spacer()
            // }
            // .zIndex(1000) // Ensure it's above everything
            
            // Zoom controls - positioned in bottom right
            VStack(spacing: 18) {
                Button(action: { bubbleManager.scale = min(bubbleManager.scale * 1.2, 3.0) }) {
                    Image(systemName: "plus.magnifyingglass")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.blue)
                        .frame(width: 54, height: 54)
                        .background(Circle().fill(Color.white))
                        .shadow(radius: 4, y: 2)
                }
                Button(action: { bubbleManager.scale = max(bubbleManager.scale / 1.2, 0.5) }) {
                    Image(systemName: "minus.magnifyingglass")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.blue)
                        .frame(width: 54, height: 54)
                        .background(Circle().fill(Color.white))
                        .shadow(radius: 4, y: 2)
                }
            }
            .padding(.bottom, 32)
            .padding(.trailing, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .zIndex(999) // Below FAB but above content
        }
        .gesture(backgroundPanGesture) // Attach pan gesture to the whole ZStack
        .navigationBarHidden(true) // Hide default navigation bar
        .onDisappear {
            // Only auto-save if not discarding
            if !showingSavePrompt { bubbleManager.saveData() }
        }
        .overlay(
            VStack(spacing: 0) {
                CustomHeaderView(
                    title: bubbleManager.currentMap?.name ?? "Bubble Word",
                    onBack: {
                        showingSavePrompt = true
                    },
                    trailing: trailingMenu
                )
                actionButtons
                Spacer()
            }
        )
        .confirmationDialog("Do you want to save changes to this map before leaving?", isPresented: $showingSavePrompt, titleVisibility: .visible) {
            Button("Save and Go Back") {
                bubbleManager.saveData()
                navigationCoordinator.pop()
            }
            Button("Discard Changes", role: .destructive) {
                navigationCoordinator.pop()
            }
            Button("Cancel", role: .cancel) { }
        }
        .onChange(of: bubbleManager.selectedNodeId) { newValue in
            handleNodeSelectionChange(oldValue: previousSelectedNodeId, newValue: newValue)
            previousSelectedNodeId = newValue
        }
        .confirmationDialog("Add Bubble", isPresented: $showingAddTypeSheet, titleVisibility: .visible) {
            Button("Add Existing Card") { 
                showingAddExistingCard = true 
            }
            Button("Add Note") { 
                showingAddWord = true 
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showingAddWord) {
            addWordSheet
        }
        .sheet(isPresented: $showingAddExistingCard) {
            NavigationView {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search cards...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    List(filteredCards) { card in
                        Button(action: {
                            addCardAsBubble(card)
                        }) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(card.word)
                                    .font(.headline)
                                if !card.definition.isEmpty {
                                    Text(card.definition)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Add Existing Card")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingAddExistingCard = false }
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditCard) {
            editWordSheet
        }
        .alert("Delete Connection?", isPresented: Binding<Bool>(
            get: { pendingDeleteConnection != nil },
            set: { if !$0 { pendingDeleteConnection = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let conn = pendingDeleteConnection {
                    bubbleManager.disconnectNodes(fromNodeId: conn.fromNodeId, toNodeId: conn.toNodeId)
                }
                pendingDeleteConnection = nil
            }
            Button("Cancel", role: .cancel) {
                pendingDeleteConnection = nil
            }
        } message: {
            Text("Are you sure you want to delete this connection?")
        }
    }
    
    private var bubbleArea: some View {
        ZStack {
            // Connection lines
            ForEach(bubbleManager.connections) { connection in
                if let fromNode = bubbleManager.nodes.first(where: { $0.id == connection.fromNodeId }),
                   let toNode = bubbleManager.nodes.first(where: { $0.id == connection.toNodeId }) {
                    ZStack {
                        // Visible line
                        Path { path in
                            path.move(to: fromNode.position)
                            path.addLine(to: toNode.position)
                        }
                        .stroke(Color.gray.opacity(0.6), lineWidth: 2)
                        // Invisible tappable line
                        Path { path in
                            path.move(to: fromNode.position)
                            path.addLine(to: toNode.position)
                        }
                        .stroke(Color.clear, lineWidth: 24)
                        .contentShape(Rectangle())
                        .onTapGesture(count: 2) {
                            pendingDeleteConnection = connection
                        }
                    }
                }
            }
            // Word bubbles
            wordNodesView
        }
        .scaleEffect(bubbleManager.scale)
        .offset(bubbleManager.offset)
        .simultaneousGesture(pinchGesture)
    }

    private var actionButtons: some View {
        HStack {
            Spacer()
            VStack(spacing: 12) {
                Button(action: {
                    showingAddTypeSheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.green, .teal],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                }
                Button(action: {
                    bubbleManager.redo()
                }) {
                    Image(systemName: "arrow.uturn.forward")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.purple, .blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .disabled(!bubbleManager.canRedo())
                .opacity(bubbleManager.canRedo() ? 1.0 : 0.5)
                Button(action: {
                    bubbleManager.undo()
                }) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .disabled(!bubbleManager.canUndo())
                .opacity(bubbleManager.canUndo() ? 1.0 : 0.5)
            }
            .padding(.trailing, 20)
            .padding(.top, 12)
        }
    }
    
    private var wordNodesView: some View {
        ForEach(bubbleManager.nodes) { node in
            wordBubbleView(for: node)
                .highPriorityGesture(nodeDragGesture(for: node))
        }
    }
    
    private func wordBubbleView(for node: WordNode) -> some View {
        WordBubbleView(
            node: node,
            isSelected: bubbleManager.selectedNodeId == node.id,
            onTap: {
                handleNodeTap(node)
            },
            onDoubleTap: {
                handleNodeDoubleTap(node)
            },
            onDelete: {
                nodeToDelete = node.id
                deleteSelectedNode()
            },
            onFlip: {
                handleNodeFlip(node)
            }
        )
        .position(node.position)
    }
    
    private func nodeDragGesture(for node: WordNode) -> some Gesture {
        DragGesture(minimumDistance: 5)
            .onChanged { value in
                if dragStartPositions[node.id] == nil {
                    dragStartPositions[node.id] = node.position
                }
                let start = dragStartPositions[node.id] ?? node.position
                let newPosition = CGPoint(
                    x: start.x + value.translation.width,
                    y: start.y + value.translation.height
                )
                bubbleManager.updateNodePosition(node.id, to: newPosition)
            }
            .onEnded { _ in
                dragStartPositions[node.id] = nil
            }
    }
    
    private var addWordSheet: some View {
        VStack(spacing: 20) {
            HStack {
                Button("Cancel", action: {
                    showingAddWord = false
                    newWord = ""
                    newNoteColorValue = .blue
                    newDefinition = ""
                })
                    .foregroundColor(.blue)
                Spacer()
                Text("Add New Note")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("Add", action: {
                    addNewWord()
                })
                    .foregroundColor(.blue)
                    .disabled(newWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Word/Note")
                        .font(.headline)
                        .foregroundColor(.primary)
                    TextField("Enter word or note", text: $newWord)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Definition (Optional)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    TextField("Enter definition for flipped side", text: $newDefinition)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .padding(.horizontal)
            
            ColorPicker("Pick a color", selection: $newNoteColorValue, supportsOpacity: false)
                .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: 400)
        .padding(.top, 32)
        .padding(.bottom, 16)
    }
    
    private var editWordSheet: some View {
        VStack(spacing: 20) {
            HStack {
                Button("Cancel", action: {
                    showingEditCard = false
                    selectedNodeForEdit = nil
                })
                    .foregroundColor(.blue)
                Spacer()
                Text("Edit Bubble")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("Save", action: {
                    saveEditedNode()
                })
                    .foregroundColor(.blue)
                    .disabled(editedWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)
            
            TextField("Enter text", text: $editedWord)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            ColorPicker("Pick a color", selection: $editedColorValue, supportsOpacity: false)
                .padding(.horizontal)
            
            // Action buttons for flippable nodes
            if let node = selectedNodeForEdit, node.isFlippable {
                VStack(spacing: 12) {
                    // Flip button
                    Button(action: {
                        if let node = selectedNodeForEdit {
                            bubbleManager.flipNode(node.id)
                        }
                        showingEditCard = false
                        selectedNodeForEdit = nil
                    }) {
                        HStack {
                            Image(systemName: selectedNodeForEdit?.isFlipped == true ? "arrow.clockwise" : "arrow.counterclockwise")
                            Text(selectedNodeForEdit?.isFlipped == true ? "Show Word" : "Show Definition")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    
                    // Delete button
                    Button(action: {
                        if let node = selectedNodeForEdit {
                            bubbleManager.removeNode(node.id)
                        }
                        showingEditCard = false
                        selectedNodeForEdit = nil
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Bubble")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .frame(maxWidth: 400)
        .padding(.top, 32)
        .padding(.bottom, 16)
        .onAppear {
            if let node = selectedNodeForEdit {
                editedWord = node.word
                editedColorValue = Color(hex: node.color) ?? .blue
            }
        }
    }
    
    private func addNewWord() {
        if !newWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let centerPosition = getNextAvailablePosition()
            let colorHex = newNoteColorValue.toHex() ?? "0000ff"
            let definition = newDefinition.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Add the node with definition
            _ = bubbleManager.addNodeWithDefinition(
                word: newWord.trimmingCharacters(in: .whitespacesAndNewlines),
                definition: definition,
                at: centerPosition,
                color: colorHex
            )
            
            newWord = ""
            newNoteColorValue = .blue
            newDefinition = ""
            showingAddWord = false
        }
    }
    
    private func getNextAvailablePosition() -> CGPoint {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let centerX = screenWidth / 2
        let centerY = screenHeight / 2
        
        if bubbleManager.nodes.isEmpty {
            return CGPoint(x: centerX, y: centerY)
        }
        
        // Find a position that doesn't overlap with existing nodes
        let nodeSpacing: CGFloat = 150
        let maxAttempts = 20
        
        for attempt in 0..<maxAttempts {
            let angle = Double(attempt) * (2 * Double.pi / Double(maxAttempts))
            let radius = nodeSpacing * (1 + Double(attempt) / Double(maxAttempts))
            
            let x = centerX + CGFloat(cos(angle)) * radius
            let y = centerY + CGFloat(sin(angle)) * radius
            
            let newPosition = CGPoint(x: x, y: y)
            
            // Check if this position is far enough from existing nodes
            var isPositionAvailable = true
            for node in bubbleManager.nodes {
                let distance = sqrt(pow(node.position.x - newPosition.x, 2) + pow(node.position.y - newPosition.y, 2))
                if distance < nodeSpacing {
                    isPositionAvailable = false
                    break
                }
            }
            
            if isPositionAvailable {
                return newPosition
            }
        }
        
        // If no good position found, use a random position
        let randomX = CGFloat.random(in: 100...(screenWidth - 100))
        let randomY = CGFloat.random(in: 100...(screenHeight - 100))
        return CGPoint(x: randomX, y: randomY)
    }
    
    private func deleteSelectedNode() {
        if let nodeId = nodeToDelete {
            bubbleManager.removeNode(nodeId)
        }
        nodeToDelete = nil
    }
    
    private func handleNodeTap(_ node: WordNode) {
        if bubbleManager.selectedNodeId == node.id {
            bubbleManager.selectedNodeId = nil
        } else {
            bubbleManager.selectedNodeId = node.id
        }
    }
    
    private func handleNodeDoubleTap(_ node: WordNode) {
        selectedNodeForEdit = node
        showingEditCard = true
    }
    
    private func handleNodeSelectionChange(oldValue: UUID?, newValue: UUID?) {
        // Handle connection creation
        if let oldId = oldValue, let newId = newValue, oldId != newId {
            bubbleManager.connectNodes(fromNodeId: oldId, toNodeId: newId)
            bubbleManager.selectedNodeId = nil
        }
    }
    
    private func resetZoom() {
        withAnimation(.easeInOut(duration: 0.5)) {
            bubbleManager.scale = 1.0
            bubbleManager.offset = .zero
            bubbleManager.lastOffset = .zero
        }
    }
    
    // Add these helper gestures:
    private var backgroundPanGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                bubbleManager.offset = CGSize(
                    width: bubbleManager.lastOffset.width + value.translation.width,
                    height: bubbleManager.lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                bubbleManager.lastOffset = bubbleManager.offset
            }
    }
    private var pinchGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                bubbleManager.scale = value
            }
            .onEnded { _ in
                bubbleManager.scale = min(max(bubbleManager.scale, 0.5), 3.0)
            }
    }
    
    // Helper for filtered cards
    private var filteredCards: [FlashCard] {
        viewModel.flashCards.filter { card in
            searchText.isEmpty ||
            card.word.localizedCaseInsensitiveContains(searchText) ||
            card.definition.localizedCaseInsensitiveContains(searchText) ||
            card.example.localizedCaseInsensitiveContains(searchText)
        }
        .sorted { $0.word.localizedCaseInsensitiveCompare($1.word) == .orderedAscending }
    }
    // Add card as bubble
    private func addCardAsBubble(_ card: FlashCard) {
        let centerPosition = getNextAvailablePosition()
        _ = bubbleManager.addCardNode(from: card, at: centerPosition)
        showingAddExistingCard = false
    }
    
    // Save edited node
    private func saveEditedNode() {
        guard let node = selectedNodeForEdit else { return }
        let colorHex = editedColorValue.toHex() ?? "0000ff"
        bubbleManager.updateNode(node.id, word: editedWord, color: colorHex)
        showingEditCard = false
        selectedNodeForEdit = nil
    }
    
    private func handleNodeFlip(_ node: WordNode) {
        bubbleManager.flipNode(node.id)
    }
    
    private var trailingMenu: AnyView {
        AnyView(
            Menu {
                Button(action: { resetZoom() }) {
                    Label("Center Map", systemImage: "scope")
                }
                Divider()
                Button(action: { bubbleManager.setGlobalFlip(!bubbleManager.globalFlipEnabled) }) {
                    Label(
                        bubbleManager.globalFlipEnabled ? "Disable Global Flip" : "Enable Global Flip",
                        systemImage: bubbleManager.globalFlipEnabled ? "eye.slash" : "eye"
                    )
                }
                Button(action: { bubbleManager.flipAllFlippable() }) {
                    Label("Flip All Flippable", systemImage: "arrow.triangle.2.circlepath")
                }
                if bubbleManager.selectedNodeId != nil {
                    Divider()
                    Button(action: {
                        bubbleManager.disconnectAllConnections(fromNodeId: bubbleManager.selectedNodeId!)
                    }) {
                        Label("Disconnect All", systemImage: "link.badge.minus")
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.blue)
            }
        )
    }
}

struct WordBubbleView: View {
    let node: WordNode
    let isSelected: Bool
    let onTap: () -> Void
    let onDoubleTap: () -> Void
    let onDelete: () -> Void
    let onFlip: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // Word bubble
            VStack(spacing: 4) {
                Text(node.displayText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: node.color) ?? node.nodeColor)
                            .shadow(color: isSelected ? (Color(hex: node.color) ?? node.nodeColor).opacity(0.6) : Color.black.opacity(0.2), radius: isSelected ? 8 : 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
                    )
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
                    .onTapGesture {
                        onTap()
                    }
                    .onTapGesture(count: 2) {
                        onDoubleTap()
                    }
                
                // Show article if available and not flipped
                if !node.isFlipped && !node.article.isEmpty {
                    Text(node.article)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(8)
                }
                
                // Show example if available and flipped
                if node.isFlipped && !node.example.isEmpty {
                    Text(node.example)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(8)
                        .lineLimit(2)
                }
            }
        }
    }
} 

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        var r: Double = 0, g: Double = 0, b: Double = 0
        let length = hexSanitized.count
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        if length == 6 {
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
        } else {
            return nil
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
    func toHex() -> String? {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "%06x", rgb)
    }
} 