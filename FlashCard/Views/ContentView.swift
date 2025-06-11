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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(card.word)
                    .font(.headline)
                
                Spacer()
                
                // Show learning progress percentage
                if let progress = card.learningProgress {
                    Text(String(format: "%.0f%%", progress))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(progressColor(progress))
                        .cornerRadius(8)
                }
            }
            
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
    }
    
    private func progressColor(_ progress: Double) -> Color {
        if progress == 100 { return .green }
        if progress >= 75 { return .blue }
        if progress >= 50 { return .orange }
        return .red
    }
} 
