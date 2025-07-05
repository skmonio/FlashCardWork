import SwiftUI

struct GameHeaderView: View {
    let currentIndex: Int
    let totalCards: Int
    let score: Int
    let combo: Int
    let knownCount: Int?
    let unknownCount: Int?
    let skippedCount: Int?
    let onAudioTapped: (() -> Void)?
    let isAudioPlaying: Bool
    let studyMode: StudyMode?
    let currentRound: Int?
    let totalRounds: Int?
    let sessionXP: Int // XP gained during current session
    let showProgressIndicator: Bool // Show prominent progress indicator for progressive study
    let progressOverride: Double? // Optional override for progress bar fill
    let isComplete: Bool // Whether the game is complete (show 100% progress)
    
    @StateObject private var userProfile = UserProfileManager.shared
    
    init(currentIndex: Int, totalCards: Int, score: Int, combo: Int, knownCount: Int? = nil, unknownCount: Int? = nil, skippedCount: Int? = nil, onAudioTapped: (() -> Void)? = nil, isAudioPlaying: Bool = false, studyMode: StudyMode? = nil, currentRound: Int? = nil, totalRounds: Int? = nil, sessionXP: Int, showProgressIndicator: Bool = false, progressOverride: Double? = nil, isComplete: Bool = false) {
        self.currentIndex = currentIndex
        self.totalCards = totalCards
        self.score = score
        self.combo = combo
        self.knownCount = knownCount
        self.unknownCount = unknownCount
        self.skippedCount = skippedCount
        self.onAudioTapped = onAudioTapped
        self.isAudioPlaying = isAudioPlaying
        self.studyMode = studyMode
        self.currentRound = currentRound
        self.totalRounds = totalRounds
        self.sessionXP = sessionXP
        self.showProgressIndicator = showProgressIndicator
        self.progressOverride = progressOverride
        self.isComplete = isComplete
    }
    
    // Computed properties
    private var progress: Double {
        guard totalCards > 0 else { return 0 }
        
        // If game is complete, show 100% progress
        if isComplete {
            return 1.0
        }
        
        if showProgressIndicator {
            if let override = progressOverride {
                return min(override, 1.0)
            } else {
                // Only fill bar after answering last question
                let capped = Double(max(currentIndex-1, 0)) / Double(totalCards)
                return min(capped, 1.0)
            }
        }
        // For all games, only fill bar after answering last question
        // Use currentIndex-1 to show progress based on completed questions
        let calculatedProgress = Double(max(currentIndex-1, 0)) / Double(totalCards)
        return min(calculatedProgress, 1.0)
    }
    
    private var progressText: String {
        if showProgressIndicator {
            // For progressive study, show currentIndex/totalCards, but cap at totalCards
            let displayIndex = min(max(currentIndex, 1), totalCards)
            return "\(displayIndex)/\(totalCards)"
        }
        let displayCurrentIndex = min(currentIndex, totalCards)
        return "\(displayCurrentIndex)/\(totalCards)"
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Progress Bar
            VStack(spacing: 8) {
                HStack {
                    Text(progressText)
                        .font(showProgressIndicator ? .title2 : .subheadline)
                        .fontWeight(showProgressIndicator ? .bold : .medium)
                        .foregroundColor(.primary)
                        .padding(showProgressIndicator ? 8 : 0)
                        .background(
                            showProgressIndicator ? 
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    ) : nil
                        )
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 14))
                        Text("+\(sessionXP) XP")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .frame(height: 12)
                        
                        // Progress fill
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: geometry.size.width * progress, height: 12)
                            .animation(.easeInOut(duration: 0.3), value: progress)
                    }
                }
                .frame(height: 12)
            }
            
            // Combo and Stats Row
            HStack {
                // Combo indicator
                if combo > 1 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 16))
                        Text("\(combo)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.1))
                    )
                }
                
                Spacer()
                
                // Audio button (center)
                if let onAudioTapped = onAudioTapped {
                    Button(action: onAudioTapped) {
                        Image(systemName: isAudioPlaying ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                            .foregroundColor(isAudioPlaying ? .orange : .blue)
                            .font(.system(size: 18))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                    )
                    .scaleEffect(isAudioPlaying ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isAudioPlaying)
                }
                
                Spacer()
                
                // Study view specific stats
                if let knownCount = knownCount,
                   let unknownCount = unknownCount,
                   let skippedCount = skippedCount {
                    HStack(spacing: 16) {
                        StatIndicator(
                            count: knownCount,
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        StatIndicator(
                            count: unknownCount,
                            icon: "xmark.circle.fill",
                            color: .red
                        )
                        StatIndicator(
                            count: skippedCount,
                            icon: "minus.circle.fill",
                            color: .blue
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20) // Reduced from 50 to move header higher
        .background(Color(.systemBackground))
    }
}

struct StatIndicator: View {
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 14))
            Text("\(count)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

// Preview
struct GameHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            GameHeaderView(
                currentIndex: 7,
                totalCards: 20,
                score: 150,
                combo: 3,
                knownCount: 5,
                unknownCount: 2,
                skippedCount: 1,
                onAudioTapped: nil,
                isAudioPlaying: false,
                studyMode: nil,
                currentRound: nil,
                totalRounds: nil,
                sessionXP: 0,
                isComplete: false
            )
            
            Spacer()
        }
        .previewLayout(.sizeThatFits)
    }
} 