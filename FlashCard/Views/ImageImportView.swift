import SwiftUI
import PhotosUI
import Vision
#if canImport(Translation)
@preconcurrency import Translation
#endif
import os

struct ImageImportView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var recognizedText = ""
    @State private var isProcessingImage = false
    @State private var extractedWords: [ExtractedWord] = []
    @State private var showingWordSelection = false
    @State private var selectedDeckIds: Set<UUID> = []
    @State private var showingDeckSelection = false
    
    // Translation state (only used on iOS 17.4+)
    @State private var translationConfiguration: Any?
    @State private var wordsToTranslate: [String] = []
    @State private var currentTranslatingWords: Set<String> = []
    
    // Compatibility
    @State private var showingCompatibilityAlert = false
    @State private var compatibilityFeature: UnavailableFeature?
    
    private let logger = Logger(subsystem: "com.flashcards", category: "ImageImportView")
    
    struct ExtractedWord: Identifiable, Hashable {
        let id = UUID()
        let text: String
        let boundingBox: CGRect
        let confidence: Float
        var isSelected: Bool = false
        var isKnownWord: Bool = false
        var suggestedTranslation: String = ""
        var isLoadingTranslation: Bool = false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            UnifiedHeader(
                title: "Import from Image",
                showBackButton: true,
                showProfileIcon: false,
                onBack: { NavigationCoordinator.shared.pop() },
                trailing: showingWordSelection ? 
                    {
                        AnyView(
                            Button("Import") {
                                // Trigger import action
                                importSelectedWords()
                            }
                            .foregroundColor(extractedWords.filter { $0.isSelected }.count > 0 ? .blue : .gray)
                            .disabled(extractedWords.filter { $0.isSelected }.count == 0)
                        )
                    } : nil
            )
            
            VStack(spacing: 20) {
                if selectedImage == nil {
                    // Image selection interface
                    VStack(spacing: 30) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("Import Words from Image")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Take a photo or select an image to extract Dutch words and add them to your flashcards")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            ActionCard(
                                icon: "camera.fill",
                                title: "Take Photo",
                                subtitle: "Capture text with your camera",
                                color: .blue
                            ) {
                                showingCamera = true
                            }
                            
                            ActionCard(
                                icon: "photo.stack.fill",
                                title: "Choose from Photos",
                                subtitle: "Select an existing image",
                                color: .green
                            ) {
                                showingImagePicker = true
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else if isProcessingImage {
                    // Image processing and word selection
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text("Analyzing image...")
                            .font(.headline)
                        
                        Text("Extracting text using OCR")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else if showingWordSelection {
                    WordSelectionView(
                        image: selectedImage!,
                        extractedWords: $extractedWords,
                        selectedDeckIds: $selectedDeckIds,
                        viewModel: viewModel,
                        showToolbar: false
                    ) {
                        NavigationCoordinator.shared.pop()
                    }
                    
                } else {
                    // Show image with overlay
                    VStack(spacing: 16) {
                        Text("Image Captured")
                            .font(.headline)
                        
                        Image(uiImage: selectedImage!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        
                        VStack(spacing: 12) {
                            Button("Extract Text") {
                                processImage()
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            
                            Button("Choose Different Image") {
                                selectedImage = nil
                                extractedWords = []
                                recognizedText = ""
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showingDeckSelection) {
            ImageImportDeckSelectionView(
                selectedDeckIds: $selectedDeckIds,
                viewModel: viewModel
            )
            .onDisappear {
                // Always proceed with import - if no decks selected, use Uncategorized
                let selectedWords = extractedWords.filter { $0.isSelected }
                if selectedWords.isEmpty { return }
                
                // If no decks were selected, find the Uncategorized deck
                if selectedDeckIds.isEmpty {
                    if let uncategorizedDeck = viewModel.decks.first(where: { $0.name == "Uncategorized" }) {
                        selectedDeckIds = [uncategorizedDeck.id]
                    }
                }
                
                // Import the words
                importWordsDirectly(selectedWords)
            }
        }
        .modifier(ImageTranslationTaskModifier(
            translationConfiguration: translationConfiguration,
            wordsToTranslate: wordsToTranslate,
            currentTranslatingWords: currentTranslatingWords,
            extractedWords: $extractedWords,
            onTranslationComplete: { wordIndex, translation in
                if wordIndex < extractedWords.count {
                    extractedWords[wordIndex].suggestedTranslation = translation
                    extractedWords[wordIndex].isLoadingTranslation = false
                }
            },
            onTranslationError: { word in
                // Try fallback translation using TranslationService
                Task {
                    // Check if translation features are available
                    guard BuildConfiguration.isFeatureAvailable(.dutchTranslation) else {
                        await MainActor.run {
                            if let finalIndex = extractedWords.firstIndex(where: { $0.text == word }) {
                                extractedWords[finalIndex].suggestedTranslation = "Translation unavailable in lite version"
                                extractedWords[finalIndex].isLoadingTranslation = false
                                currentTranslatingWords.remove(word)
                            }
                        }
                        return
                    }
                    
                    let fallbackTranslation = await TranslationService.shared.getTranslationWithFallback(for: word)
                    await MainActor.run {
                        if let finalIndex = extractedWords.firstIndex(where: { $0.text == word }) {
                            extractedWords[finalIndex].suggestedTranslation = fallbackTranslation
                            extractedWords[finalIndex].isLoadingTranslation = false
                            currentTranslatingWords.remove(word)
                        }
                    }
                }
            },
            onComplete: {
                wordsToTranslate = []
            }
        ))
        .featureUnavailableAlert(
            isPresented: $showingCompatibilityAlert,
            feature: compatibilityFeature ?? .translation
        )
    }
    
    private func processImage() {
        guard let image = selectedImage else { return }
        
        isProcessingImage = true
        logger.debug("Starting OCR processing for image")
        
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            DispatchQueue.main.async {
                self.handleOCRResults(request: request, error: error)
            }
        }
        
        // Configure based on iOS version
        let ocrConfig = VisionCompatibility.getOCRConfiguration()
        
        if #available(iOS 17.0, *) {
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["nl", "en"]
            request.usesLanguageCorrection = true
        } else if #available(iOS 16.0, *) {
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en"] // More limited on older iOS
            request.usesLanguageCorrection = false
        } else {
            request.recognitionLevel = .fast
            request.recognitionLanguages = ["en"]
            request.usesLanguageCorrection = false
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.logger.error("OCR processing failed: \(error.localizedDescription)")
                    self.isProcessingImage = false
                }
            }
        }
    }
    
    private func handleOCRResults(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation],
              error == nil else {
            logger.error("OCR failed: \(error?.localizedDescription ?? "Unknown error")")
            isProcessingImage = false
            return
        }
        
        var words: [ExtractedWord] = []
        var allText = ""
        
        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            
            allText += topCandidate.string + " "
            
            // Extract individual words
            let wordsInObservation = topCandidate.string.components(separatedBy: .whitespacesAndNewlines)
            
            for word in wordsInObservation {
                let cleanWord = word.trimmingCharacters(in: .punctuationCharacters.union(.whitespacesAndNewlines))
                
                if !cleanWord.isEmpty && cleanWord.count > 2 {
                    let extractedWord = ExtractedWord(
                        text: cleanWord,
                        boundingBox: observation.boundingBox,
                        confidence: topCandidate.confidence,
                        isKnownWord: isKnownWord(cleanWord)
                    )
                    words.append(extractedWord)
                }
            }
        }
        
        recognizedText = allText
        extractedWords = words
        
        logger.debug("OCR completed: found \(words.count) words")
        
        // Auto-fetch translations for unknown words
        fetchTranslationsForUnknownWords()
        
        isProcessingImage = false
        showingWordSelection = true
    }
    
    private func isKnownWord(_ word: String) -> Bool {
        return viewModel.flashCards.contains { existingCard in
            existingCard.word.lowercased() == word.lowercased()
        }
    }
    
    private func fetchTranslationsForUnknownWords() {
        // Check if translation features are available
        guard BuildConfiguration.isFeatureAvailable(.dutchTranslation) else {
            logger.debug("Translation features disabled in lite version")
            return
        }
        
        let unknownWords = extractedWords.filter { !$0.isKnownWord && !$0.isLoadingTranslation }
        
        logger.debug("Fetching translations for \(unknownWords.count) unknown words")
        
        // Check if Translation framework is available
        if CompatibilityHelper.isTranslationFrameworkAvailable {
            // Use Apple's Translation framework on iOS 17.4+
            fetchTranslationsUsingAppleFramework(unknownWords)
        } else {
            // Fallback to local dictionary for older iOS versions
            fetchTranslationsUsingLocalDictionary(unknownWords)
        }
    }
    
    private func fetchTranslationsUsingAppleFramework(_ unknownWords: [ExtractedWord]) {
        // Check if we can use Apple's Translation framework
        guard #available(iOS 18.0, *), CompatibilityHelper.isTranslationFrameworkAvailable else {
            // Fallback to local dictionary
            fetchTranslationsUsingLocalDictionary(unknownWords)
            return
        }
        
        for (index, word) in extractedWords.enumerated() {
            if !word.isKnownWord && !word.isLoadingTranslation {
                extractedWords[index].isLoadingTranslation = true
                currentTranslatingWords.insert(word.text)
            }
        }
        
        // Set up translation configuration
        #if canImport(Translation)
        if #available(iOS 18.0, *) {
            translationConfiguration = TranslationSession.Configuration(
                source: Locale.Language(identifier: "nl"),
                target: Locale.Language(identifier: "en")
            )
        }
        #endif
        
        // Extract unique words to translate
        let uniqueWords = Array(currentTranslatingWords)
        wordsToTranslate = uniqueWords
    }
    
    private func fetchTranslationsUsingLocalDictionary(_ unknownWords: [ExtractedWord]) {
        for (index, word) in extractedWords.enumerated() {
            if !word.isKnownWord && !word.isLoadingTranslation {
                extractedWords[index].isLoadingTranslation = true
                
                // Use local dictionary
                Task {
                    let translation = await TranslationService.shared.getTranslationWithFallback(for: word.text)
                    
                    await MainActor.run {
                        if let wordIndex = self.extractedWords.firstIndex(where: { $0.id == word.id }) {
                            self.extractedWords[wordIndex].suggestedTranslation = translation
                            self.extractedWords[wordIndex].isLoadingTranslation = false
                        }
                    }
                }
            }
        }
    }
    
    private func fetchTranslation(for word: String, completion: @escaping (String) -> Void) {
        // This method is now replaced by translationTask
        // Keeping for backwards compatibility if needed
        Task {
            // Check if translation features are available
            guard BuildConfiguration.isFeatureAvailable(.dutchTranslation) else {
                completion("Translation unavailable in lite version")
                return
            }
            
            let translation = await TranslationService.shared.getTranslationWithFallback(for: word)
            completion(translation)
        }
    }
    
    private func importSelectedWords() {
        let selectedWords = extractedWords.filter { $0.isSelected }
        guard !selectedWords.isEmpty else { return }
        
        // Show deck selection first
        showingDeckSelection = true
    }
    
    private func importWordsDirectly(_ selectedWords: [ExtractedWord]) {
        var importedCount = 0
        for word in selectedWords {
            if !word.suggestedTranslation.isEmpty {
                let _ = viewModel.addCard(
                    word: word.text,
                    definition: word.suggestedTranslation,
                    example: "",
                    deckIds: selectedDeckIds
                )
                importedCount += 1
            }
        }
        
        logger.debug("Imported \(importedCount) words directly")
        
        // Show success notification
        if importedCount > 0 {
            NotificationManager.shared.showNotification(
                AppNotification(
                    type: .info,
                    title: "📸 Image Import Successful",
                    message: "Imported \(importedCount) word\(importedCount == 1 ? "" : "s") from your image",
                    duration: 4.0
                )
            )
        }
        
        // Go back to main view after import
        NavigationCoordinator.shared.pop()
    }
}

