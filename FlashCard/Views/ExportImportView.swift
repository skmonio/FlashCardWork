import SwiftUI
import UniformTypeIdentifiers

struct ExportImportView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingExportSheet = false
    @State private var showingImportPicker = false
    @State private var showingImportAlert = false
    @State private var importResult: (success: Int, errors: [String]) = (0, [])
    @State private var exportContent = ""
    @State private var selectedExportOption: ExportOption = .multipleDecks
    @State private var showingSimulatorAlert = false
    @State private var selectedDeckIds: Set<UUID> = []
    @State private var showingDeckSelection = false
    @State private var showingExportError = false
    @State private var exportErrorMessage = ""

    
    enum ExportOption: Hashable, Equatable {
        case multipleDecks
        
        var title: String {
            switch self {
            case .multipleDecks:
                return "Select Specific Decks"
            }
        }
        
        // Implement Hashable
        func hash(into hasher: inout Hasher) {
            switch self {
            case .multipleDecks:
                hasher.combine("multipleDecks")
            }
        }
        
        // Implement Equatable
        static func == (lhs: ExportOption, rhs: ExportOption) -> Bool {
            switch (lhs, rhs) {
            case (.multipleDecks, .multipleDecks):
                return true
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Export")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Export your flashcards to CSV format")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Picker("Export Options", selection: $selectedExportOption) {
                            Text("Select Specific Decks").tag(ExportOption.multipleDecks)
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        // Deck selection using the same component as game selection
                        if selectedExportOption == .multipleDecks {
                            DeckDropdownChecklist(
                                viewModel: viewModel,
                                selectedDeckIds: $selectedDeckIds
                            )
                        }
                        
                        Button(action: {
                            exportToCSV()
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                #if targetEnvironment(simulator)
                                Text("Export to CSV (Limited in Simulator)")
                                #else
                                Text("Export to CSV")
                                #endif
                            }
                            .foregroundColor(.blue)
                        }
                        .disabled(selectedDeckIds.isEmpty)
                    }
                }
                
                Section(header: Text("Import"), footer: Text("Import CSV files with columns: Word, Definition, Example, Article, Past Tense, Future Tense, Decks, Success Count, Times Shown, Times Correct")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Import flashcards from CSV format")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            showingImportPicker = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("Import from CSV")
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                
                Section(header: Text("CSV Format")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CSV Structure")
                            .font(.subheadline)
                            .bold()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach([
                                "Word (required)",
                                "Definition (required)", 
                                "Example (optional)",
                                "Article (optional: de/het)",
                                "Past Tense (optional)",
                                "Future Tense (optional)",
                                "Decks (optional: separated by ;)",
                                "Success Count (optional)",
                                "Times Shown (optional)",
                                "Times Correct (optional)"
                            ], id: \.self) { field in
                                Text("• \(field)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Text("Example")
                            .font(.subheadline)
                            .bold()
                            .padding(.top, 8)
                        
                        Text("""
                        Word,Definition,Example,Article,Past Tense,Future Tense,Decks,Success Count,Times Shown,Times Correct
                        Hallo,Hello,"Hallo, hoe gaat het?",,,,"A1 - Basics",5,10,8
                        Brood,Bread,"Ik eet brood met kaas",het,,,"A1 - Food & Drinks; Basics",3,5,3
                        """)
                            .font(.caption)
                            .modifier(MonospacedFontModifier())
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("Export & Import")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                ShareSheet(activityItems: [exportContent])
            }
            .fileImporter(
                isPresented: $showingImportPicker,
                allowedContentTypes: [
                    UTType.commaSeparatedText,
                    UTType.plainText,
                    UTType.text,
                    UTType.data
                ],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result: result)
            }
            .alert("Import Results", isPresented: $showingImportAlert) {
                Button("OK") { }
            } message: {
                Text(importAlertMessage)
            }
            .alert("Simulator Limitation", isPresented: $showingSimulatorAlert) {
                Button("OK") { }
            } message: {
                Text("File sharing is limited in iOS Simulator. The CSV content has been printed to the console. On a real device, you would be able to save or share the file normally.")
            }
            .alert("Export Error", isPresented: $showingExportError) {
                Button("OK") { }
            } message: {
                Text(exportErrorMessage)
            }
        }
    }
    
    private var importAlertMessage: String {
        var message = "Successfully imported \(importResult.success) cards."
        
        if !importResult.errors.isEmpty {
            message += "\n\nErrors encountered:"
            for error in importResult.errors.prefix(5) {
                message += "\n• \(error)"
            }
            
            if importResult.errors.count > 5 {
                message += "\n... and \(importResult.errors.count - 5) more errors"
            }
        }
        
        return message
    }
    
    private func exportToCSV() {
        print("🔍 UI Export Debug: Starting export with option: \(selectedExportOption)")
        
        // Test Documents directory access first
        guard testDocumentsDirectoryAccess() else {
            print("❌ Documents directory access test failed")
            exportErrorMessage = "Unable to access app's Documents directory. Please check app permissions and try again."
            showingExportError = true
            return
        }
        
        // Validate that we have selected decks
        guard !selectedDeckIds.isEmpty else {
            print("❌ No decks selected for export")
            exportErrorMessage = "Please select at least one deck to export."
            showingExportError = true
            return
        }
        
        // Calculate total cards in selected decks (including hierarchy)
        let totalCards = selectedDeckIds.reduce(0) { total, deckId in
            if let deck = viewModel.decks.first(where: { $0.id == deckId }) {
                return total + viewModel.getTotalCardsInDeckHierarchy(deck)
            }
            return total
        }
        
        print("📊 Exporting \(totalCards) cards from \(selectedDeckIds.count) selected decks")
        
        // Check if any cards will be exported
        if totalCards == 0 {
            print("❌ No cards found in selected decks")
            exportErrorMessage = "No cards found in the selected decks. Please ensure the decks contain cards before exporting."
            showingExportError = true
            return
        }
        
        // Generate CSV content
        print("🔍 UI Export Debug: Exporting multiple decks: \(selectedDeckIds.count) selected")
        exportContent = viewModel.exportMultipleDecksToCSV(selectedDeckIds)
        
        // Validate CSV content
        guard !exportContent.isEmpty else {
            print("❌ Export failed: CSV content is empty")
            exportErrorMessage = "Failed to generate CSV content. The export data appears to be empty. This might happen if the selected decks don't contain any cards."
            showingExportError = true
            return
        }
        
        guard exportContent.count > 100 else { // Minimum reasonable size for CSV with headers
            print("❌ Export failed: CSV content too small (\(exportContent.count) characters)")
            exportErrorMessage = "Export data is too small (\(exportContent.count) characters). This may indicate that the selected decks are empty or there's an issue with the export process."
            showingExportError = true
            return
        }
        
        print("✅ CSV generated successfully: \(exportContent.count) characters")
        print("🔍 UI Export Debug: Export content preview: \(String(exportContent.prefix(200)))")
        
        // Validate CSV structure
        let lines = exportContent.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        guard lines.count >= 2 else { // At least header + 1 data row
            print("❌ Export failed: Invalid CSV structure (only \(lines.count) lines)")
            exportErrorMessage = "Invalid CSV structure detected. Expected at least 2 lines but found \(lines.count). This suggests the selected decks may be empty."
            showingExportError = true
            return
        }
        
        print("📝 CSV structure valid: \(lines.count) lines (including header)")
        
        #if targetEnvironment(simulator)
        // In simulator, just show the content and inform user
        print("=== CSV Export Content ===")
        print(exportContent)
        print("=== End CSV Content ===")
        showingSimulatorAlert = true
        #else
        // On real device, show the share sheet
        print("📱 Showing share sheet on real device")
        showingExportSheet = true
        #endif
    }
    
    // Test function to verify Documents directory access
    private func testDocumentsDirectoryAccess() -> Bool {
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            print("📁 Documents directory: \(documentsPath.path)")
            
            // Test if we can write to the Documents directory
            let testFile = documentsPath.appendingPathComponent("test_export_access.txt")
            let testContent = "Test file for export access verification"
            
            try testContent.write(to: testFile, atomically: true, encoding: .utf8)
            print("✅ Test file created successfully")
            
            // Verify the file exists and can be read
            let readContent = try String(contentsOf: testFile, encoding: .utf8)
            guard readContent == testContent else {
                print("❌ Test file content mismatch")
                return false
            }
            
            // Clean up test file
            try FileManager.default.removeItem(at: testFile)
            print("✅ Documents directory access test passed")
            return true
            
        } catch {
            print("❌ Documents directory access test failed: \(error.localizedDescription)")
            return false
        }
    }
    
    private func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { 
                importResult = (0, ["No file selected"])
                showingImportAlert = true
                return 
            }
            
            // Start accessing security-scoped resource
            let accessing = url.startAccessingSecurityScopedResource()
            defer {
                if accessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            do {
                let csvContent = try String(contentsOf: url, encoding: .utf8)
                importResult = viewModel.importCardsFromCSV(csvContent)
                showingImportAlert = true
            } catch {
                importResult = (0, ["Failed to read file: \(error.localizedDescription). Make sure the file is a valid text file and you have permission to access it."])
                showingImportAlert = true
            }
            
        case .failure(let error):
            importResult = (0, ["Import failed: \(error.localizedDescription)"])
            showingImportAlert = true
        }
    }
}

