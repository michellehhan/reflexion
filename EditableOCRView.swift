import SwiftUI

struct EditableOCRView: View {
    @Binding var text: String 
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var journalManager = JournalDatabaseManager.shared 
    
    var body: some View {
        VStack {
            Text("Edit Extracted Text")
                    .font(.title)
                    .bold()
                    .padding()
                
                TextEditor(text: $text)
                    .font(.body)
                    .padding()
                    .frame(height: 300)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .padding()
                
            Button(action: {
                saveEditedText() 
                presentationMode.wrappedValue.dismiss()
            }) {
                    Text("Save")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
                
                Spacer()
            
        }
        .padding()
        .navigationTitle("Edit Text")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func saveEditedText() {
        let updatedEntry = JournalEntry(
            id: UUID(),
            date: Date(),
            type: .ocr,
            content: text, 
            fileURL: nil,
            emotionTag: nil
        )
        journalManager.saveJournalEntry(entry: updatedEntry)
        journalManager.fetchAndUpdateEntries()
    }
    
}

//struct EditableOCRView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditableOCRView(text: "Editable text sample")
//    }
//}
