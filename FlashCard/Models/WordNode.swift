import Foundation
import SwiftUI

// MARK: - Bubble Word Map Model
struct BubbleWordMap: Identifiable, Codable {
    var id = UUID()
    var name: String
    var dateCreated: Date = Date()
    var lastModified: Date = Date()
    var nodes: [WordNode] = []
    var connections: [WordConnection] = []
    
    init(name: String) {
        self.name = name
        self.dateCreated = Date()
        self.lastModified = Date()
    }
    
    // Coding keys for CGPoint encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id, name, dateCreated, lastModified, nodes, connections
    }
}

struct WordNode: Identifiable, Codable, Hashable {
    var id = UUID()
    var word: String
    var position: CGPoint
    var connections: Set<UUID> = []
    var color: String = "blue"
    var size: CGFloat = 120
    
    // Card data for flipping functionality
    var cardId: UUID? // Reference to original FlashCard if this is a card
    var definition: String = ""
    var example: String = ""
    var article: String = ""
    var isFlipped: Bool = false // Whether to show definition instead of word
    
    // Coding keys for CGPoint encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id, word, positionX, positionY, connections, color, size
        case cardId, definition, example, article, isFlipped
    }
    
    init(word: String, position: CGPoint = CGPoint(x: 0, y: 0), color: String = "blue") {
        self.word = word
        self.position = position
        self.color = color
    }
    
    // Initialize with card data
    init(from card: FlashCard, position: CGPoint = CGPoint(x: 0, y: 0), color: String = "blue") {
        self.word = card.word
        self.position = position
        self.color = color
        self.cardId = card.id
        self.definition = card.definition
        self.example = card.example
        self.article = card.article
    }
    
    // Custom encoding for CGPoint
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(word, forKey: .word)
        try container.encode(position.x, forKey: .positionX)
        try container.encode(position.y, forKey: .positionY)
        try container.encode(connections, forKey: .connections)
        try container.encode(color, forKey: .color)
        try container.encode(size, forKey: .size)
        try container.encode(cardId, forKey: .cardId)
        try container.encode(definition, forKey: .definition)
        try container.encode(example, forKey: .example)
        try container.encode(article, forKey: .article)
        try container.encode(isFlipped, forKey: .isFlipped)
    }
    
    // Custom decoding for CGPoint
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        word = try container.decode(String.self, forKey: .word)
        let x = try container.decode(CGFloat.self, forKey: .positionX)
        let y = try container.decode(CGFloat.self, forKey: .positionY)
        position = CGPoint(x: x, y: y)
        connections = try container.decode(Set<UUID>.self, forKey: .connections)
        color = try container.decode(String.self, forKey: .color)
        size = try container.decode(CGFloat.self, forKey: .size)
        
        // Decode card data with defaults for backward compatibility
        cardId = try container.decodeIfPresent(UUID.self, forKey: .cardId)
        definition = try container.decodeIfPresent(String.self, forKey: .definition) ?? ""
        example = try container.decodeIfPresent(String.self, forKey: .example) ?? ""
        article = try container.decodeIfPresent(String.self, forKey: .article) ?? ""
        isFlipped = try container.decodeIfPresent(Bool.self, forKey: .isFlipped) ?? false
    }
    
    // Computed property to get SwiftUI Color
    var nodeColor: Color {
        return Color(hex: color) ?? .blue
    }
    
    // Computed property to get display text based on flip state
    var displayText: String {
        if isFlipped && !definition.isEmpty {
            return definition
        } else {
            return word
        }
    }
    
    // Check if this node represents a card (has card data)
    var isCard: Bool {
        return cardId != nil && !definition.isEmpty
    }
    
    // Check if this node is flippable (has definition to show when flipped)
    var isFlippable: Bool {
        return !definition.isEmpty
    }
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: WordNode, rhs: WordNode) -> Bool {
        lhs.id == rhs.id
    }
}

struct WordConnection: Identifiable, Codable {
    var id = UUID()
    var fromNodeId: UUID
    var toNodeId: UUID
    
