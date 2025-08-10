import SwiftUI
import UniformTypeIdentifiers

struct ExportWordExercisesView: View {
    @ObservedObject var wordExerciseManager = DutchWordExerciseManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingFileExporter = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingSuccess = false
    @State private var exportData: Data?
    @State private var selectedExercises: Set<UUID> = []
    @State private var exportAll = true
    
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
                        
                        Text("Export Word Exercises")
                            .font(.headline)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Divider()
                }
                .background(Color(.systemGroupedBackground))
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Export Options
                        exportOptionsSection
                        
                        // Exercise Selection
                        if !exportAll {
                            exerciseSelectionSection
                        }
                        
                        // Export Button
                        exportButton
                        
                        // Export Information
                        exportInformationSection
                    }
                    .padding()
                }
            }
        }
        .fileExporter(
            isPresented: $showingFileExporter,
            document: WordExerciseDocument(data: exportData ?? Data()),
            contentType: .json,
            defaultFilename: "dutch_word_exercises.json"
        ) { result in
            handleFileExport(result)
        }
        .alert("Export Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Export Successful", isPresented: $showingSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Word exercises exported successfully.")
        }
    }
    
    // MARK: - Export Options Section
    
    private var exportOptionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Export Options")
                .font(.headline)
            
            VStack(spacing: 12) {
                // Export All Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Export All Exercises")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("Include all word exercises in the export")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $exportAll)
                        .labelsHidden()
                }
                .padding()
                .background(Color(.tertiarySystemGroupedBackground))
                .cornerRadius(8)
                
                if !exportAll {
                    // Export Selection Info
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        
                        Text("Select specific exercises to export")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Exercise Selection Section
    
    private var exerciseSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Select Exercises")
                    .font(.headline)
                
                Spacer()
                
                Button("Select All") {
                    selectedExercises = Set(wordExerciseManager.wordExercises.map { $0.id })
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(wordExerciseManager.wordExercises) { exercise in
                    ExerciseSelectionRow(
                        exercise: exercise,
                        isSelected: selectedExercises.contains(exercise.id)
                    ) {
                        if selectedExercises.contains(exercise.id) {
                            selectedExercises.remove(exercise.id)
                        } else {
                            selectedExercises.insert(exercise.id)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Export Button
    
    private var exportButton: some View {
        VStack(spacing: 12) {
            Button(action: prepareExport) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export to JSON")
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(canExport ? Color.blue : Color.gray)
                .cornerRadius(8)
            }
            .disabled(!canExport || wordExerciseManager.isLoading)
            
            if wordExerciseManager.isLoading {
                ProgressView("Preparing export...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Export Information Section
    
    private var exportInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Export Information")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                ExportInfoRow(
                    icon: "doc.text",
                    title: "Format",
                    value: "JSON (JavaScript Object Notation)"
                )
                
                ExportInfoRow(
                    icon: "number",
                    title: "Exercises to Export",
                    value: "\(exercisesToExport.count) word exercises"
                )
                
                ExportInfoRow(
                    icon: "questionmark.circle",
                    title: "Total Questions",
                    value: "\(totalQuestionsToExport) questions"
                )
                
                ExportInfoRow(
                    icon: "calendar",
                    title: "Export Date",
                    value: DateFormatter.exportDateFormatter.string(from: Date())
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Computed Properties
    
    private var canExport: Bool {
        if exportAll {
            return !wordExerciseManager.wordExercises.isEmpty
        } else {
            return !selectedExercises.isEmpty
        }
    }
    
    private var exercisesToExport: [DutchWordExercise] {
        if exportAll {
            return wordExerciseManager.wordExercises
        } else {
            return wordExerciseManager.wordExercises.filter { selectedExercises.contains($0.id) }
        }
    }
    
    private var totalQuestionsToExport: Int {
        exercisesToExport.reduce(0) { $0 + $1.exercises.count }
    }
    
    // MARK: - Export Functions
    
    private func prepareExport() {
        Task {
            do {
                let exportData = try await wordExerciseManager.exportWordExercises(to: URL(fileURLWithPath: "/tmp/temp_export.json"))
                
                await MainActor.run {
                    self.exportData = exportData
                    showingFileExporter = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func handleFileExport(_ result: Result<URL, Error>) {
        switch result {
        case .success:
            showingSuccess = true
        case .failure(let error):
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

// MARK: - Supporting Views

struct ExerciseSelectionRow: View {
    let exercise: DutchWordExercise
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .secondary)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.targetWord)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(exercise.wordTranslation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(exercise.exercises.count)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                    
                    Text("exercises")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.tertiarySystemGroupedBackground))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ExportInfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Document for File Export

struct WordExerciseDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        data = Data()
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}

// MARK: - Date Formatter Extension

extension DateFormatter {
    static let exportDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    ExportWordExercisesView()
} 