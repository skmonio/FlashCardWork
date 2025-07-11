import SwiftUI

struct CustomHeaderView: View {
    let title: String
    let onBack: () -> Void
    let trailing: AnyView?
    
    init(title: String, onBack: @escaping () -> Void, trailing: AnyView? = nil) {
        self.title = title
        self.onBack = onBack
        self.trailing = trailing
    }
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                    Text("Back")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.blue)
            }
            Spacer()
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            Spacer()
            if let trailing = trailing {
                trailing
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 1, y: 1)
    }
} 