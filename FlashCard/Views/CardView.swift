import SwiftUI

struct CardView: View {
    let card: FlashCard
    @State private var isShowingFront = true
    @State private var degree: Double = 0
    
    var body: some View {
        ZStack {
            // Front of card (Word)
            frontView
                .opacity(isShowingFront ? 1 : 0)
                .rotation3DEffect(.degrees(degree), axis: (x: 0, y: 1, z: 0))
            
            // Back of card (Definition and Example)
            backView
                .opacity(isShowingFront ? 0 : 1)
                .rotation3DEffect(.degrees(degree - 180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(height: 200)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.5)) {
                degree += 180
                isShowingFront.toggle()
            }
        }
    }
    
    private var frontView: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.blue.opacity(0.1))
            .overlay(
                VStack {
                    Text(card.word)
                        .font(.title)
                        .bold()
                    Text("Tap to flip")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            )
            .padding()
    }
    
    private var backView: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.green.opacity(0.1))
            .overlay(
                VStack(spacing: 16) {
                    Text(card.definition)
                        .font(.body)
                        .multilineTextAlignment(.center)
                    
                    if !card.example.isEmpty {
                        Divider()
                        Text("Example:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(card.example)
                            .font(.body)
                            .italic()
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
            )
            .padding()
    }
} 