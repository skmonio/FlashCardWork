import SwiftUI

struct FeatureNotAvailableView: View {
    let feature: String
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "lock.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            VStack(spacing: 12) {
                Text("Feature Not Available")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("\(feature) is only available in the full version of \(BuildConfiguration.appName).")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 16) {
                Text("Upgrade to the full version to access:")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 8) {
                    FeatureRow(icon: "book.closed.fill", text: "Dutch Lessons")
                    FeatureRow(icon: "book.pages.fill", text: "Dutch Grammar Rules")
                    FeatureRow(icon: "textformat.abc", text: "Dutch Vocabulary Packs")
                    FeatureRow(icon: "translate", text: "Translation Service")
                    FeatureRow(icon: "plus.circle.fill", text: "Advanced Grammar Features")
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            Button(action: {
                // In a real app, this would open the App Store or show upgrade options
                print("Upgrade to full version tapped")
            }) {
                Text("Upgrade to Full Version")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Text("Current version: \(BuildConfiguration.appName)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
        .navigationTitle("Feature Unavailable")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        FeatureNotAvailableView(feature: "Dutch Grammar")
    }
} 