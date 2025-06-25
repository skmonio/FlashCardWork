import SwiftUI

struct StudyTypeSelectionView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let gameMode: GameMode
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var selectedCardCount: Int = 10
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 16) {
                Text("Choose Study Type")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("How would you like to study?")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            // Study Type Options
            VStack(spacing: 20) {
                // Quick Study Option
                StudyTypeCard(
                    title: "Quick Study",
                    subtitle: "Random cards from all decks",
                    description: "Perfect for quick practice sessions",
                    icon: "bolt.fill",
                    color: .orange,
                    onTap: {
                        navigationCoordinator.push(NavigationDestination.quickStudy(gameMode, .adaptive, selectedCardCount))
                    }
                )
                
                // Normal Study Option
                StudyTypeCard(
                    title: "Normal Study",
                    subtitle: "Choose specific decks",
                    description: "Focused study on selected topics",
                    icon: "folder.fill",
                    color: .blue,
                    onTap: {
                        navigationCoordinator.push(NavigationDestination.normalStudy(gameMode, .adaptive))
                    }
                )
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("Study Type")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(false)
    }
}

struct StudyTypeCard: View {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(color)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
} 