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
    @ObservedObject var viewModel: FlashCardViewModel
    
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
            
            // Learning percentage badge (only show if card has been attempted)
            if let percentage = card.learningPercentage {
                HStack(spacing: 4) {
                    Text("\(Int(percentage))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(progressColor(for: percentage))
                        )
                }
            }
        }
    }
    
    private func progressColor(for percentage: Double) -> Color {
        switch percentage {
        case 100:
            return .green
        case 75..<100:
            return .blue
        case 50..<75:
            return .orange
        default:
            return .red
        }
    }
} 
