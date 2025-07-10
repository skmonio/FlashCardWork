import Foundation
import SwiftUI

struct WordNode: Identifiable, Codable, Hashable {
    var id = UUID()
    var word: String
    var position: CGPoint
    var connections: Set<UUID> = []
    var color: String = "blue"
    var size: CGFloat = 120
    
    // Coding keys for CGPoint encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id, word, positionX, positionY, connections, color, size
    }
    
    init(word: String, position: CGPoint = CGPoint(x: 0, y: 0), color: String = "blue") {
        self.word = word
        self.position = position
        self.color = color
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
    }
    
    // Computed property to get SwiftUI Color
    var nodeColor: Color {
        switch color {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        case "pink": return .pink
        case "yellow": return .yellow
        case "mint": return .mint
        case "indigo": return .indigo
        default: return .blue
        }
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

class BubbleWordManager: ObservableObject {
    @Published var nodes: [WordNode] = []
    @Published var connections: [WordConnection] = []
    @Published var selectedNodeId: UUID?
    @Published var scale: CGFloat = 1.0
    @Published var offset: CGSize = .zero
    @Published var lastOffset: CGSize = .zero
    
    private let userDefaults = UserDefaults.standard
    private let nodesKey = "BubbleWordNodes"
    private let connectionsKey = "BubbleWordConnections"
    
    init() {
        loadData()
    }
    
    func addNode(word: String, at position: CGPoint, color: String = "blue") -> WordNode {
        let newNode = WordNode(word: word, position: position, color: color)
        nodes.append(newNode)
        saveData()
        return newNode
    }
    
    func connectNodes(fromNodeId: UUID, toNodeId: UUID) {
        // Check if connection already exists
        let existingConnection = connections.first { connection in
            (connection.fromNodeId == fromNodeId && connection.toNodeId == toNodeId) ||
            (connection.fromNodeId == toNodeId && connection.toNodeId == fromNodeId)
        }
        
        guard existingConnection == nil else { return }
        
        let connection = WordConnection(fromNodeId: fromNodeId, toNodeId: toNodeId)
        connections.append(connection)
        
        // Update node connections
        if let fromIndex = nodes.firstIndex(where: { $0.id == fromNodeId }) {
            nodes[fromIndex].connections.insert(toNodeId)
        }
        if let toIndex = nodes.firstIndex(where: { $0.id == toNodeId }) {
            nodes[toIndex].connections.insert(fromNodeId)
        }
        
        saveData()
    }
    
    func disconnectNodes(fromNodeId: UUID, toNodeId: UUID) {
        // Remove the connection
        connections.removeAll { connection in
            (connection.fromNodeId == fromNodeId && connection.toNodeId == toNodeId) ||
            (connection.fromNodeId == toNodeId && connection.toNodeId == fromNodeId)
        }
        
        // Remove connections from nodes
        if let fromIndex = nodes.firstIndex(where: { $0.id == fromNodeId }) {
            nodes[fromIndex].connections.remove(toNodeId)
        }
        if let toIndex = nodes.firstIndex(where: { $0.id == toNodeId }) {
            nodes[toIndex].connections.remove(fromNodeId)
        }
        
        saveData()
    }
    
    func removeNode(_ nodeId: UUID) {
        // Remove all connections involving this node
        connections.removeAll { connection in
            connection.fromNodeId == nodeId || connection.toNodeId == nodeId
        }
        
        // Remove connections from other nodes
        for i in nodes.indices {
            nodes[i].connections.remove(nodeId)
        }
        
        // Remove the node
        nodes.removeAll { $0.id == nodeId }
        
        // Clear selection if this node was selected
        if selectedNodeId == nodeId {
            selectedNodeId = nil
        }
        
        saveData()
    }
    
    func updateNodePosition(_ nodeId: UUID, to position: CGPoint) {
        if let index = nodes.firstIndex(where: { $0.id == nodeId }) {
            nodes[index].position = position
            saveData()
        }
    }
    
    func updateNode(_ nodeId: UUID, word: String, color: String) {
        if let index = nodes.firstIndex(where: { $0.id == nodeId }) {
            nodes[index].word = word
            nodes[index].color = color
            saveData()
        }
    }
    
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
    
    private func saveData() {
        if let nodesData = try? JSONEncoder().encode(nodes) {
            userDefaults.set(nodesData, forKey: nodesKey)
        }
        if let connectionsData = try? JSONEncoder().encode(connections) {
            userDefaults.set(connectionsData, forKey: connectionsKey)
        }
    }
    
    private func loadData() {
        if let nodesData = userDefaults.data(forKey: nodesKey),
           let loadedNodes = try? JSONDecoder().decode([WordNode].self, from: nodesData) {
            nodes = loadedNodes
        }
        
        if let connectionsData = userDefaults.data(forKey: connectionsKey),
           let loadedConnections = try? JSONDecoder().decode([WordConnection].self, from: connectionsData) {
            connections = loadedConnections
        }
    }
    
    func resetData() {
        nodes.removeAll()
        connections.removeAll()
        selectedNodeId = nil
        saveData()
    }
} 