    init(fromNodeId: UUID, toNodeId: UUID) {
        self.fromNodeId = fromNodeId
        self.toNodeId = toNodeId
    }
}

// MARK: - Bubble Word Manager
class BubbleWordManager: ObservableObject {
    // Shared instance for app-wide consistency
    static let shared = BubbleWordManager()
    
    @Published var maps: [BubbleWordMap] = []
    @Published var selectedMapId: UUID?
    @Published var selectedNodeId: UUID?
    @Published var scale: CGFloat = 1.0
    @Published var offset: CGSize = .zero
    @Published var lastOffset: CGSize = .zero
    
    // Global flip setting
    @Published var globalFlipEnabled: Bool = false
    
    // Undo/Redo functionality
    private var undoStack: [BubbleWordMap] = []
    private var redoStack: [BubbleWordMap] = []
    private let maxUndoSteps = 20
    
    private let userDefaults = UserDefaults.standard
    private let mapsKey = "BubbleWordMaps"
    private let selectedMapKey = "BubbleWordSelectedMap"
    private let globalFlipKey = "BubbleWordGlobalFlip"
    
    init() {
        loadData()
        // If no maps exist, create a default one
        if maps.isEmpty {
            createDefaultMap()
        }
        // Select the first map if none is selected
        if selectedMapId == nil && !maps.isEmpty {
            selectedMapId = maps.first?.id
        }
    }
    
    // MARK: - Map Management
    
    func createMap(name: String) -> BubbleWordMap {
        print("🗺️ BubbleWordManager: Creating new map: '\(name)'")
        let newMap = BubbleWordMap(name: name)
        maps.append(newMap)
        selectedMapId = newMap.id
        print("✅ BubbleWordManager: Map created with ID: \(newMap.id)")
        saveData()
        return newMap
    }
    
    func deleteMap(_ mapId: UUID) {
        maps.removeAll { $0.id == mapId }
        if selectedMapId == mapId {
            selectedMapId = maps.first?.id
        }
        saveData()
    }
    
    func selectMap(_ mapId: UUID) {
        selectedMapId = mapId
        // Reset view state when switching maps
        scale = 1.0
        offset = .zero
        lastOffset = .zero
        selectedNodeId = nil
        saveData()
    }
    
    private func createDefaultMap() {
        let defaultMap = BubbleWordMap(name: "My First Map")
        maps.append(defaultMap)
        selectedMapId = defaultMap.id
        saveData()
    }
    
    // MARK: - Current Map Computed Properties
    
    var currentMap: BubbleWordMap? {
        guard let selectedId = selectedMapId else { return nil }
        return maps.first { $0.id == selectedId }
    }
    
    var nodes: [WordNode] {
        return currentMap?.nodes ?? []
    }
    
    var connections: [WordConnection] {
        return currentMap?.connections ?? []
    }
    
    // MARK: - Node Management
    
    func addNode(word: String, at position: CGPoint, color: String = "blue") -> WordNode {
        guard var currentMap = currentMap else { 
            let newNode = WordNode(word: word, position: position, color: color)
            return newNode
        }
        
        saveStateForUndo()
        
        let newNode = WordNode(word: word, position: position, color: color)
        currentMap.nodes.append(newNode)
        currentMap.lastModified = Date()
        
        // Update the map in the array
        if let index = maps.firstIndex(where: { $0.id == currentMap.id }) {
            maps[index] = currentMap
        }
        
        saveData()
        return newNode
    }
    
