import SwiftUI

struct NotificationBanner: View {
    @ObservedObject var notificationManager = NotificationManager.shared
    
    var body: some View {
        ZStack {
            if let notification = notificationManager.currentNotification,
               notificationManager.isShowing {
                VStack {
                    // Notification Banner
                    HStack(spacing: 12) {
                        // Icon
                        Image(systemName: notification.type.icon)
                            .foregroundColor(notification.type.color)
                            .font(.title2)
                            .frame(width: 24)
                        
                        // Content
                        VStack(alignment: .leading, spacing: 2) {
                            Text(notification.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(notification.message)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        // Dismiss button
                        Button(action: {
                            notificationManager.dismissNotification()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.title3)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: notificationManager.isShowing)
            }
        }
    }
}

#Preview {
    NotificationBanner()
} 