import SwiftUI

struct BubbleWordTestView: View {
    @StateObject private var bubbleManager = BubbleWordManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Bubble Word Test")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("This is a test view to verify the Bubble Word feature works correctly.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    Button("Add Test Words") {
                        addTestWords()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Clear All") {
                        bubbleManager.resetData()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                    
                    Button("Show Bubble Word View") {
                        // This would navigate to the actual BubbleWordView
                        // For testing, we'll just show some stats
                        showStats()
                    }
                    .buttonStyle(.bordered)
                }
                
                // Show current stats
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Stats:")
                        .font(.headline)
                    
                    Text("Words: \(bubbleManager.nodes.count)")
                    Text("Connections: \(bubbleManager.connections.count)")
                    Text("Selected: \(bubbleManager.selectedNodeId?.uuidString.prefix(8) ?? "None")")
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Bubble Word Test")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func addTestWords() {
        let testWords = ["Hello", "World", "Swift", "SwiftUI", "Bubble", "Word", "Test", "Feature"]
        let centerX = UIScreen.main.bounds.width / 2
        let centerY = UIScreen.main.bounds.height / 2
        
        for (index, word) in testWords.enumerated() {
            let angle = Double(index) * (2 * Double.pi / Double(testWords.count))
            let radius: CGFloat = 150
            let x = centerX + CGFloat(cos(angle)) * radius
            let y = centerY + CGFloat(sin(angle)) * radius
            
            let position = CGPoint(x: x, y: y)
            bubbleManager.addNode(word: word, at: position)
        }
    }
    
    private func showStats() {
        print("Bubble Word Stats:")
        print("- Words: \(bubbleManager.nodes.count)")
        print("- Connections: \(bubbleManager.connections.count)")
        print("- Scale: \(bubbleManager.scale)")
        print("- Offset: \(bubbleManager.offset)")
        
        for node in bubbleManager.nodes {
            print("- Word: \(node.word), Position: \(node.position), Color: \(node.color)")
        }
    }
}

#Preview {
    BubbleWordTestView()
} 