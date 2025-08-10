import SwiftUI
import UniformTypeIdentifiers

struct ImportWordExercisesView: View {
    @ObservedObject var wordExerciseManager = DutchWordExerciseManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingFilePicker = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingSuccess = false
    @State private var importedCount = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Text("Import Word Exercises")
                            .font(.headline)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Divider()
                }
                .background(Color(.systemGroupedBackground))
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Import Instructions
                        importInstructionsSection
                        
                        // Supported Formats
                        supportedFormatsSection
                        
                        // Import Button
                        importButton
                        
                        // Example JSON
                        exampleJSONSection
                    }
                    .padding()
                }
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [UTType.json, UTType.data],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
        .alert("Import Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Import Successful", isPresented: $showingSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Successfully imported \(importedCount) word exercises.")
        }
    }
    
    // MARK: - Import Instructions Section
    
    private var importInstructionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Import Instructions")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                ImportInstructionRow(
                    number: "1",
                    text: "Prepare your word exercises in JSON format"
                )
                
                ImportInstructionRow(
                    number: "2",
                    text: "Ensure the file contains valid exercise data"
                )
                
                ImportInstructionRow(
                    number: "3",
                    text: "Tap 'Choose File' to select your file"
                )
                
                ImportInstructionRow(
                    number: "4",
                    text: "Review and confirm the import"
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Supported Formats Section
    
    private var supportedFormatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Supported Formats")
                .font(.headline)
            
            VStack(spacing: 12) {
                FormatCard(
                    format: "JSON",
                    description: "JavaScript Object Notation - Most flexible format",
                    icon: "doc.text",
                    isSupported: true
                )
                
                FormatCard(
                    format: "Excel (Coming Soon)",
                    description: "Microsoft Excel files - .xlsx and .xls",
                    icon: "tablecells",
                    isSupported: false
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Import Button
    
    private var importButton: some View {
        Button(action: { showingFilePicker = true }) {
            HStack {
                Image(systemName: "square.and.arrow.down")
                Text("Choose File")
            }
            .font(.subheadline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.blue)
            .cornerRadius(8)
        }
        .disabled(wordExerciseManager.isLoading)
    }
    
    // MARK: - Example JSON Section
    
    private var exampleJSONSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Example JSON Format")
                .font(.headline)
            
            ScrollView {
                Text(exampleJSON)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(8)
            }
            .frame(maxHeight: 200)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - File Import Handling
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                errorMessage = "No file selected"
                showingError = true
                return
            }
            
            Task {
                do {
                    try await wordExerciseManager.importWordExercises(from: url)
                    
                    // Count newly imported exercises
                    let stats = wordExerciseManager.getStatistics()
                    importedCount = stats.imported
                    
                    await MainActor.run {
                        showingSuccess = true
                    }
                } catch {
                    await MainActor.run {
                        errorMessage = error.localizedDescription
                        showingError = true
                    }
                }
            }
            
        case .failure(let error):
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    // MARK: - Example JSON
    
    private var exampleJSON: String {
        """
        {
          "exercises": [
            {
              "targetWord": "terecht",
              "wordTranslation": "justified",
              "exercises": [
                {
                  "type": "fillInBlank",
                  "prompt": "De straf was _____ voor wat hij had gedaan.",
                  "options": ["terecht", "onterecht", "recht", "rechtstreeks"],
                  "correctAnswer": "terecht",
                  "explanation": "'Terecht' means 'justified' or 'deserved'.",
                  "hint": "Think about whether the punishment was deserved",
                  "difficulty": "medium"
                }
              ],
              "difficulty": "medium",
              "category": "general"
            }
          ],
          "metadata": {
            "source": "Custom Import",
            "version": "1.0",
            "importedAt": "2024-01-01T00:00:00Z",
            "totalExercises": 1,
            "categories": ["general"]
          }
        }
        """
    }
}

// MARK: - Supporting Views

struct ImportInstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct FormatCard: View {
    let format: String
    let description: String
    let icon: String
    let isSupported: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isSupported ? .blue : .secondary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(format)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if !isSupported {
                        Text("Coming Soon")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(8)
        .opacity(isSupported ? 1.0 : 0.6)
    }
}

#Preview {
    ImportWordExercisesView()
} 