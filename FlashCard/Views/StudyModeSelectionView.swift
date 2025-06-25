import SwiftUI

struct StudyModeSelectionView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let gameMode: GameMode
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var selectedStudyMode: StudyMode = .adaptive
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 16) {
                Text("Choose Your Study Mode")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Select how you want to study your cards")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            // Study Mode Options
            VStack(spacing: 20) {
                ForEach(StudyMode.allCases, id: \.self) { studyMode in
                    StudyModeCard(
                        studyMode: studyMode,
                        isSelected: selectedStudyMode == studyMode,
                        onTap: {
                            selectedStudyMode = studyMode
                        }
                    )
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Continue Button
            Button(action: {
                navigationCoordinator.push(NavigationDestination.studyTypeSelection(gameMode, selectedStudyMode))
            }) {
                Text("Continue")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .navigationTitle(gameMode.title)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(false)
    }
}

struct StudyModeCard: View {
    let studyMode: StudyMode
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: studyMode.icon)
                    .font(.title)
                    .foregroundColor(isSelected ? studyMode.color : .gray)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(studyMode.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(studyMode.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(studyMode.color)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? studyMode.color.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? studyMode.color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    StudyModeSelectionView(
        viewModel: FlashCardViewModel(),
        gameMode: .study
    )
} 