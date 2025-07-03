import SwiftUI

struct UnifiedHeader: View {
    let title: String
    let showBackButton: Bool
    let showProfileIcon: Bool
    let onBack: (() -> Void)?
    let onProfile: (() -> Void)?
    let leading: AnyView?
    let trailing: AnyView?
    
    init(
        title: String,
        showBackButton: Bool = true,
        showProfileIcon: Bool = true,
        onBack: (() -> Void)? = nil,
        onProfile: (() -> Void)? = nil,
        leading: (() -> AnyView)? = nil,
        trailing: (() -> AnyView)? = nil
    ) {
        self.title = title
        self.showBackButton = showBackButton
        self.showProfileIcon = showProfileIcon
        self.onBack = onBack
        self.onProfile = onProfile
        self.leading = leading?()
        self.trailing = trailing?()
    }
    
    var body: some View {
        HStack {
            // Left: Back button, leading content, or invisible spacer
            HStack(spacing: 8) {
                if showBackButton {
                    Button(action: { onBack?() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text("Back")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.blue)
                    }
                }
                if let leading = leading {
                    leading
                }
            }
            .frame(width: 80, alignment: .leading)

            Spacer(minLength: 0)

            // Title (Center)
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)

            Spacer(minLength: 0)

            // Right: Trailing custom view and/or profile icon, or invisible spacer
            HStack(spacing: 8) {
                if let trailing = trailing {
                    trailing
                }
                if showProfileIcon {
                    Button(action: { onProfile?() }) {
                        Image(systemName: "person.crop.circle")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .frame(width: 80, alignment: .trailing)
            .contentShape(Rectangle())
            .background(Color.clear)
            .if(!showProfileIcon && trailing == nil) { view in
                view.hidden()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator)),
            alignment: .bottom
        )
    }
}

// Helper view modifier for conditional hiding
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        UnifiedHeader(
            title: "Dutch Grammar",
            onBack: { print("Back tapped") },
            onProfile: { print("Profile tapped") },
            leading: {
                AnyView(
                    Button(action: { print("Info tapped") }) {
                        Image(systemName: "info.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                )
            },
            trailing: {
                AnyView(
                    Button(action: { print("Info tapped") }) {
                        Image(systemName: "info.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                )
            }
        )
        Spacer()
    }
} 