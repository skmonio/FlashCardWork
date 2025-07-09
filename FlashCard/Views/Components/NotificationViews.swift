import SwiftUI

// MARK: - Level Up Notification
struct LevelUpNotificationView: View {
    let message: String
    let level: Int
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            VStack(spacing: 0) {
                // Main notification card
                VStack(spacing: 16) {
                    // Icon and level
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 80, height: 80)
                            
                            Text("\(level)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        Text("LEVEL UP!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    // Message
                    Text(message)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Progress indicator
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(index == 1 ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == 1 ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: index)
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 2)
                )
            }
            .transition(.asymmetric(
                insertion: .scale.combined(with: .opacity),
                removal: .scale.combined(with: .opacity)
            ))
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isShowing)
        }
    }
}

// MARK: - Achievement Notification
struct AchievementNotificationView: View {
    let achievement: Achievement
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            VStack(spacing: 0) {
                // Main notification card
                VStack(spacing: 16) {
                    // Icon and title
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(achievement.type.color.opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: achievement.icon)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(achievement.type.color)
                        }
                        
                        Text("ACHIEVEMENT UNLOCKED!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    // Achievement details
                    VStack(spacing: 8) {
                        Text(achievement.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(achievement.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Type indicator
                    HStack(spacing: 4) {
                        Circle()
                            .fill(achievement.type.color)
                            .frame(width: 8, height: 8)
                        
                        Text(achievement.type.rawValue.uppercased())
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(achievement.type.color)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(achievement.type.color.opacity(0.1))
                    )
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(achievement.type.color.opacity(0.3), lineWidth: 2)
                )
            }
            .transition(.asymmetric(
                insertion: .scale.combined(with: .opacity),
                removal: .scale.combined(with: .opacity)
            ))
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isShowing)
        }
    }
}

// MARK: - Floating XP Notification
struct FloatingXPNotificationView: View {
    let amount: Int
    let position: CGPoint
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            Text("+\(amount) XP")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.yellow)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.yellow.opacity(0.2))
                        .overlay(
                            Capsule()
                                .stroke(Color.yellow.opacity(0.4), lineWidth: 1)
                        )
                )
                .position(position)
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
                .animation(.easeOut(duration: 1.0), value: isShowing)
        }
    }
}

// MARK: - Global Notification Overlay
struct GlobalNotificationOverlay: View {
    var body: some View {
        NotificationBanner()
    }
}

// MARK: - Achievement Badge Component
struct AchievementBadgeView: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.type.color.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(achievement.isUnlocked ? achievement.type.color : .gray)
            }
            
            // Title
            Text(achievement.title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Description
            Text(achievement.description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Status indicator
            if achievement.isUnlocked {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Text("Unlocked")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("Locked")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(achievement.isUnlocked ? achievement.type.color.opacity(0.05) : Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(achievement.isUnlocked ? achievement.type.color.opacity(0.2) : Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
        .scaleEffect(achievement.isUnlocked ? 1.0 : 0.95)
        .opacity(achievement.isUnlocked ? 1.0 : 0.7)
        .animation(.easeInOut(duration: 0.3), value: achievement.isUnlocked)
    }
}

// MARK: - Level Reward Component
struct LevelRewardView: View {
    let reward: LevelReward
    let onClaim: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(reward.type.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: reward.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(reward.type.color)
            }
            
            // Title
            Text(reward.title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Description
            Text(reward.description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Level requirement
            Text("Level \(reward.level)")
                .font(.caption2)
                .foregroundColor(.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.1))
                )
            
            // Claim button
            if !reward.isClaimed {
                Button(action: onClaim) {
                    Text("Claim")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(reward.type.color)
                        )
                }
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Text("Claimed")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(reward.type.color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(reward.type.color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview
struct NotificationViews_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            LevelUpNotificationView(
                message: "🎉 Level 5 Unlocked!",
                level: 5,
                isShowing: .constant(true)
            )
            
            AchievementNotificationView(
                achievement: Achievement(
                    title: "XP Master",
                    description: "Earn 1000 XP",
                    icon: "star.square.fill",
                    xpRequired: 1000,
                    levelRequired: 3,
                    type: .xp
                ),
                isShowing: .constant(true)
            )
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
} 