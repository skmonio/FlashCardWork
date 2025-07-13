import SwiftUI
import PhotosUI

struct UserProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    @StateObject private var userProfile = UserProfileManager.shared
    @StateObject private var statsManager = StatisticsManager.shared
    @State private var showingEditProfile = false
    @State private var showingImagePicker = false
    @State private var selectedTab = 0
    @State private var animatedProgress: Double = 0
    
    private let avatarOptions = [
        "person.crop.circle.fill",
        "person.crop.circle",
        "person.fill",
        "person",
        "person.2.fill",
        "person.2",
        "graduationcap.fill",
        "graduationcap",
        "book.fill",
        "book",
        "brain.head.profile",
        "brain"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    profileHeader
                    
                    // Tab Selector
                    tabSelector
                    
                    // Tab Content
                    tabContent
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: Binding(
                    get: {
                        if let imageData = userProfile.profileImageData {
                            return UIImage(data: imageData)
                        }
                        return nil
                    },
                    set: { uiImage in
                        if let uiImage = uiImage {
                            userProfile.profileImageData = uiImage.jpegData(compressionQuality: 0.8)
                        } else {
                            userProfile.profileImageData = nil
                        }
                    }
                ))
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .overlay(
                GlobalNotificationOverlay()
            )
            .onAppear {
                // Initialize animated progress
                animatedProgress = userProfile.progressToNextLevel
            }
            .onChange(of: userProfile.progressToNextLevel) { newProgress in
                // Check if we leveled up (progress went from high to low)
                let oldProgress = animatedProgress
                let newProgressValue = newProgress
                
                if oldProgress > 0.8 && newProgressValue < 0.2 {
                    // Likely a level up - animate to 1.0 first (completion)
                    withAnimation(.easeInOut(duration: 0.6)) {
                        animatedProgress = 1.0
                    }
                    
                    // After reaching 1.0, wait a moment, then start filling from 0 to new progress
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        // Reset to 0 first (instant, no animation)
                        animatedProgress = 0.0
                        
                        // Then animate from 0 to new progress
                        withAnimation(.easeInOut(duration: 0.8)) {
                            animatedProgress = newProgressValue
                        }
                    }
                } else {
                    // Normal progress update
                    withAnimation(.easeInOut(duration: 1.0)) {
                        animatedProgress = newProgressValue
                    }
                }
            }
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile Image with Circular XP Progress Bar
            ZStack {
                // Circular XP Progress Bar (larger, behind the photo)
                CircularXPProgressBar(
                    progress: animatedProgress,
                    xp: userProfile.xp,
                    level: userProfile.level,
                    size: 140
                )
                
                // Profile Photo (smaller, on top)
                Button(action: {
                    showingImagePicker = true
                }) {
                    if let imageData = userProfile.profileImageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: userProfile.selectedAvatar)
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                            .frame(width: 100, height: 100)
                            .background(Circle().fill(Color.blue.opacity(0.1)))
                    }
                }
                
                // Edit indicator
                Circle()
                    .fill(Color.blue)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Image(systemName: "pencil")
                            .font(.caption)
                            .foregroundColor(.white)
                    )
                    .offset(x: 35, y: 35)
            }
            
            // User Info
            VStack(spacing: 8) {
                Text(userProfile.username)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Level \(userProfile.level)")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
        }
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            TabButton(
                title: "Stats",
                isSelected: selectedTab == 0,
                action: { selectedTab = 0 }
            )
            
            TabButton(
                title: "Achievements",
                isSelected: selectedTab == 1,
                action: { selectedTab = 1 }
            )
            
            TabButton(
                title: "Rewards",
                isSelected: selectedTab == 2,
                action: { selectedTab = 2 }
            )
        }
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case 0:
            statsTab
        case 1:
            achievementsTab
        case 2:
            rewardsTab
        default:
            statsTab
        }
    }
    
    private var statsTab: some View {
        // Access all cards for stats
        let allCards: [FlashCard] = viewModel.flashCards
        let averageLearningPercent = allCards.isEmpty ? 0 : Int((allCards.compactMap { $0.learningPercentage ?? 0 }.reduce(0, +)) / max(1, allCards.count))
        let currentStreak = StreakManager.shared.currentStreak
        let xpToNextLevel = max(0, userProfile.xpForLevel(userProfile.level + 1) - userProfile.xp)

        return VStack(spacing: 20) {
            // Study Statistics (just 3 cards, no carousel)
            VStack(alignment: .leading, spacing: 16) {
                Text("Study Statistics")
                    .font(.headline)
                    .padding(.horizontal)

                HStack(spacing: 16) {
                    StatCard(
                        icon: "flame.fill",
                        title: "Current Streak",
                        value: "\(currentStreak) days",
                        color: .red
                    )
                    StatCard(
                        icon: "percent",
                        title: "Average Learning %",
                        value: "\(averageLearningPercent)%",
                        color: .purple
                    )
                    StatCard(
                        icon: "arrow.up.circle.fill",
                        title: "XP to Next Level",
                        value: "\(xpToNextLevel) XP",
                        color: .indigo
                    )
                }
                .padding(.horizontal)
            }

            // Deck Progress Bar Chart Section (unchanged)
            VStack(alignment: .leading, spacing: 12) {
                Text("Deck Progress")
                    .font(.headline)
                    .padding(.top, 8)
                if viewModel.decks.isEmpty {
                    Text("No decks yet. Add some decks to start tracking your progress!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                } else {
                    ForEach(viewModel.decks.filter { !$0.cards.isEmpty }, id: \.id) { deck in
                        let mastered = deck.cards.filter { ($0.learningPercentage ?? 0) >= 90 }.count
                        let learnt = deck.cards.filter { ($0.learningPercentage ?? 0) >= 70 && ($0.learningPercentage ?? 0) < 90 }.count
                        let notLearnt = deck.cards.filter { ($0.learningPercentage ?? 0) < 70 }.count
                        let total = deck.cards.count
                        HStack(alignment: .center, spacing: 8) {
                            Text(deck.name)
                                .font(.subheadline)
                                .frame(width: 110, alignment: .leading)
                            GeometryReader { geometry in
                                let barWidth = geometry.size.width
                                let masteredWidth = barWidth * CGFloat(mastered) / CGFloat(max(1, total))
                                let learntWidth = barWidth * CGFloat(learnt) / CGFloat(max(1, total))
                                let notLearntWidth = barWidth * CGFloat(notLearnt) / CGFloat(max(1, total))
                                HStack(spacing: 0) {
                                    Rectangle()
                                        .fill(Color.green)
                                        .frame(width: masteredWidth, height: 16)
                                    Rectangle()
                                        .fill(Color.yellow)
                                        .frame(width: learntWidth, height: 16)
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: notLearntWidth, height: 16)
                                }
                                .cornerRadius(6)
                            }
                            .frame(height: 16)
                            .padding(.horizontal, 4)
                            Text("\(mastered)/\(total) mastered")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .frame(height: 24)
                        .padding(.vertical, 2)
                    }
                }
            }
        }
    }

    private var achievementsTab: some View {
        VStack(spacing: 20) {
            // Achievement Summary
            VStack(spacing: 12) {
                HStack {
                    Text("Achievements")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(userProfile.unlockedAchievementsCount)/\(userProfile.totalAchievementsCount)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: Double(userProfile.unlockedAchievementsCount) / Double(userProfile.totalAchievementsCount))
                    .accentColor(.blue)
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            
            // Achievement Categories
            ForEach(AchievementType.allCases, id: \.self) { type in
                VStack(alignment: .leading, spacing: 12) {
                    let typeAchievements = userProfile.getAchievements(of: type)
                    let unlockedCount = typeAchievements.filter { $0.isUnlocked }.count
                    
                    HStack {
                        Image(systemName: type == .xp ? "star.fill" : type == .level ? "number.circle.fill" : type == .streak ? "flame.fill" : type == .sessions ? "book.fill" : type == .perfect ? "checkmark.circle.fill" : "target")
                            .foregroundColor(type.color)
                        
                        Text(type.rawValue.uppercased())
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("\(unlockedCount)/\(typeAchievements.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(typeAchievements) { achievement in
                            AchievementBadgeView(achievement: achievement)
                        }
                    }
                }
            }
        }
    }
    
    private var rewardsTab: some View {
        VStack(spacing: 20) {
            // Available Rewards
            VStack(alignment: .leading, spacing: 12) {
                Text("Available Rewards")
                    .font(.headline)
                
                if userProfile.availableLevelRewards.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "gift")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        Text("No rewards available")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Level up to unlock rewards!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        ForEach(userProfile.availableLevelRewards) { reward in
                            LevelRewardView(reward: reward) {
                                userProfile.claimLevelReward(reward)
                            }
                        }
                    }
                }
            }
            
            // All Rewards
            VStack(alignment: .leading, spacing: 12) {
                Text("All Rewards")
                    .font(.headline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(userProfile.levelRewards) { reward in
                        LevelRewardView(reward: reward) {
                            if !reward.isClaimed && userProfile.level >= reward.level {
                                userProfile.claimLevelReward(reward)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func formatTotalTime() -> String {
        let totalSeconds = statsManager.studySessions.reduce(0) { $0 + $1.duration }
        let hours = Int(totalSeconds) / 3600
        let minutes = Int(totalSeconds) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Supporting Views

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.blue : Color.clear)
                )
        }
    }
}

struct SessionRowView: View {
    let session: StudySession
    
    var body: some View {
        HStack(spacing: 12) {
            // Session icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "book.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
            }
            
            // Session details
            VStack(alignment: .leading, spacing: 4) {
                Text("Study Session")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(session.knownCards) known, \(session.unknownCards) unknown")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Session stats
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(session.accuracyPercentage)%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(session.accuracyPercentage >= 80 ? .green : .orange)
                
                Text(formatDuration(session.duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct EditProfileView: View {
    @ObservedObject var userProfile = UserProfileManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var username: String = ""
    @State private var selectedAvatar: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile Information") {
                    TextField("Username", text: $username)
                    
                    Picker("Avatar", selection: $selectedAvatar) {
                        ForEach(availableAvatars, id: \.self) { avatar in
                            HStack {
                                Image(systemName: avatar)
                                    .foregroundColor(.blue)
                                Text(avatarName(for: avatar))
                            }
                            .tag(avatar)
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        userProfile.updateProfile(username: username, avatar: selectedAvatar)
                        dismiss()
                    }
                }
            }
            .onAppear {
                username = userProfile.username
                selectedAvatar = userProfile.selectedAvatar
            }
        }
    }
    
    private var availableAvatars: [String] {
        return [
            "person.crop.circle.fill",
            "person.crop.circle.badge.plus",
            "person.crop.circle.badge.checkmark",
            "person.crop.circle.badge.questionmark",
            "person.crop.circle.badge.exclamationmark",
            "person.crop.circle.badge.moon",
            "person.crop.circle.badge.clock",
            "person.crop.circle.badge.xmark"
        ]
    }
    
    private func avatarName(for avatar: String) -> String {
        switch avatar {
        case "person.crop.circle.fill": return "Default"
        case "person.crop.circle.badge.plus": return "Plus"
        case "person.crop.circle.badge.checkmark": return "Checkmark"
        case "person.crop.circle.badge.questionmark": return "Question"
        case "person.crop.circle.badge.exclamationmark": return "Exclamation"
        case "person.crop.circle.badge.moon": return "Moon"
        case "person.crop.circle.badge.clock": return "Clock"
        case "person.crop.circle.badge.xmark": return "X Mark"
        default: return "Unknown"
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(viewModel: FlashCardViewModel())
    }
} 