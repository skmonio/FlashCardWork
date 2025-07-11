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
    @State private var editedDefinition: String = ""
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
    @State private var showingOverlaySelection = false
    
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
        .sheet(isPresented: $showingOverlaySelection) {
            overlaySelectionSheet
        }
        .alert("Duplicate Found", isPresented: $bubbleManager.showingDuplicateDialog) {
            if let firstDuplicate = bubbleManager.duplicateNodes.first {
                Button("Keep Both") {
                    bubbleManager.handleDuplicateChoice(.keepBoth, for: firstDuplicate)
                }
                Button("Merge") {
                    bubbleManager.handleDuplicateChoice(.merge, for: firstDuplicate)
                }
            }
        } message: {
            if let firstDuplicate = bubbleManager.duplicateNodes.first {
                Text("The word '\(firstDuplicate.overlayNode.word)' already exists in the base map. How would you like to handle this?")
            }
        }
    }
    
    private var bubbleArea: some View {
        ZStack {
            // Base map connection lines
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
            
            // Overlay connection lines
            ForEach(bubbleManager.overlayConnections) { connection in
                if let fromNode = bubbleManager.overlayNodes.first(where: { $0.id == connection.fromNodeId }),
                   let toNode = bubbleManager.overlayNodes.first(where: { $0.id == connection.toNodeId }) {
                    Path { path in
                        path.move(to: fromNode.position)
                        path.addLine(to: toNode.position)
                    }
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
            }
            
            // Base map word bubbles
            wordNodesView
            
            // Overlay word bubbles
            overlayWordNodesView
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
    
    private var overlayWordNodesView: some View {
        ForEach(bubbleManager.overlayNodes) { node in
            overlayWordBubbleView(for: node)
                .highPriorityGesture(overlayNodeDragGesture(for: node))
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
    
    private func overlayWordBubbleView(for node: WordNode) -> some View {
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
                // Overlay nodes can't be deleted directly
            },
            onFlip: {
                handleNodeFlip(node)
            }
        )
        .position(node.position)
        .opacity(0.7) // Make overlay nodes semi-transparent
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
                
                print("🔍 DEBUG: Base node drag gesture triggered for '\(node.word)'")
                
                // Check if this node has any actual connections in overlay maps (from merge operations only)
                var hasMergeConnections = false
                print("🔍 DEBUG: Checking for merge connections for base node '\(node.word)' (ID: \(node.id))")
                
                for overlayMapId in bubbleManager.overlayMapIds {
                    if let overlayMap = bubbleManager.maps.first(where: { $0.id == overlayMapId }) {
                        print("🔍 DEBUG: Checking overlay map: \(overlayMapId)")
                        
                        // Check if any overlay node has a connection TO this base node (from merge operations)
                        for connection in overlayMap.connections {
                            if connection.toNodeId == node.id {
                                // Only count it as a merge if the fromNode is an overlay node
                                if overlayMap.nodes.contains(where: { $0.id == connection.fromNodeId }) {
                                    print("🔍 DEBUG: Found merge connection to base node '\(node.word)' from overlay node \(connection.fromNodeId)")
                                    hasMergeConnections = true
                                    break
                                }
                            }
                        }
                        
                        // Also check if any overlay node has this base node in its connections list
                        for overlayNode in overlayMap.nodes {
                            if overlayNode.connections.contains(node.id) {
                                print("🔍 DEBUG: Found merge connection from overlay node '\(overlayNode.word)' to base node '\(node.word)'")
                                print("🔍 DEBUG: Overlay node connections: \(overlayNode.connections)")
                                hasMergeConnections = true
                                break
                            }
                        }
                    }
                    if hasMergeConnections { break }
                }
                
                print("🔍 DEBUG: Base node '\(node.word)' hasMergeConnections: \(hasMergeConnections)")
                
                if hasMergeConnections {
                    // Use updateMergedNodes to move only the specifically merged nodes
                    print("🔗 DEBUG: Moving base node '\(node.word)' with merged nodes")
                    bubbleManager.updateMergedNodes(node.id, to: newPosition)
                } else {
                    // Update just this node (including "Keep Both" nodes which have no connections)
                    print("🔗 DEBUG: Moving base node '\(node.word)' alone")
                    bubbleManager.updateNodePosition(node.id, to: newPosition)
                }
            }
            .onEnded { _ in
                dragStartPositions[node.id] = nil
            }
    }
    
    private func overlayNodeDragGesture(for node: WordNode) -> some Gesture {
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
                
                // Check if this overlay node has actual merge connections (not just "Keep Both" positioning)
                var hasMergeConnections = false
                var connectedBaseNodeId: UUID? = nil
                
                // Look for actual connection records in overlay maps
                for overlayMapId in bubbleManager.overlayMapIds {
                    if let overlayMap = bubbleManager.maps.first(where: { $0.id == overlayMapId }) {
                        // Check if this overlay node has connections to base nodes
                        if let overlayNode = overlayMap.nodes.first(where: { $0.id == node.id }) {
                            print("🔍 DEBUG: Overlay node '\(node.word)' connections: \(overlayNode.connections)")
                            for connectedNodeId in overlayNode.connections {
                                // Only count it as a merge if it connects to a base node
                                if bubbleManager.nodes.contains(where: { $0.id == connectedNodeId }) {
                                    hasMergeConnections = true
                                    connectedBaseNodeId = connectedNodeId
                                    print("🔗 DEBUG: Found merge connection from overlay node \(node.word) to base node \(connectedNodeId)")
                                    break
                                }
                            }
                        }
                        
                        // Also check if any base node connects to this overlay node
                        print("🔍 DEBUG: Overlay map connections: \(overlayMap.connections)")
                        for connection in overlayMap.connections {
                            if connection.toNodeId == node.id {
                                // Only count it as a merge if the fromNode is a base node
                                if bubbleManager.nodes.contains(where: { $0.id == connection.fromNodeId }) {
                                    hasMergeConnections = true
                                    connectedBaseNodeId = connection.fromNodeId
                                    print("🔗 DEBUG: Found merge connection from base node \(connection.fromNodeId) to overlay node \(node.word)")
                                    break
                                }
                            }
                        }
                    }
                    if hasMergeConnections { break }
                }
                
                print("🔍 DEBUG: Node '\(node.word)' hasMergeConnections: \(hasMergeConnections)")
                
                if hasMergeConnections, let baseNodeId = connectedBaseNodeId {
                    // This is a truly merged node - move both together
                    print("🔗 DEBUG: Moving merged node '\(node.word)' with base node \(baseNodeId)")
                    bubbleManager.updateMergedNodes(baseNodeId, to: newPosition)
                } else {
                    // This is a regular overlay node (including "Keep Both" nodes) - move it independently
                    // "Keep Both" nodes should have no connections, so they move alone
                    print("🔗 DEBUG: Moving independent overlay node '\(node.word)' alone")
                    for overlayMapId in bubbleManager.overlayMapIds {
                        if var overlayMap = bubbleManager.maps.first(where: { $0.id == overlayMapId }) {
                            if let nodeIndex = overlayMap.nodes.firstIndex(where: { $0.id == node.id }) {
                                overlayMap.nodes[nodeIndex].position = newPosition
                                if let mapIndex = bubbleManager.maps.firstIndex(where: { $0.id == overlayMapId }) {
                                    bubbleManager.maps[mapIndex] = overlayMap
                                }
                            }
                        }
                    }
                }
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
            
            TextField("Enter word", text: $editedWord)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Text("Definition")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            TextField("Definition", text: $editedDefinition)
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
                editedDefinition = node.definition
                editedColorValue = Color(hex: node.color) ?? .blue
            }
        }
    }
    
    private var overlaySelectionSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "plus.rectangle.on.rectangle")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Manage Map Overlays")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Add or remove map overlays")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Current overlays
                if !bubbleManager.overlayMapIds.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current Overlays")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(bubbleManager.maps.filter { bubbleManager.overlayMapIds.contains($0.id) }) { map in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(map.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text("\(map.nodes.count) nodes")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button(action: {
                                    bubbleManager.removeOverlay(map.id)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title2)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Available maps to add as overlays
                let availableMaps = bubbleManager.maps.filter { map in
                    map.id != bubbleManager.selectedMapId && !bubbleManager.overlayMapIds.contains(map.id)
                }
                
                if !availableMaps.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Available Maps")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(availableMaps) { map in
                            Button(action: {
                                bubbleManager.addOverlay(map.id)
                                // Check for duplicates
                                let duplicates = bubbleManager.checkForDuplicates()
                                if !duplicates.isEmpty {
                                    bubbleManager.duplicateNodes = duplicates
                                    bubbleManager.showingDuplicateDialog = true
                                }
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(map.name)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                        Text("\(map.nodes.count) nodes")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                }
                
                if availableMaps.isEmpty && bubbleManager.overlayMapIds.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("No Maps Available")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Create more maps to use as overlays")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Manage Overlays")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        showingOverlaySelection = false
                    }
                }
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
        // Only use the first line of the definition, trimmed
        var definition = card.definition.trimmingCharacters(in: .whitespacesAndNewlines)
        if let firstLine = definition.components(separatedBy: "\n").first {
            definition = firstLine
        }
        var cardCopy = card
        cardCopy.definition = definition
        _ = bubbleManager.addCardNode(from: cardCopy, at: centerPosition)
        showingAddExistingCard = false
    }
    
    // Save edited node
    private func saveEditedNode() {
        guard let node = selectedNodeForEdit else { return }
        let colorHex = editedColorValue.toHex() ?? "0000ff"
        bubbleManager.updateNodeWithDefinition(node.id, word: editedWord, definition: editedDefinition, color: colorHex)
        showingEditCard = false
        selectedNodeForEdit = nil
    }
    
    private func handleNodeFlip(_ node: WordNode) {
        bubbleManager.flipNode(node.id)
    }
    
    private func autoLayoutNodes() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let centerX = screenWidth / 2
        let centerY = screenHeight / 2
        
        let nodeSpacing: CGFloat = 150
        let maxAttempts = 20
        
        var newPositions: [CGPoint] = []
        
        for attempt in 0..<maxAttempts {
            let angle = Double(attempt) * (2 * Double.pi / Double(maxAttempts))
            let radius = nodeSpacing * (1 + Double(attempt) / Double(maxAttempts))
            
            let x = centerX + CGFloat(cos(angle)) * radius
            let y = centerY + CGFloat(sin(angle)) * radius
            
            let newPosition = CGPoint(x: x, y: y)
            
            // Check if this position is far enough from existing nodes
            var isPositionAvailable = true
            for existingNode in bubbleManager.nodes {
                let distance = sqrt(pow(existingNode.position.x - newPosition.x, 2) + pow(existingNode.position.y - newPosition.y, 2))
                if distance < nodeSpacing {
                    isPositionAvailable = false
                    break
                }
            }
            
            if isPositionAvailable {
                newPositions.append(newPosition)
            }
        }
        
        // If not enough positions found, use random ones
        if newPositions.count < bubbleManager.nodes.count {
            for _ in newPositions.count..<bubbleManager.nodes.count {
                let randomX = CGFloat.random(in: 100...(screenWidth - 100))
                let randomY = CGFloat.random(in: 100...(screenHeight - 100))
                newPositions.append(CGPoint(x: randomX, y: randomY))
            }
        }
        
        for (index, node) in bubbleManager.nodes.enumerated() {
            if index < newPositions.count {
                bubbleManager.updateNodePosition(node.id, to: newPositions[index])
            }
        }
    }
    
    private var trailingMenu: AnyView {
        AnyView(
            Menu {
                Button(action: { resetZoom() }) {
                    Label("Center Map", systemImage: "scope")
                }
                Button(action: { autoLayoutNodes() }) {
                    Label("Auto Layout", systemImage: "rectangle.3.group")
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
                
                if !bubbleManager.overlayMapIds.isEmpty {
                    Divider()
                    Button(action: { bubbleManager.clearAllOverlays() }) {
                        Label("Clear All Overlays", systemImage: "rectangle.slash")
                    }
                }
                
                Divider()
                Button(action: { showingOverlaySelection = true }) {
                    Label("Manage Overlays", systemImage: "rectangle.on.rectangle")
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