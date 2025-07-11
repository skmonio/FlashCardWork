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
    
    // Overlay functionality
    @Published var overlayMapIds: Set<UUID> = []
    @Published var showingDuplicateDialog: Bool = false
    @Published var duplicateNodes: [(overlayNode: WordNode, baseNode: WordNode)] = []
    
    // Undo/Redo functionality
    private var undoStack: [BubbleWordMap] = []
    private var redoStack: [BubbleWordMap] = []
    private let maxUndoSteps = 20
    
    private let userDefaults = UserDefaults.standard
    private let mapsKey = "BubbleWordMaps"
    private let selectedMapKey = "BubbleWordSelectedMap"
    private let globalFlipKey = "BubbleWordGlobalFlip"
    private let overlayMapIdsKey = "BubbleWordOverlayMapIds"
    
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
        // Clear all overlays when switching maps for a clean start
        overlayMapIds.removeAll()
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
    
    // MARK: - Overlay Computed Properties
    
    var overlayNodes: [WordNode] {
        var allOverlayNodes: [WordNode] = []
        for overlayMapId in overlayMapIds {
            if let overlayMap = maps.first(where: { $0.id == overlayMapId }) {
                allOverlayNodes.append(contentsOf: overlayMap.nodes)
            }
        }
        return allOverlayNodes
    }
    
    var overlayConnections: [WordConnection] {
        var allOverlayConnections: [WordConnection] = []
        for overlayMapId in overlayMapIds {
            if let overlayMap = maps.first(where: { $0.id == overlayMapId }) {
                allOverlayConnections.append(contentsOf: overlayMap.connections)
            }
        }
        return allOverlayConnections
    }
    
    var allNodes: [WordNode] {
        return nodes + overlayNodes
    }
    
    var allConnections: [WordConnection] {
        return connections + overlayConnections
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
    
    // MARK: - Overlay Management
    
    func addOverlay(_ mapId: UUID) {
        guard mapId != selectedMapId else { return }
        overlayMapIds.insert(mapId)
        saveData()
    }
    
    func removeOverlay(_ mapId: UUID) {
        overlayMapIds.remove(mapId)
        saveData()
    }
    
    func clearAllOverlays() {
        overlayMapIds.removeAll()
        saveData()
    }
    
    func toggleOverlay(_ mapId: UUID) {
        if overlayMapIds.contains(mapId) {
            removeOverlay(mapId)
        } else {
            addOverlay(mapId)
        }
    }
    
    func checkForDuplicates() -> [(overlayNode: WordNode, baseNode: WordNode)] {
        var duplicates: [(overlayNode: WordNode, baseNode: WordNode)] = []
        
        for overlayNode in overlayNodes {
            if let baseNode = nodes.first(where: { $0.word.lowercased() == overlayNode.word.lowercased() }) {
                duplicates.append((overlayNode: overlayNode, baseNode: baseNode))
            }
        }
        
        return duplicates
    }
    
    enum DuplicateChoice {
        case merge
        case keepBoth
        case cancel
    }
    
    func handleDuplicateChoice(_ choice: DuplicateChoice, for duplicate: (overlayNode: WordNode, baseNode: WordNode)) {
        switch choice {
        case .merge:
            // Merge definitions and connect only the specific matching nodes
            if let baseNodeIndex = currentMap?.nodes.firstIndex(where: { $0.id == duplicate.baseNode.id }) {
                var updatedMap = currentMap!
                let baseDefinition = updatedMap.nodes[baseNodeIndex].definition
                let overlayDefinition = duplicate.overlayNode.definition
                
                // Only append the overlay definition if it's not already present
                if !baseDefinition.contains(overlayDefinition) && !overlayDefinition.isEmpty {
                    updatedMap.nodes[baseNodeIndex].definition += "\n" + overlayDefinition
                }
                
                // Don't add permanent connections to the base map
                // Only add connections to overlay maps for temporary linking
                
                // Update the base map
                if let mapIndex = maps.firstIndex(where: { $0.id == updatedMap.id }) {
                    maps[mapIndex] = updatedMap
                }
            }
            
            // Add the base node connection to the overlay node in its original map
            for overlayMapId in overlayMapIds {
                if var overlayMap = maps.first(where: { $0.id == overlayMapId }) {
                    if let overlayNodeIndex = overlayMap.nodes.firstIndex(where: { $0.id == duplicate.overlayNode.id }) {
                        // Only connect this specific overlay node to the base node
                        overlayMap.nodes[overlayNodeIndex].connections.insert(duplicate.baseNode.id)
                        
                        // Add the reverse connection in the overlay map
                        let reverseConnection = WordConnection(fromNodeId: duplicate.overlayNode.id, toNodeId: duplicate.baseNode.id)
                        overlayMap.connections.append(reverseConnection)
                        
                        if let mapIndex = maps.firstIndex(where: { $0.id == overlayMapId }) {
                            maps[mapIndex] = overlayMap
                        }
                    }
                }
            }
            break
            
        case .keepBoth:
            // Keep both nodes separate (no connection, both can exist independently)
            // Offset the overlay node's position relative to the base node so both nodes are visible
            print("🔍 DEBUG: Starting .keepBoth for word: \(duplicate.overlayNode.word)")
            print("🔍 DEBUG: Base node ID: \(duplicate.baseNode.id)")
            print("🔍 DEBUG: Overlay node ID: \(duplicate.overlayNode.id)")
            
            for overlayMapId in overlayMapIds {
                if var overlayMap = maps.first(where: { $0.id == overlayMapId }) {
                    if let overlayNodeIndex = overlayMap.nodes.firstIndex(where: { $0.id == duplicate.overlayNode.id }) {
                        // Offset the overlay node position relative to the base node (50 points to the right and down)
                        let offsetPosition = CGPoint(
                            x: duplicate.baseNode.position.x + 50,
                            y: duplicate.baseNode.position.y + 50
                        )
                        overlayMap.nodes[overlayNodeIndex].position = offsetPosition
                        
                        // Ensure NO connections are created for "Keep Both"
                        overlayMap.nodes[overlayNodeIndex].connections.remove(duplicate.baseNode.id)
                        
                        // Remove any connection records that might connect these nodes
                        overlayMap.connections.removeAll { connection in
                            (connection.fromNodeId == duplicate.overlayNode.id && connection.toNodeId == duplicate.baseNode.id) ||
                            (connection.fromNodeId == duplicate.baseNode.id && connection.toNodeId == duplicate.overlayNode.id)
                        }
                        
                        print("🔍 DEBUG: Removed any connections between overlay node and base node")
                        print("🔍 DEBUG: Overlay node connections after cleanup: \(overlayMap.nodes[overlayNodeIndex].connections)")
                        print("🔍 DEBUG: Overlay map connections after cleanup: \(overlayMap.connections.count)")
                        
                        if let mapIndex = maps.firstIndex(where: { $0.id == overlayMapId }) {
                            maps[mapIndex] = overlayMap
                        }
                    }
                }
            }
            print("✅ DEBUG: Completed .keepBoth for word: \(duplicate.overlayNode.word)")
            
        case .cancel:
            // Remove the overlay entirely - don't add it at all
            // Find which overlay map contains this duplicate node and remove it
            for overlayMapId in overlayMapIds {
                if let overlayMap = maps.first(where: { $0.id == overlayMapId }) {
                    if overlayMap.nodes.contains(where: { $0.id == duplicate.overlayNode.id }) {
                        // Remove this overlay map entirely
                        removeOverlay(overlayMapId)
                        break
                    }
                }
            }
        }
        
        // Remove this duplicate from the list
        duplicateNodes.removeAll { $0.overlayNode.id == duplicate.overlayNode.id }
        
        // Check for more duplicates
        if duplicateNodes.isEmpty {
            showingDuplicateDialog = false
        }
        
        saveData()
    }
    
    func handleAllDuplicates(_ choice: DuplicateChoice) {
        print("🔄 DEBUG: Handling all \(duplicateNodes.count) duplicates with choice: \(choice)")
        
        // Create a copy of all duplicates to process
        let allDuplicates = duplicateNodes
        
        // Process each duplicate with the same choice
        for duplicate in allDuplicates {
            switch choice {
            case .merge:
                // Merge definitions and connect only the specific matching nodes
                if let baseNodeIndex = currentMap?.nodes.firstIndex(where: { $0.id == duplicate.baseNode.id }) {
                    var updatedMap = currentMap!
                    let baseDefinition = updatedMap.nodes[baseNodeIndex].definition
                    let overlayDefinition = duplicate.overlayNode.definition
                    
                    // Only append the overlay definition if it's not already present
                    if !baseDefinition.contains(overlayDefinition) && !overlayDefinition.isEmpty {
                        updatedMap.nodes[baseNodeIndex].definition += "\n" + overlayDefinition
                    }
                    
                    // Update the base map
                    if let mapIndex = maps.firstIndex(where: { $0.id == updatedMap.id }) {
                        maps[mapIndex] = updatedMap
                    }
                }
                
                // Add the base node connection to the overlay node in its original map
                for overlayMapId in overlayMapIds {
                    if var overlayMap = maps.first(where: { $0.id == overlayMapId }) {
                        if let overlayNodeIndex = overlayMap.nodes.firstIndex(where: { $0.id == duplicate.overlayNode.id }) {
                            // Only connect this specific overlay node to the base node
                            overlayMap.nodes[overlayNodeIndex].connections.insert(duplicate.baseNode.id)
                            
                            // Add the reverse connection in the overlay map
                            let reverseConnection = WordConnection(fromNodeId: duplicate.overlayNode.id, toNodeId: duplicate.baseNode.id)
                            overlayMap.connections.append(reverseConnection)
                            
                            if let mapIndex = maps.firstIndex(where: { $0.id == overlayMapId }) {
                                maps[mapIndex] = overlayMap
                            }
                        }
                    }
                }
                
            case .keepBoth:
                // Keep both nodes separate (no connection, both can exist independently)
                // Offset the overlay node's position relative to the base node so both nodes are visible
                for overlayMapId in overlayMapIds {
                    if var overlayMap = maps.first(where: { $0.id == overlayMapId }) {
                        if let overlayNodeIndex = overlayMap.nodes.firstIndex(where: { $0.id == duplicate.overlayNode.id }) {
                            // Offset the overlay node position relative to the base node (50 points to the right and down)
                            let offsetPosition = CGPoint(
                                x: duplicate.baseNode.position.x + 50,
                                y: duplicate.baseNode.position.y + 50
                            )
                            overlayMap.nodes[overlayNodeIndex].position = offsetPosition
                            
                            // Ensure NO connections are created for "Keep Both"
                            overlayMap.nodes[overlayNodeIndex].connections.remove(duplicate.baseNode.id)
                            
                            // Remove any connection records that might connect these nodes
                            overlayMap.connections.removeAll { connection in
                                (connection.fromNodeId == duplicate.overlayNode.id && connection.toNodeId == duplicate.baseNode.id) ||
                                (connection.fromNodeId == duplicate.baseNode.id && connection.toNodeId == duplicate.overlayNode.id)
                            }
                            
                            if let mapIndex = maps.firstIndex(where: { $0.id == overlayMapId }) {
                                maps[mapIndex] = overlayMap
                            }
                        }
                    }
                }
                
            case .cancel:
                // This shouldn't happen with handleAllDuplicates, but handle it just in case
                break
            }
        }
        
        // Clear all duplicates and close the dialog
        duplicateNodes.removeAll()
        showingDuplicateDialog = false
        
        print("✅ DEBUG: Completed handling all duplicates")
        saveData()
    }
    
    func updateMergedNodes(_ nodeId: UUID, to position: CGPoint) {
        // Update base map node
        updateNodePosition(nodeId, to: position)
        
        // Find only the nodes that were specifically merged with this node
        var mergedNodeIds: Set<UUID> = []
        
        // Check for connections from this specific node in overlay maps
        for overlayMapId in overlayMapIds {
            if let overlayMap = maps.first(where: { $0.id == overlayMapId }) {
                if let overlayNode = overlayMap.nodes.first(where: { $0.id == nodeId }) {
                    mergedNodeIds.formUnion(overlayNode.connections)
                }
                
                // Check for connections to this specific node in overlay maps
                for connection in overlayMap.connections {
                    if connection.toNodeId == nodeId {
                        mergedNodeIds.insert(connection.fromNodeId)
                    }
                }
            }
        }
        
        // Update only the merged nodes in overlays (don't update base map nodes)
        for mergedNodeId in mergedNodeIds {
            for overlayMapId in overlayMapIds {
                if var overlayMap = maps.first(where: { $0.id == overlayMapId }) {
                    if let nodeIndex = overlayMap.nodes.firstIndex(where: { $0.id == mergedNodeId }) {
                        overlayMap.nodes[nodeIndex].position = position
                        if let mapIndex = maps.firstIndex(where: { $0.id == overlayMapId }) {
                            maps[mapIndex] = overlayMap
                        }
                    }
                }
            }
        }
        
        // Don't update base map nodes - they should stay in their original positions
        // This prevents nodes from getting stuck on top of each other when overlays are removed
    }
    
    func updateConnectedNodes(_ nodeId: UUID, to position: CGPoint) {
        // Update base map node
        updateNodePosition(nodeId, to: position)
        
        // Find only the specifically connected nodes (the ones that were merged)
        var connectedNodeIds: Set<UUID> = []
        
        // Check for connections from this specific node only
        if let baseNode = nodes.first(where: { $0.id == nodeId }) {
            connectedNodeIds.formUnion(baseNode.connections)
        }
        
        // Check for connections to this specific node only
        for connection in connections {
            if connection.toNodeId == nodeId {
                connectedNodeIds.insert(connection.fromNodeId)
            }
        }
        
        // Update only the specifically connected nodes in overlays
        for connectedNodeId in connectedNodeIds {
            for overlayMapId in overlayMapIds {
                if var overlayMap = maps.first(where: { $0.id == overlayMapId }) {
                    if let nodeIndex = overlayMap.nodes.firstIndex(where: { $0.id == connectedNodeId }) {
                        overlayMap.nodes[nodeIndex].position = position
                        if let mapIndex = maps.firstIndex(where: { $0.id == overlayMapId }) {
                            maps[mapIndex] = overlayMap
                        }
                    }
                }
            }
        }
        
        // Also update only the specifically connected nodes in the base map
        for connectedNodeId in connectedNodeIds {
            if let nodeIndex = currentMap?.nodes.firstIndex(where: { $0.id == connectedNodeId }) {
                if var currentMap = currentMap {
                    currentMap.nodes[nodeIndex].position = position
                    if let mapIndex = maps.firstIndex(where: { $0.id == currentMap.id }) {
                        maps[mapIndex] = currentMap
                    }
                }
            }
        }
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
            
            // Find only the specifically connected nodes (the ones that were merged)
            var connectedNodeIds: Set<UUID> = []
            
            // Check for connections from this specific node only
            if let baseNode = currentMap.nodes.first(where: { $0.id == nodeId }) {
                connectedNodeIds.formUnion(baseNode.connections)
            }
            
            // Check for connections to this specific node only
            for connection in currentMap.connections {
                if connection.toNodeId == nodeId {
                    connectedNodeIds.insert(connection.fromNodeId)
                }
            }
            
            // Flip only the specifically connected nodes in overlays
            for connectedNodeId in connectedNodeIds {
                for overlayMapId in overlayMapIds {
                    if var overlayMap = maps.first(where: { $0.id == overlayMapId }) {
                        if let nodeIndex = overlayMap.nodes.firstIndex(where: { $0.id == connectedNodeId }) {
                            overlayMap.nodes[nodeIndex].isFlipped.toggle()
                            if let mapIndex = maps.firstIndex(where: { $0.id == overlayMapId }) {
                                maps[mapIndex] = overlayMap
                            }
                        }
                    }
                }
            }
            
            // Flip only the specifically connected nodes in base map
            for connectedNodeId in connectedNodeIds {
                if let nodeIndex = currentMap.nodes.firstIndex(where: { $0.id == connectedNodeId }) {
                    currentMap.nodes[nodeIndex].isFlipped.toggle()
                    if let mapIndex = maps.firstIndex(where: { $0.id == currentMap.id }) {
                        maps[mapIndex] = currentMap
                    }
                }
            }
            
            saveData()
        }
    }
    
    func flipAllFlippable() {
        saveStateForUndo()
        
        // Flip all flippable nodes in the base map
        if var currentMap = currentMap {
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
        }
        
        // Flip all flippable nodes in overlay maps
        for overlayMapId in overlayMapIds {
            if var overlayMap = maps.first(where: { $0.id == overlayMapId }) {
                for i in 0..<overlayMap.nodes.count {
                    if overlayMap.nodes[i].isFlippable {
                        overlayMap.nodes[i].isFlipped.toggle()
                    }
                }
                overlayMap.lastModified = Date()
                
                // Update the overlay map in the array
                if let mapIndex = maps.firstIndex(where: { $0.id == overlayMapId }) {
                    maps[mapIndex] = overlayMap
                }
            }
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
        
        // Save overlay map IDs
        let overlayMapIdStrings = overlayMapIds.map { $0.uuidString }
        userDefaults.set(overlayMapIdStrings, forKey: overlayMapIdsKey)
        print("✅ BubbleWordManager: Overlay map IDs saved: \(overlayMapIds)")
        
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
        
        // Load overlay map IDs
        if let overlayMapIdStrings = userDefaults.stringArray(forKey: overlayMapIdsKey) {
            overlayMapIds = Set(overlayMapIdStrings.compactMap { UUID(uuidString: $0) })
            print("✅ BubbleWordManager: Overlay map IDs loaded: \(overlayMapIds)")
        } else {
            print("❌ BubbleWordManager: No overlay map IDs found")
        }
    }
    
    func updateNodeWithDefinition(_ nodeId: UUID, word: String, definition: String, color: String) {
        guard var currentMap = currentMap else { return }
        saveStateForUndo()
        if let nodeIndex = currentMap.nodes.firstIndex(where: { $0.id == nodeId }) {
            currentMap.nodes[nodeIndex].word = word
            currentMap.nodes[nodeIndex].definition = definition
            currentMap.nodes[nodeIndex].color = color
            currentMap.lastModified = Date()
            // Update the map in the array
            if let mapIndex = maps.firstIndex(where: { $0.id == currentMap.id }) {
                maps[mapIndex] = currentMap
            }
            saveData()
        }
    }
} 