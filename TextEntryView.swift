import SwiftUI
import NaturalLanguage

struct TextEntryView: View {
    @State private var entryText: String = ""
    @State private var entryTitle: String = "" 
    @State private var selectedMood: String? = nil 
    @State private var isAIProcessingMood = false 
    @State private var showAlert: Bool = false 
    @State private var isBold: Bool = false
    @State private var isItalic: Bool = false
    @State private var wordCount: Int = 0 
    @FocusState private var focusedField: Field? 
    
    enum Field {
        case title, entry
    }
    
    // Mood Options
    let moods = ["Joyful 😊", "Calm 🌿", "Energetic ⚡", "Stressed 😖", "Sad 😞", "Reflective 🤔"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Text("Text Entry")
                    .font(.largeTitle)
                    .bold()
                
                // Date Display
                Text("📆 \(formattedDate())")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                // Title Text
                TextField("Enter a title (optional)", text: $entryTitle)
                    .font(.title2)
                    .padding()
                    .frame(width: UIScreen.main.bounds.width * 0.6) 
                    .background(Color(.systemBackground))
                    .foregroundColor(Color(.label))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .title ? Color(hex: "#E6C4FE") : Color(hex: "#D3D3D3"), lineWidth: 2) 
                    )
                    .shadow(color: focusedField == .title ? Color(hex: "#E6C4FE").opacity(0.6) : Color.clear, radius: 5)
                    .padding(.horizontal)
                    .focused($focusedField, equals: .title)
                
                // Mood Selection
                HStack {
                    Menu("Select Mood") {
                        ForEach(moods, id: \.self) { mood in
                            Button(mood) { selectedMood = mood }
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(12)
                    
                    Button(action: generateAIMood) {
                        Text("🎭 Auto-Detect Mood")
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(isAIProcessingMood ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(isAIProcessingMood)
                }
                
                if let mood = selectedMood {
                    Text("Selected Mood: \(mood)")
                        .font(.subheadline)
                        .padding(.bottom, 5)
                }
                
                // Text Formatting Controls
                HStack(spacing: 20) {
                    Button(action: { isBold.toggle() }) {
                        Image(systemName: "bold")
                            .font(.title2)
                            .foregroundColor(isBold ? .blue : .gray)
                    }
                    
                    Button(action: { isItalic.toggle() }) {
                        Image(systemName: "italic")
                            .font(.title2)
                            .foregroundColor(isItalic ? .blue : .gray)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                // Text Editor
                TextEditor(text: $entryText)
                    .font(isBold && isItalic ? .title3.italic().bold() : isBold ? .title3.bold() : isItalic ? .title3.italic() : .title3)
                    .padding()
                    .frame(width: UIScreen.main.bounds.width * 0.6, height: 250) 
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .entry ? Color(hex: "#E6C4FE") : Color.gray, lineWidth: 2) 
                    )
                    .shadow(color: focusedField == .entry ? Color(hex: "#E6C4FE").opacity(0.6) : Color.clear, radius: 5)
                    .onChange(of: entryText) { _ in
                        wordCount = entryText.split(separator: " ").count
                    }
                    .focused($focusedField, equals: .entry)
                
                // Word Counter
                Text("Word Count: \(wordCount)")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                
                // Save Button
                Button(action: saveEntry) {
                    Text("Save Entry")
                        .bold()
                        .padding()
                        .frame(width: UIScreen.main.bounds.width * 0.6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Saved!"), message: Text("Your journal entry has been saved."), dismissButton: .default(Text("OK")))
                }
            }
            .padding()
        }
        .navigationTitle("New Journal Entry")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    // Format Date Func
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: Date())
    }
    
    // AI Mood Detection Func
    private func generateAIMood() {
        isAIProcessingMood = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let tagger = NLTagger(tagSchemes: [.sentimentScore])
            tagger.string = entryText
            
            let (sentiment, _) = tagger.tag(at: entryText.startIndex, unit: .paragraph, scheme: .sentimentScore)
            let score = Double(sentiment?.rawValue ?? "0") ?? 0
            
            DispatchQueue.main.async {
                self.selectedMood = self.mapSentimentToMood(score)
                self.isAIProcessingMood = false
            }
        }
    }
    
    private func mapSentimentToMood(_ score: Double) -> String {
        switch score {
        case 0.6...:
            return "Energetic ⚡"
        case 0.3..<0.6:
            return "Joyful 😊" 
        case 0.1..<0.3:
            return "Calm 🌿"     
        case -0.1..<0.1:
            return "Reflective 🤔" 
        case -0.4..<(-0.1):
            return "Stressed 😖"   
        default:
            return "Sad 😞"    
        }
    }
    
    private func saveEntry() {
        if !entryText.isEmpty {
            let entry = JournalEntry(
                id: UUID(),
                date: Date(),
                type: .text,
                content: entryText,
                fileURL: nil,
                emotionTag: selectedMood
            )
            
            JournalDatabaseManager.shared.saveJournalEntry(entry: entry)
            showAlert = true
        }
    }
    
}

struct TextEntryView_Previews: PreviewProvider {
    static var previews: some View {
        TextEntryView()
    }
}
