import SwiftUI

struct BubbleWordView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @StateObject private var bubbleManager = BubbleWordManager()
    @State private var newWord = ""
    @State private var newNoteColorValue: Color = .blue
    @State private var showingAddWord = false
    @State private var showingAddTypeSheet = false // For action sheet
    @State private var showingAddExistingCard = false // For card picker
    @State private var searchText = ""
    @State private var showingResetAlert = false
    @State private var showingDisconnectAlert = false
    @State private var selectedConnection: WordConnection? = nil
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
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            // Main content
            VStack {
                // Bubble word area (no toolbarView)
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
                .gesture(backgroundPanGesture)
                .simultaneousGesture(pinchGesture)
                
                Spacer()
            }
            // Floating action buttons - Top right
            VStack(spacing: 18) {
                Button(action: { showingAddTypeSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 54, height: 54)
                        .background(Circle().fill(Color.blue))
                        .shadow(radius: 4, y: 2)
                }
                Button(action: { showingResetAlert = true }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 54, height: 54)
                        .background(Circle().fill(Color.orange))
                        .shadow(radius: 4, y: 2)
                }
                if bubbleManager.selectedNodeId != nil {
                    Button(action: {
                        if let nodeId = bubbleManager.selectedNodeId {
                            nodeToDelete = nodeId
                            deleteSelectedNode()
                        }
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 54, height: 54)
                            .background(Circle().fill(Color.red))
                            .shadow(radius: 4, y: 2)
                    }
                }
            }
            .padding(.top, 32)
            .padding(.trailing, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            // Floating zoom buttons - Bottom right
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
        }
        .navigationTitle("Bubble Word")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: bubbleManager.selectedNodeId) { newValue in
            handleNodeSelectionChange(oldValue: previousSelectedNodeId, newValue: newValue)
            previousSelectedNodeId = newValue
        }
        .actionSheet(isPresented: $showingAddTypeSheet) {
            ActionSheet(title: Text("Add Bubble"), buttons: [
                .default(Text("Add Existing Card")) { showingAddExistingCard = true },
                .default(Text("Add Note")) { showingAddWord = true },
                .cancel()
            ])
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
        .alert("Reset Bubble Word", isPresented: $showingResetAlert) {
            Button("Reset", role: .destructive) {
                bubbleManager.resetData()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will delete all words and connections. This action cannot be undone.")
        }
        .alert("Disconnect Nodes", isPresented: $showingDisconnectAlert) {
            Button("Disconnect", role: .destructive) {
                disconnectSelectedConnection()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to disconnect these nodes?")
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
        NoteEditSheet(
            title: "Add New Note",
            word: $newWord,
            colorValue: $newNoteColorValue,
            onCancel: {
                showingAddWord = false
                newWord = ""
                newNoteColorValue = .blue
            },
            onSave: {
                addNewWord()
            }
        )
    }
    
    private var editWordSheet: some View {
        NoteEditSheet(
            title: "Edit Note",
            word: $editedWord,
            colorValue: $editedColorValue,
            onCancel: {
                showingEditCard = false
                selectedNodeForEdit = nil
            },
            onSave: {
                saveEditedNode()
            }
        )
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
            bubbleManager.addNode(word: newWord.trimmingCharacters(in: .whitespacesAndNewlines), at: centerPosition, color: colorHex)
            newWord = ""
            newNoteColorValue = .blue
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
    
    private func showDisconnectOptions() {
        if let selectedId = bubbleManager.selectedNodeId {
            let connections = bubbleManager.connections.filter { 
                $0.fromNodeId == selectedId || $0.toNodeId == selectedId 
            }
            if let firstConnection = connections.first {
                selectedConnection = firstConnection
                showingDisconnectAlert = true
            }
        }
    }
    
    private func disconnectSelectedConnection() {
        if let connection = selectedConnection {
            bubbleManager.disconnectNodes(fromNodeId: connection.fromNodeId, toNodeId: connection.toNodeId)
            selectedConnection = nil
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
        bubbleManager.addNode(word: card.word, at: centerPosition)
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
}

struct WordBubbleView: View {
    let node: WordNode
    let isSelected: Bool
    let onTap: () -> Void
    let onDoubleTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // Word bubble
            Text(node.word)
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
            
            // Delete button (only show when selected)
            if isSelected {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
} 

struct NoteEditSheet: View {
    let title: String
    @Binding var word: String
    @Binding var colorValue: Color
    let onCancel: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button("Cancel", action: onCancel)
                    .foregroundColor(.blue)
                Spacer()
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("Save", action: onSave)
                    .foregroundColor(.blue)
                    .disabled(word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)
            TextField("Enter note", text: $word)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            ColorPicker("Pick a color", selection: $colorValue, supportsOpacity: false)
                .padding(.horizontal)
            Spacer()
        }
        .frame(maxWidth: 400)
        .padding(.top, 32)
        .padding(.bottom, 16)
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