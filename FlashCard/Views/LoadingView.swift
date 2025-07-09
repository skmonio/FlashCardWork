import SwiftUI

struct LoadingView: View {
    @State private var opacity: Double = 0
    @State private var showContent = false
    @State private var loadingText = "Loading your Dutch learning journey..."
    @State private var progressPulse: Double = 1.0
    
    let content: AnyView
    let minimumDisplayTime: Double
    let isReadyCheck: (() -> Bool)?
    
    init<Content: View>(
        minimumDisplayTime: Double = 2.0,
        isReadyCheck: (() -> Bool)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = AnyView(content())
        self.minimumDisplayTime = minimumDisplayTime
        self.isReadyCheck = isReadyCheck
    }
    
    var body: some View {
        ZStack {
            if showContent {
                content
                    .transition(.opacity)
            } else {
                splashScreen
                    .transition(.opacity)
            }
        }
        .onAppear {
            startLoadingSequence()
        }
    }
    
    private var splashScreen: some View {
        ZStack {
            // Background color
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Main splash image - full screen
                Image("taal-trek-splash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(opacity)
                
                Spacer()
                
                // Loading indicator at bottom
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2 * progressPulse)
                        .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                    
                    Text(loadingText)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                }
                .opacity(opacity * 0.8)
                .padding(.bottom, 60)
            }
        }
    }
    
    private func startLoadingSequence() {
        // Simple fade in
        withAnimation(.easeOut(duration: 0.3)) {
            opacity = 1.0
        }
        
        // Start pulsing animation for progress indicator
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                progressPulse = 1.2
            }
        }
        
        // Update loading text progressively (faster)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.3)) {
                loadingText = "Preparing your flashcards..."
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 0.3)) {
                loadingText = "Almost ready..."
            }
        }
        
        // Check for readiness and transition to main content
        checkAndTransition()
    }
    
    private func checkAndTransition() {
        let startTime = Date()
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            let elapsed = Date().timeIntervalSince(startTime)
            let minimumTimeMet = elapsed >= minimumDisplayTime
            let isReady = isReadyCheck?() ?? true
            
            if minimumTimeMet && isReady {
                timer.invalidate()
                
                // Play begin sound as splash screen fades away
                SoundManager.shared.playBeginSound()
                
                // Add haptic feedback for completion
                HapticManager.shared.successNotification()
                
                withAnimation(.easeInOut(duration: 0.5)) {
                    showContent = true
                }
            }
        }
    }
}

#Preview {
    LoadingView {
        VStack {
            Text("Main Content")
                .font(.title)
            Text("App has loaded!")
                .foregroundColor(.secondary)
        }
        .padding()
    }
} 