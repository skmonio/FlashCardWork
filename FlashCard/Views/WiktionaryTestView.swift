import SwiftUI

struct WiktionaryTestView: View {
    @State private var searchWord: String = ""
    @State private var isLoading: Bool = false
    @State private var result: WiktionaryWordInfo?
    @State private var errorMessage: String?
    
    private let wiktionaryService = WiktionaryService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Test Dutch Word:")
                        .font(.headline)
                    
                    HStack {
                        TextField("Enter Dutch word (e.g., eten, huis)", text: $searchWord)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Search") {
                            searchWiktionary()
                        }
                        .disabled(searchWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                    }
                }
                
                if isLoading {
                    ProgressView("Searching Wiktionary...")
                        .padding()
                }
                
                if let error = errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                }
                
                if let wordInfo = result {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Word: \(wordInfo.word)")
                                    .font(.title2)
                                    .bold()
                                
                                Text("Translation: \(wordInfo.translation)")
                                    .font(.title3)
                                
                                Text("Type: \(wordInfo.wordType.rawValue.capitalized)")
                                    .font(.body)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            
                            if wordInfo.article != nil || wordInfo.plural != nil ||
                               wordInfo.pastTense != nil || wordInfo.pastParticiple != nil {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Grammar Information:")
                                        .font(.headline)
                                    
                                    if let article = wordInfo.article {
                                        HStack {
                                            Text("Article:")
                                                .bold()
                                            Text(article)
                                        }
                                    }
                                    
                                    if let plural = wordInfo.plural {
                                        HStack {
                                            Text("Plural:")
                                                .bold()
                                            Text(plural)
                                        }
                                    }
                                    
                                    if let pastTense = wordInfo.pastTense {
                                        HStack {
                                            Text("Past Tense:")
                                                .bold()
                                            Text(pastTense)
                                        }
                                    }
                                    
                                    if let futureTense = wordInfo.futureTense {
                                        HStack {
                                            Text("Future Tense:")
                                                .bold()
                                            Text(futureTense)
                                        }
                                    }
                                    
                                    if let pastParticiple = wordInfo.pastParticiple {
                                        HStack {
                                            Text("Past Participle:")
                                                .bold()
                                            Text(pastParticiple)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            
                            if !wordInfo.examples.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Examples:")
                                        .font(.headline)
                                    
                                    ForEach(wordInfo.examples.indices, id: \.self) { index in
                                        Text("• \(wordInfo.examples[index])")
                                            .italic()
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            
                            if let pronunciation = wordInfo.pronunciation {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Pronunciation:")
                                        .font(.headline)
                                    Text(pronunciation)
                                        .font(.body)
                                        .fontDesign(.monospaced)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                    }
                } else if !isLoading && !searchWord.isEmpty {
                    Text("Try searching for a Dutch word")
                        .foregroundColor(.secondary)
                        .italic()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Wiktionary Test")
        }
    }
    
    private func searchWiktionary() {
        let word = searchWord.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !word.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        result = nil
        
        wiktionaryService.fetchWordInfo(for: word) { result in
            self.isLoading = false
            
            switch result {
            case .success(let wordInfo):
                self.result = wordInfo
                if wordInfo == nil {
                    self.errorMessage = "No information found for '\(word)'"
                }
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    WiktionaryTestView()
} 