    // Add node with definition
    func addNodeWithDefinition(word: String, definition: String, at position: CGPoint, color: String = "blue") -> WordNode {
        guard var currentMap = currentMap else { 
            let newNode = WordNode(word: word, position: position, color: color)
            var nodeWithDefinition = newNode
            nodeWithDefinition.definition = definition
            // Apply global flip setting if enabled
            if globalFlipEnabled {
                nodeWithDefinition.isFlipped = true
            }
            return nodeWithDefinition
        }
        
        saveStateForUndo()
        
        var newNode = WordNode(word: word, position: position, color: color)
        newNode.definition = definition
        // Apply global flip setting if enabled
        if globalFlipEnabled {
            newNode.isFlipped = true
        }
        currentMap.nodes.append(newNode)
        currentMap.lastModified = Date()
        
        // Update the map in the array
        if let index = maps.firstIndex(where: { $0.id == currentMap.id }) {
            maps[index] = currentMap
        }
        
        saveData()
        return newNode
    }
    
    // Add node from FlashCard
    func addCardNode(from card: FlashCard, at position: CGPoint, color: String = "blue") -> WordNode {
        guard var currentMap = currentMap else { 
            let newNode = WordNode(from: card, position: position, color: color)
            return newNode
        }
        
        saveStateForUndo()
        
        var newNode = WordNode(from: card, position: position, color: color)
        // Apply global flip setting if enabled
        if globalFlipEnabled {
            newNode.isFlipped = true
        }
        currentMap.nodes.append(newNode)
        currentMap.lastModified = Date()
        
        // Update the map in the array
        if let index = maps.firstIndex(where: { $0.id == currentMap.id }) {
            maps[index] = currentMap
        }
        
        saveData()
        return newNode
    }
    
    func updateNodePosition(_ nodeId: UUID, to position: CGPoint) {
        guard var currentMap = currentMap else { return }
        
        saveStateForUndo()
        
        if let nodeIndex = currentMap.nodes.firstIndex(where: { $0.id == nodeId }) {
            currentMap.nodes[nodeIndex].position = position
            currentMap.lastModified = Date()
            
            // Update the map in the array
            if let mapIndex = maps.firstIndex(where: { $0.id == currentMap.id }) {
                maps[mapIndex] = currentMap
            }
            
            saveData()
        }
    }
    
    func updateNode(_ nodeId: UUID, word: String, color: String) {
        guard var currentMap = currentMap else { return }
        
        saveStateForUndo()
        
        if let nodeIndex = currentMap.nodes.firstIndex(where: { $0.id == nodeId }) {
            currentMap.nodes[nodeIndex].word = word
            currentMap.nodes[nodeIndex].color = color
            currentMap.lastModified = Date()
            
            // Update the map in the array
            if let mapIndex = maps.firstIndex(where: { $0.id == currentMap.id }) {
                maps[mapIndex] = currentMap
            }
            
            saveData()
        }
    }
    
    func removeNode(_ nodeId: UUID) {
        guard var currentMap = currentMap else { return }
        
        saveStateForUndo()
        
        // Remove the node
        currentMap.nodes.removeAll { $0.id == nodeId }
        
        // Remove connections involving this node
        currentMap.connections.removeAll { 
            $0.fromNodeId == nodeId || $0.toNodeId == nodeId 
        }
        
        // Remove this node from other nodes' connections
        for i in 0..<currentMap.nodes.count {
            currentMap.nodes[i].connections.remove(nodeId)
        }
        
        currentMap.lastModified = Date()
        
        // Update the map in the array
        if let mapIndex = maps.firstIndex(where: { $0.id == currentMap.id }) {
            maps[mapIndex] = currentMap
        }
        
        saveData()
    }
    
    // MARK: - Card Flipping Functionality
    
    func flipNode(_ nodeId: UUID) {
        guard var currentMap = currentMap else { return }
        
        saveStateForUndo()
        
        if let nodeIndex = currentMap.nodes.firstIndex(where: { $0.id == nodeId }) {
            currentMap.nodes[nodeIndex].isFlipped.toggle()
            currentMap.lastModified = Date()
            
            // Update the map in the array
            if let mapIndex = maps.firstIndex(where: { $0.id == currentMap.id }) {
                maps[mapIndex] = currentMap
            }
            
            saveData()
        }
    }
    
