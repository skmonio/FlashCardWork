import SwiftUI

struct GameFooterView: View {
    let hasSignificantProgress: Bool
    let showingResults: Bool
    let onClose: () -> Void
    let onSaveAndClose: (() -> Void)?
    let onPrevious: (() -> Void)?
    let canGoPrevious: Bool
    
    @State private var showingCloseConfirmation = false
    
    var body: some View {
        HStack {
            // Previous button (left side)
            if let onPrevious = onPrevious, canGoPrevious {
                Button(action: onPrevious) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .padding(12)
                        .background(Circle().fill(Color(.systemGray5)))
                }
            }
            
            Spacer()
            
            // Close button (center) - only show when not on results screen
            if !showingResults {
                Button(action: {
                    if hasSignificantProgress && !showingResults {
                        showingCloseConfirmation = true
                    } else {
                        onClose()
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .padding(12)
                        .background(Circle().fill(Color(.systemGray5)))
                }
            }
            
            Spacer()
        }
        .padding(.bottom, 20)
        .background(Color(.systemBackground))
        .alert("Close Game?", isPresented: $showingCloseConfirmation) {
            if let onSaveAndClose = onSaveAndClose {
                Button("Save & Close", role: .destructive) {
                    onSaveAndClose()
                }
            }
            Button(onSaveAndClose != nil ? "Close Without Saving" : "Close", role: .destructive) {
                onClose()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(hasSignificantProgress ? 
                "Would you like to save your progress?" : 
                "Are you sure you want to close?")
        }
    }
}

// Preview
struct GameFooterView_Previews: PreviewProvider {
    static var previews: some View {
        GameFooterView(
            hasSignificantProgress: true,
            showingResults: false,
            onClose: {},
            onSaveAndClose: {},
            onPrevious: nil,
            canGoPrevious: false
        )
        .previewLayout(.sizeThatFits)
    }
} 