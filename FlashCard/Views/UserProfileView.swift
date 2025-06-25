import SwiftUI
import PhotosUI

struct UserProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var userProfile = UserProfileManager.shared
    @StateObject private var statsManager = StatisticsManager.shared
    @State private var showingEditProfile = false
    
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
                VStack(spacing: 32) {
                    // Avatar with Circular Progress
                    VStack(spacing: 16) {
                        ZStack {
                            // Circular Progress Background
                            Circle()
                                .stroke(Color(.systemGray5), lineWidth: 8)
                                .frame(width: 120, height: 120)
                            
                            // Circular Progress Fill
                            Circle()
                                .trim(from: 0, to: userProfile.progressToNextLevel)
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 1.0), value: userProfile.progressToNextLevel)
                            
                            // Avatar or Profile Image
                            if let imageData = userProfile.profileImageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .background(Color(.systemBackground))
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            } else {
                                Image(systemName: userProfile.selectedAvatar)
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.blue)
                                    .background(Color(.systemBackground))
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                        }
                        
                        VStack(spacing: 4) {
                            Text(userProfile.username)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Level \(userProfile.level)")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            HStack(spacing: 8) {
                                Text("XP: \(userProfile.xp)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("•")
                                    .foregroundColor(.secondary)
                                Text("Next: \(userProfile.xpForLevel(userProfile.level + 1)) XP")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button("Edit Profile") {
                            showingEditProfile = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding(.top, 24)
                    
                    // Key Stats Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        ProfileStatCard(title: "Total Sessions", value: "\(statsManager.studySessions.count)", icon: "clock.fill", color: .blue, subtitle: "sessions")
                        ProfileStatCard(title: "Accuracy Rate", value: "\(Int(statsManager.getOverallAccuracy() * 100))%", icon: "target", color: .green, subtitle: "overall")
                    }
                    .padding(.horizontal)
                    
                    // Learning Progress
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Learning Progress")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ProgressStatRow(
                                title: "Cards Studied",
                                value: "\(statsManager.studySessions.reduce(0) { $0 + $1.totalCards })",
                                icon: "rectangle.stack.fill",
                                color: .blue,
                                progress: min(Double(statsManager.studySessions.count) / 100.0, 1.0)
                            )
                            
                            ProgressStatRow(
                                title: "Accuracy Rate",
                                value: "\(Int(statsManager.getOverallAccuracy() * 100))%",
                                icon: "target",
                                color: .green,
                                progress: statsManager.getOverallAccuracy()
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Achievements Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Achievements")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                            AchievementBadge(
                                icon: "star.fill",
                                title: "First Steps",
                                subtitle: "Complete first session",
                                achieved: statsManager.studySessions.count > 0
                            )
                            
                            AchievementBadge(
                                icon: "trophy.fill",
                                title: "XP Master",
                                subtitle: "1000 XP",
                                achieved: userProfile.xp >= 1000
                            )
                            
                            AchievementBadge(
                                icon: "bolt.fill",
                                title: "Speed Learner",
                                subtitle: "10 sessions",
                                achieved: statsManager.studySessions.count >= 10
                            )
                            
                            AchievementBadge(
                                icon: "target",
                                title: "Sharp Shooter",
                                subtitle: "90% accuracy",
                                achieved: statsManager.getOverallAccuracy() >= 0.9
                            )
                            
                            AchievementBadge(
                                icon: "infinity",
                                title: "Unstoppable",
                                subtitle: "100 sessions",
                                achieved: statsManager.studySessions.count >= 100
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("Your Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(
                    selectedAvatar: $userProfile.selectedAvatar,
                    username: $userProfile.username,
                    avatarOptions: avatarOptions
                )
            }
        }
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedAvatar: String
    @Binding var username: String
    let avatarOptions: [String]
    @StateObject private var userProfile = UserProfileManager.shared
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Photo Section
                    VStack(spacing: 16) {
                        Text("Profile Photo")
                            .font(.headline)
                        
                        // Current Photo Display
                        if let imageData = userProfile.profileImageData,
                           let uiImage = UIImage(data: imageData) {
                            VStack(spacing: 12) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .background(Color(.systemBackground))
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                                
                                Button("Remove Photo") {
                                    userProfile.setProfileImage(nil)
                                }
                                .foregroundColor(.red)
                                .font(.subheadline)
                            }
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: selectedAvatar)
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.blue)
                                    .background(Color(.systemGray6))
                                    .clipShape(Circle())
                                
                                PhotosPicker(selection: $selectedItem, matching: .images) {
                                    Text("Upload Photo")
                                        .foregroundColor(.blue)
                                        .font(.subheadline)
                                }
                                .onChange(of: selectedItem) { newItem in
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                            await MainActor.run {
                                                userProfile.setProfileImage(data)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    
                    // Avatar Selection
                    VStack(spacing: 16) {
                        Text("Choose Avatar")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                            ForEach(avatarOptions, id: \.self) { avatar in
                                Button(action: {
                                    selectedAvatar = avatar
                                    // Clear profile image when selecting avatar
                                    userProfile.setProfileImage(nil)
                                }) {
                                    Image(systemName: avatar)
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(selectedAvatar == avatar ? .white : .blue)
                                        .background(
                                            Circle()
                                                .fill(selectedAvatar == avatar ? .blue : Color(.systemGray6))
                                        )
                                        .frame(width: 60, height: 60)
                                }
                            }
                        }
                    }
                    .padding()
                    
                    // Username Input
                    VStack(spacing: 12) {
                        Text("Username")
                            .font(.headline)
                        
                        TextField("Enter username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { 
                        // Profile is automatically saved via @Published properties
                        dismiss() 
                    }
                }
            }
        }
    }
}

// MARK: - Enhanced Stat Card
struct ProfileStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: color.opacity(0.08), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Progress Stat Row
struct ProgressStatRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let progress: Double
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(value)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(color)
                }
                
                ProgressView(value: progress)
                    .accentColor(color)
                    .frame(height: 4)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Enhanced Achievement Badge
struct AchievementBadge: View {
    let icon: String
    let title: String
    let subtitle: String
    let achieved: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(achieved ? .yellow : .gray)
                .opacity(achieved ? 1.0 : 0.4)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .opacity(achieved ? 1.0 : 0.5)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .opacity(achieved ? 1.0 : 0.3)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 1)
    }
}

// MARK: - Helpers
extension StatisticsManager {
    var formattedTotalStudyTime: String {
        let hours = Int(totalStudyTime) / 3600
        let minutes = (Int(totalStudyTime) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    func getOverallAccuracy() -> Double {
        let totalCards = studySessions.reduce(0) { $0 + $1.totalCards }
        let correctCards = studySessions.reduce(0) { $0 + $1.knownCards }
        return totalCards > 0 ? Double(correctCards) / Double(totalCards) : 0.0
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
} 