    func flipAllFlippable() {
        guard var currentMap = currentMap else { return }
        
        saveStateForUndo()
        
        for i in 0..<currentMap.nodes.count {
            if currentMap.nodes[i].isFlippable {
                currentMap.nodes[i].isFlipped.toggle()
            }
        }
        
        currentMap.lastModified = Date()
        
        // Update the map in the array
        if let mapIndex = maps.firstIndex(where: { $0.id == currentMap.id }) {
            maps[mapIndex] = currentMap
        }
        
        saveData()
    }
    
    func setGlobalFlip(_ enabled: Bool) {
        globalFlipEnabled = enabled
        saveData()
    }
    
    // MARK: - Connection Management
    
    func connectNodes(fromNodeId: UUID, toNodeId: UUID) {
        guard var currentMap = currentMap else { return }
        
        // Check if connection already exists
        let existingConnection = currentMap.connections.first { connection in
            (connection.fromNodeId == fromNodeId && connection.toNodeId == toNodeId) ||
            (connection.fromNodeId == toNodeId && connection.toNodeId == fromNodeId)
        }
        
        guard existingConnection == nil else { return }
        
        saveStateForUndo()
        
        let connection = WordConnection(fromNodeId: fromNodeId, toNodeId: toNodeId)
        currentMap.connections.append(connection)
        
        // Update node connections
        if let fromIndex = currentMap.nodes.firstIndex(where: { $0.id == fromNodeId }) {
            currentMap.nodes[fromIndex].connections.insert(toNodeId)
        }
        if let toIndex = currentMap.nodes.firstIndex(where: { $0.id == toNodeId }) {
            currentMap.nodes[toIndex].connections.insert(fromNodeId)
        }
        
        currentMap.lastModified = Date()
        
        // Update the map in the array
        if let mapIndex = maps.firstIndex(where: { $0.id == currentMap.id }) {
            maps[mapIndex] = currentMap
        }
        
        saveData()
    }
    
    func disconnectNodes(fromNodeId: UUID, toNodeId: UUID) {
        guard var currentMap = currentMap else { return }
        
        saveStateForUndo()
        
        // Remove the connection
        currentMap.connections.removeAll { connection in
            (connection.fromNodeId == fromNodeId && connection.toNodeId == toNodeId) ||
            (connection.fromNodeId == toNodeId && connection.toNodeId == fromNodeId)
        }
        
        // Remove from node connections
        if let fromIndex = currentMap.nodes.firstIndex(where: { $0.id == fromNodeId }) {
            currentMap.nodes[fromIndex].connections.remove(toNodeId)
        }
        if let toIndex = currentMap.nodes.firstIndex(where: { $0.id == toNodeId }) {
            currentMap.nodes[toIndex].connections.remove(fromNodeId)
        }
        
        currentMap.lastModified = Date()
        
        // Update the map in the array
        if let mapIndex = maps.firstIndex(where: { $0.id == currentMap.id }) {
            maps[mapIndex] = currentMap
        }
        
        saveData()
    }
    
    func disconnectAllConnections(fromNodeId: UUID) {
        guard var currentMap = currentMap else { return }
        
        saveStateForUndo()
        
        // Remove all connections involving this node
        currentMap.connections.removeAll { connection in
            connection.fromNodeId == fromNodeId || connection.toNodeId == fromNodeId
        }
        
        // Remove this node from all other nodes' connections
        for i in 0..<currentMap.nodes.count {
            currentMap.nodes[i].connections.remove(fromNodeId)
        }
        
        // Clear this node's connections
        if let nodeIndex = currentMap.nodes.firstIndex(where: { $0.id == fromNodeId }) {
            currentMap.nodes[nodeIndex].connections.removeAll()
        }
        
        currentMap.lastModified = Date()
        
        // Update the map in the array
        if let mapIndex = maps.firstIndex(where: { $0.id == currentMap.id }) {
            maps[mapIndex] = currentMap
        }
        
        saveData()
    }
    
    // MARK: - Helper Methods
    
    func getConnectedNodes(for nodeId: UUID) -> [WordNode] {
        guard let node = nodes.first(where: { $0.id == nodeId }) else { return [] }
        return nodes.filter { node.connections.contains($0.id) }
    }
    
