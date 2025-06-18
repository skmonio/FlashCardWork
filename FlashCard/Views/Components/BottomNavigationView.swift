import SwiftUI

struct BottomNavigationView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Binding var selectedTab: TabItem
    let onNavigate: (TabItem) -> Void
    
    enum TabItem: String, CaseIterable {
        case home = "home"
        case cards = "cards"
        case settings = "settings"
        
        var icon: String {
            switch self {
            case .home: return "house"
            case .cards: return "rectangle.stack"
            case .settings: return "gearshape"
            }
        }
        
        var selectedIcon: String {
            switch self {
            case .home: return "house.fill"
            case .cards: return "rectangle.stack.fill"
            case .settings: return "gearshape.fill"
            }
        }
        
        var title: String {
            switch self {
            case .home: return "Home"
            case .cards: return "Cards"
            case .settings: return "Settings"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator))
                .opacity(0.5)
            
            HStack(spacing: 0) {
                ForEach(TabItem.allCases, id: \.rawValue) { tab in
                    Button(action: {
                        selectedTab = tab
                        onNavigate(tab)
                        HapticManager.shared.lightImpact()
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                                .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                                .foregroundColor(selectedTab == tab ? .blue : .secondary)
                                .animation(.easeInOut(duration: 0.2), value: selectedTab)
                            
                            Text(tab.title)
                                .font(.caption2)
                                .fontWeight(selectedTab == tab ? .semibold : .regular)
                                .foregroundColor(selectedTab == tab ? .blue : .secondary)
                                .animation(.easeInOut(duration: 0.2), value: selectedTab)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            .background(Color(.systemBackground))
        }
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: -1)
        )
    }
}

#Preview {
    @State var selectedTab = BottomNavigationView.TabItem.home
    return BottomNavigationView(
        viewModel: FlashCardViewModel(),
        selectedTab: $selectedTab,
        onNavigate: { _ in }
    )
} 