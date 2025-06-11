import SwiftUI

struct LearningPercentageView: View {
    let percentage: Int?
    
    var body: some View {
        if let percentage = percentage {
            HStack(spacing: 4) {
                Text("\(percentage)%")
                    .font(.caption)
                    .fontWeight(.medium)
                Image(systemName: percentage == 100 ? "star.fill" : "chart.bar.fill")
                    .font(.caption2)
            }
            .foregroundColor(colorForPercentage(percentage))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColorForPercentage(percentage))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(colorForPercentage(percentage).opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private func colorForPercentage(_ percentage: Int) -> Color {
        switch percentage {
        case 100:
            return .green
        case 80..<100:
            return .blue
        case 60..<80:
            return .orange
        default:
            return .red
        }
    }
    
    private func backgroundColorForPercentage(_ percentage: Int) -> Color {
        switch percentage {
        case 100:
            return .green.opacity(0.1)
        case 80..<100:
            return .blue.opacity(0.1)
        case 60..<80:
            return .orange.opacity(0.1)
        default:
            return .red.opacity(0.1)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        LearningPercentageView(percentage: 100)
        LearningPercentageView(percentage: 85)
        LearningPercentageView(percentage: 67)
        LearningPercentageView(percentage: 42)
        LearningPercentageView(percentage: nil)
    }
    .padding()
} 