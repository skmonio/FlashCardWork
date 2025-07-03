import SwiftUI

struct UnifiedBackButton: View {
    let action: () -> Void
    let style: BackButtonStyle
    
    enum BackButtonStyle {
        case toolbar      // For navigation toolbar (small, icon + text)
        case floating     // For floating buttons (circular, icon only)
        case card         // For card views (circular with background)
    }
    
    init(style: BackButtonStyle = .toolbar, action: @escaping () -> Void) {
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            switch style {
            case .toolbar:
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                    Text("Back")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.blue)
                
            case .floating:
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(Circle().fill(Color(.systemGray5)))
                
            case .card:
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 44, height: 44)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 20) {
        UnifiedBackButton(style: .toolbar) {
            print("Toolbar back tapped")
        }
        
        UnifiedBackButton(style: .floating) {
            print("Floating back tapped")
        }
        
        UnifiedBackButton(style: .card) {
            print("Card back tapped")
        }
    }
    .padding()
} 