    func getConnectionPath(from: WordNode, to: WordNode) -> Path {
        var path = Path()
        path.move(to: from.position)
        path.addLine(to: to.position)
        return path
    }
    
    func resetData() {
        guard var currentMap = currentMap else { return }
        
        currentMap.nodes.removeAll()
        currentMap.connections.removeAll()
        currentMap.lastModified = Date()
        
        // Update the map in the array
        if let mapIndex = maps.firstIndex(where: { $0.id == currentMap.id }) {
            maps[mapIndex] = currentMap
        }
        
        selectedNodeId = nil
        saveData()
    }
    
    // MARK: - Data Persistence
    
    func saveData() {
        print("💾 BubbleWordManager: Saving \(maps.count) maps")
        if let mapsData = try? JSONEncoder().encode(maps) {
            userDefaults.set(mapsData, forKey: mapsKey)
            print("✅ BubbleWordManager: Maps saved successfully")
        } else {
            print("❌ BubbleWordManager: Failed to encode maps")
        }
        if let selectedId = selectedMapId {
            userDefaults.set(selectedId.uuidString, forKey: selectedMapKey)
            print("✅ BubbleWordManager: Selected map ID saved: \(selectedId)")
        }
        userDefaults.set(globalFlipEnabled, forKey: globalFlipKey)
        print("💾 BubbleWordManager: Save complete")
    }
    
    // MARK: - Undo/Redo Functionality
    
    func canUndo() -> Bool {
        return !undoStack.isEmpty
    }
    
    func canRedo() -> Bool {
        return !redoStack.isEmpty
    }
    
    func undo() {
        guard let currentMap = currentMap, !undoStack.isEmpty else { return }
        
        // Save current state to redo stack
        redoStack.append(currentMap)
        if redoStack.count > maxUndoSteps {
            redoStack.removeFirst()
        }
        
        // Restore previous state
        let previousState = undoStack.removeLast()
        if let mapIndex = maps.firstIndex(where: { $0.id == currentMap.id }) {
            maps[mapIndex] = previousState
        }
        
        // Clear redo stack if we're not at the end
        redoStack.removeAll()
        
        saveData()
    }
    
    func redo() {
        guard let currentMap = currentMap, !redoStack.isEmpty else { return }
        
        // Save current state to undo stack
        undoStack.append(currentMap)
        if undoStack.count > maxUndoSteps {
            undoStack.removeFirst()
        }
        
        // Restore next state
        let nextState = redoStack.removeLast()
        if let mapIndex = maps.firstIndex(where: { $0.id == currentMap.id }) {
            maps[mapIndex] = nextState
        }
        
        saveData()
    }
    
    private func saveStateForUndo() {
        guard let currentMap = currentMap else { return }
        
        // Save current state to undo stack
        undoStack.append(currentMap)
        if undoStack.count > maxUndoSteps {
            undoStack.removeFirst()
        }
        
        // Clear redo stack when new action is performed
        redoStack.removeAll()
    }
    
    private func loadData() {
        print("📂 BubbleWordManager: Loading data...")
        if let mapsData = userDefaults.data(forKey: mapsKey),
           let loadedMaps = try? JSONDecoder().decode([BubbleWordMap].self, from: mapsData) {
            maps = loadedMaps
            print("✅ BubbleWordManager: Loaded \(maps.count) maps")
        } else {
            print("❌ BubbleWordManager: No maps found or failed to decode")
        }
        
        if let selectedIdString = userDefaults.string(forKey: selectedMapKey),
           let selectedId = UUID(uuidString: selectedIdString) {
            selectedMapId = selectedId
            print("✅ BubbleWordManager: Selected map ID loaded: \(selectedId)")
        } else {
            print("❌ BubbleWordManager: No selected map ID found")
        }
        
        globalFlipEnabled = userDefaults.bool(forKey: globalFlipKey)
        print("📂 BubbleWordManager: Load complete")
    }
} 