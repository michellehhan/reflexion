import SwiftUI
import PDFKit
import NaturalLanguage

struct OCRResultView: View {
    @State var recognizedText: String
    @State private var isCopied = false
    
    @ObservedObject var journalManager = JournalDatabaseManager.shared
    @State private var showSuccessMessage = false
    @State private var isSaving = false
    @State private var selectedMood: String? = nil 
    @State private var isAIProcessingMood = false 
    private let availableMoods = ["Joyful 😊", "Calm 🌿", "Energetic ⚡", "Stressed 😖", "Sad 😞", "Reflective 🤔"]


    var body: some View {
        ScrollView{
            VStack(spacing: 20) {
                Text("Extracted Text")
                    .font(.title)
                    .bold()
                    .padding(.top, 10)
                
                // Text Display Box
                ScrollView {
                    Text(recognizedText)
                        .font(.system(size: 18))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                }
                .frame(maxHeight: 400) 
                .padding(.horizontal)
                
                VStack {
                    Text("Select Mood")
                        .font(.headline)
                    
                    HStack {
                        ForEach(availableMoods, id: \.self) { mood in
                            Button(action: { selectedMood = mood }) {
                                Text(mood)
                                    .padding(8)
                                    .background(selectedMood == mood ? Color.blue.opacity(0.2) : Color.gray.opacity(0.3))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                if isAIProcessingMood {
                    ProgressView("Detecting mood...")
                }
                
                Button(action: saveToDatabase) {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        Text("  Add Entry to Journal")
                            .bold()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isSaving ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isSaving)
                .padding(.top)
                
                Spacer()
                // Action Buttons
                HStack(spacing: 16) {
                    // Copy to Clipboard
                    Button(action: {
                        UIPasteboard.general.string = recognizedText
                        isCopied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isCopied = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text(isCopied ? "Copied!" : "Copy Text")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    // Edit Extracted Text
                    NavigationLink(destination: EditableOCRView(text: $recognizedText)) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                Spacer().frame(height: 50)
            }
            .padding()
            }
            .padding()
            .navigationTitle("OCR Result")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                detectAIMood()
            }
            .alert(isPresented: $showSuccessMessage) { 
                Alert(
                    title: Text("Saved!"),
                    message: Text("Your journal entry has been saved."),
                    dismissButton: .default(Text("OK"))
                )
            }
        
    }
    
    private func detectAIMood() {
        isAIProcessingMood = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let tagger = NLTagger(tagSchemes: [.sentimentScore])
            tagger.string = recognizedText
            
            let (sentiment, _) = tagger.tag(at: recognizedText.startIndex, unit: .paragraph, scheme: .sentimentScore)
            let score = Double(sentiment?.rawValue ?? "0") ?? 0
            
            let detectedMood = self.mapSentimentToMood(score)
            
            DispatchQueue.main.async {
                self.selectedMood = detectedMood 
                self.isAIProcessingMood = false
            }
        }
    }
    
    private func mapSentimentToMood(_ score: Double) -> String {
        switch score {
        case 0.6...:
            return "Joyful 😊"
        case 0.3..<0.6:
            return "Calm 🌿"
        case 0.1..<0.3:
            return "Energetic ⚡"
        case -0.1..<0.1:
            return "Reflective 🤔"
        case -0.3..<(-0.1):
            return "Sad 😞"
        default:
            return "Stressed 😖"
        }
    }

    
private func saveToDatabase() {
    guard let mood = selectedMood else { return } 
    isSaving = true 
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        let entry = JournalEntry(
            id: UUID(),
            date: Date(),
            type: .ocr, 
            content: recognizedText,
            fileURL: nil, 
            emotionTag: mood
        )
        
        journalManager.saveJournalEntry(entry: entry) 
        journalManager.fetchAndUpdateEntries() 
        
        isSaving = false
        showSuccessMessage = true 
            }
}
}


struct OCRResultView_Previews: PreviewProvider {
    static var previews: some View {
        OCRResultView(recognizedText: "Sample extracted text from an image.")
    }
}
