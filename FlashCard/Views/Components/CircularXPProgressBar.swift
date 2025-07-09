import SwiftUI

struct CircularXPProgressBar: View {
    let progress: Double // 0.0 to 1.0
    let xp: Int
    let level: Int
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 8)
                .frame(width: size, height: size)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    progress >= 1.0 ? 
                        AngularGradient(
                            gradient: Gradient(colors: [.green, .green.opacity(0.8)]),
                            center: .center
                        ) :
                        AngularGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            center: .center
                        ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: size, height: size)
                .animation(.easeInOut(duration: progress >= 1.0 ? 0.6 : 1.0), value: progress)
        }
    }
}

struct CircularXPProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        CircularXPProgressBar(progress: 0.65, xp: 230, level: 3, size: 140)
            .padding()
            .previewLayout(.sizeThatFits)
    }
} 