// Helper struct for sharing functionality
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        var itemsToShare: [Any] = []
        
        // Handle CSV string export
        if let csvString = activityItems.first as? String {
            // Try multiple approaches for sharing
            var fileCreated = false
            
            // Approach 1: Use app's Documents directory
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let exportURL = documentsPath.appendingPathComponent("FlashCards_Export_\(DateFormatter.filenameFriendly.string(from: Date())).csv")
            
            do {
                // Ensure the file doesn't already exist
                if FileManager.default.fileExists(atPath: exportURL.path) {
                    try FileManager.default.removeItem(at: exportURL)
                }
                
                // Write the CSV content to the file
                try csvString.write(to: exportURL, atomically: true, encoding: .utf8)
                
                // Verify the file was created successfully
                if FileManager.default.fileExists(atPath: exportURL.path) {
                    print("✅ Export file created successfully at: \(exportURL.path)")
                    itemsToShare.append(exportURL)
                    fileCreated = true
                } else {
                    print("❌ Export file was not created")
                }
            } catch {
                print("❌ Failed to create export file in Documents: \(error.localizedDescription)")
            }
            
            // Approach 2: Try temporary directory as fallback
            if !fileCreated {
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("FlashCards_Export_\(DateFormatter.filenameFriendly.string(from: Date())).csv")
                
                do {
                    try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
                    if FileManager.default.fileExists(atPath: tempURL.path) {
                        print("✅ Fallback: Export file created in temp directory: \(tempURL.path)")
                        itemsToShare.append(tempURL)
                        fileCreated = true
                    }
                } catch {
                    print("❌ Failed to create export file in temp directory: \(error.localizedDescription)")
                }
            }
            
            // Approach 3: Share as plain text if file creation fails
            if !fileCreated {
                print("📝 Fallback: Sharing CSV content as plain text")
                itemsToShare.append(csvString)
                
                // Also create a custom activity item that provides better metadata
                let csvItem = CSVActivityItem(csvContent: csvString)
                itemsToShare.append(csvItem)
            }
        } else {
            itemsToShare = activityItems
        }
        
        let controller = UIActivityViewController(
            activityItems: itemsToShare,
            applicationActivities: nil
        )
        
        // Set subject for email sharing
        controller.setValue("FlashCards Export", forKey: "subject")
        
        // Exclude some activities that don't make sense for CSV files
        controller.excludedActivityTypes = [
            .postToFacebook,
            .postToTwitter,
            .postToWeibo,
            .postToVimeo,
            .postToTencentWeibo,
            .postToFlickr,
            .assignToContact,
            .saveToCameraRoll,
            .addToReadingList,
            .markupAsPDF
        ]
        
        // For iPad - prevent crash by setting source
        if let popover = controller.popoverPresentationController {
            // Try to get the current window's root view controller
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                popover.sourceView = rootViewController.view
            } else {
                // Fallback for older iOS versions
                if let window = UIApplication.shared.windows.first {
                    popover.sourceView = window.rootViewController?.view
                }
            }
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        // Add completion handler to clean up temporary files
        controller.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if let error = error {
                print("❌ Share sheet error: \(error.localizedDescription)")
            } else if completed {
                print("✅ Export completed successfully")
            } else {
                print("📝 Export was cancelled by user")
            }
            
            // Clean up the temporary export file after sharing
            if let csvString = activityItems.first as? String {
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                
                // Clean up any export files older than 1 hour to prevent accumulation
                cleanupOldExportFiles(in: documentsPath)
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    
    // Helper function to clean up old export files
    private func cleanupOldExportFiles(in directory: URL) {
        do {
            let fileManager = FileManager.default
            let files = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.creationDateKey], options: [])
            
            let exportFiles = files.filter { $0.lastPathComponent.hasPrefix("FlashCards_Export_") && $0.pathExtension == "csv" }
            let oneHourAgo = Date().addingTimeInterval(-3600) // 1 hour ago
            
            for file in exportFiles {
                if let creationDate = try? file.resourceValues(forKeys: [.creationDateKey]).creationDate,
                   creationDate < oneHourAgo {
                    try fileManager.removeItem(at: file)
                    print("🧹 Cleaned up old export file: \(file.lastPathComponent)")
                }
            }
        } catch {
            print("⚠️ Failed to clean up old export files: \(error.localizedDescription)")
        }
    }
}

// Custom activity item for CSV content
class CSVActivityItem: NSObject, UIActivityItemSource {
    private let csvContent: String
    
    init(csvContent: String) {
        self.csvContent = csvContent
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return csvContent
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return csvContent
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "FlashCards Export"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "public.comma-separated-values-text"
    }
}

// Extension for filename-friendly date formatting
extension DateFormatter {
    static let filenameFriendly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }()
}

// MARK: - iOS 16.0 Compatibility
struct MonospacedFontModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.1, *) {
            content.fontDesign(.monospaced)
        } else {
            content.font(.system(.caption, design: .monospaced))
        }
    }
}

struct ExportImportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportImportView(viewModel: FlashCardViewModel())
    }
} 