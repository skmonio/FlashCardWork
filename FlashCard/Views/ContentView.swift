import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FlashCardViewModel()
    
    var body: some View {
        HomeView(viewModel: viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CardRow: View {
    let card: FlashCard
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(card.word)
                    .font(.headline)
                Text(card.definition)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if !card.example.isEmpty {
                    Text("Example: \(card.example)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
            
            Spacer()
            
            // Learning percentage on the right
            LearningPercentageView(percentage: card.learningPercentage)
        }
    }
} 