struct ActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Supporting Views

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }
            
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.selectedImage = image as? UIImage
                }
            }
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    ImageImportView(viewModel: FlashCardViewModel())
}

// MARK: - Image Translation Task Modifier

struct ImageTranslationTaskModifier: ViewModifier {
    let translationConfiguration: Any?
    let wordsToTranslate: [String]
    let currentTranslatingWords: Set<String>
    @Binding var extractedWords: [ImageImportView.ExtractedWord]
    let onTranslationComplete: (Int, String) -> Void
    let onTranslationError: (String) -> Void
    let onComplete: () -> Void
    
    func body(content: Content) -> some View {
        if #available(iOS 18.0, *), CompatibilityHelper.isTranslationFrameworkAvailable {
            #if canImport(Translation)
            if let translationConfiguration = translationConfiguration,
               let config = translationConfiguration as? TranslationSession.Configuration {
                content.translationTask(config) { session in
                    guard !wordsToTranslate.isEmpty else { return }
                    
                    for word in wordsToTranslate {
                        guard currentTranslatingWords.contains(word) else { continue }
                        
                        do {
                            let response = try await session.translate(word)
                            
                            await MainActor.run {
                                if let wordIndex = extractedWords.firstIndex(where: { $0.text == word }) {
                                    onTranslationComplete(wordIndex, response.targetText)
                                }
                            }
                        } catch {
                            await MainActor.run {
                                onTranslationError(word)
                            }
                        }
                    }
                    
                    // Clear the translation queue
                    await MainActor.run {
                        onComplete()
                    }
                }
            } else {
                content
            }
            #else
            content
            #endif
        } else {
            content
        }
    }
} 