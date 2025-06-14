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
    @State private var selectedExportOption: ExportOption = .allCards
    @State private var showingSimulatorAlert = false
    @State private var selectedDeckIds: Set<UUID> = []
    @State private var showingMultiDeckSelection = false

    
    enum ExportOption: Hashable, Equatable {
        case allCards
        case specificDeck(Deck)
        case multipleDecks
        
        var title: String {
            switch self {
            case .allCards:
                return "All Cards"
            case .specificDeck(let deck):
                return deck.name
            case .multipleDecks:
                return "Multiple Decks"
            }
        }
        
        // Implement Hashable
        func hash(into hasher: inout Hasher) {
            switch self {
            case .allCards:
                hasher.combine("allCards")
            case .specificDeck(let deck):
                hasher.combine("specificDeck")
                hasher.combine(deck.id)
            case .multipleDecks:
                hasher.combine("multipleDecks")
            }
        }
        
        // Implement Equatable
        static func == (lhs: ExportOption, rhs: ExportOption) -> Bool {
            switch (lhs, rhs) {
            case (.allCards, .allCards):
                return true
            case (.specificDeck(let deck1), .specificDeck(let deck2)):
                return deck1.id == deck2.id
            case (.multipleDecks, .multipleDecks):
                return true
            default:
                return false
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
                            Text("All Cards (\(viewModel.flashCards.count) cards)").tag(ExportOption.allCards)
                            
                            Text("Multiple Decks (Select...)").tag(ExportOption.multipleDecks)
                            
                            ForEach(viewModel.getAllDecksHierarchical()) { deck in
                                if deck.name != "Uncategorized" {
                                    let cardCount = viewModel.getTotalCardsInDeckHierarchy(deck)
                                    let displayName = deck.isSubDeck ? "    ↳ \(deck.name)" : deck.name
                                    Text("\(displayName) (\(cardCount) cards)")
                                        .tag(ExportOption.specificDeck(deck))
                                }
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        // Multi-deck selection button
                        if selectedExportOption == .multipleDecks {
                            Button(action: {
                                showingMultiDeckSelection = true
                            }) {
                                HStack {
                                    Image(systemName: "checkmark.square")
                                    if selectedDeckIds.isEmpty {
                                        Text("Select Decks to Export")
                                    } else {
                                        Text("\(selectedDeckIds.count) Decks Selected")
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .foregroundColor(.blue)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
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
                        .disabled(viewModel.flashCards.isEmpty || 
                                 (selectedExportOption == .multipleDecks && selectedDeckIds.isEmpty))
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
            .sheet(isPresented: $showingMultiDeckSelection) {
                MultiDeckSelectionView(
                    viewModel: viewModel,
                    selectedDeckIds: $selectedDeckIds
                )
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
        
        switch selectedExportOption {
        case .allCards:
            print("🔍 UI Export Debug: Exporting all cards")
            exportContent = viewModel.exportCardsToCSV()
        case .specificDeck(let deck):
            print("🔍 UI Export Debug: Exporting deck: \(deck.name)")
            exportContent = viewModel.exportDeckToCSV(deck)
        case .multipleDecks:
            print("🔍 UI Export Debug: Exporting multiple decks: \(selectedDeckIds.count) selected")
            exportContent = viewModel.exportMultipleDecksToCSV(selectedDeckIds)
        }
        
        print("🔍 UI Export Debug: Export content length: \(exportContent.count)")
        print("🔍 UI Export Debug: Export content preview: \(String(exportContent.prefix(200)))")
        
        #if targetEnvironment(simulator)
        // In simulator, just show the content and inform user
        print("=== CSV Export Content ===")
        print(exportContent)
        print("=== End CSV Content ===")
        showingSimulatorAlert = true
        #else
        // On real device, show the share sheet
        showingExportSheet = true
        #endif
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
            // Create temporary file
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("FlashCards_Export_\(DateFormatter.filenameFriendly.string(from: Date())).csv")
            
            do {
                try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
                itemsToShare.append(tempURL)
            } catch {
                print("Failed to create temporary file: \(error)")
                // Fallback to sharing the string directly
                itemsToShare.append(csvString)
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
        
        // For iPad - prevent crash by setting source
        if let popover = controller.popoverPresentationController {
            popover.sourceView = UIApplication.shared.windows.first?.rootViewController?.view
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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

// MARK: - Multi-Deck Selection View

struct MultiDeckSelectionView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Binding var selectedDeckIds: Set<UUID>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Select Decks to Export")) {
                    ForEach(viewModel.getAllDecksHierarchical()) { deck in
                        if deck.name != "Uncategorized" {
                            Button(action: {
                                if selectedDeckIds.contains(deck.id) {
                                    selectedDeckIds.remove(deck.id)
                                } else {
                                    selectedDeckIds.insert(deck.id)
                                }
                            }) {
                                HStack {
                                    if deck.isSubDeck {
                                        HStack(spacing: 4) {
                                            Text("    ↳")
                                                .foregroundColor(.secondary)
                                            Text(deck.name)
                                        }
                                    } else {
                                        Text(deck.name)
                                    }
                                    
                                    Spacer()
                                    
                                    let cardCount = viewModel.getTotalCardsInDeckHierarchy(deck)
                                    Text("\(cardCount) cards")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    if selectedDeckIds.contains(deck.id) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
                
                if !selectedDeckIds.isEmpty {
                    Section {
                        let totalCards = selectedDeckIds.reduce(0) { total, deckId in
                            if let deck = viewModel.decks.first(where: { $0.id == deckId }) {
                                return total + viewModel.getTotalCardsInDeckHierarchy(deck)
                            }
                            return total
                        }
                        
                        HStack {
                            Text("Total cards to export:")
                            Spacer()
                            Text("\(totalCards)")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Select Decks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
} 