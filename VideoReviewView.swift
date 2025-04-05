import SwiftUI
import AVKit

struct VideoReviewView: View {
    let videoURL: URL?
    let transcript: String
    
    @State private var isSaving = false
    @State private var showAlert = false
    @ObservedObject var journalManager = JournalDatabaseManager.shared
    
    var body: some View {
            VStack(spacing: 16) {
                Text("Review Video")
                    .font(.title)
                    .bold()
                
                if let url = videoURL {
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 300)
                        .cornerRadius(10)
                } else {
                    Text("No video recorded.")
                        .foregroundColor(.gray)
                }
                
                ScrollView {
                    Text(transcript.isEmpty ? "No transcript available." : transcript)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                }
                .frame(height: 200)
                

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
                .padding(.top)
                .disabled(isSaving) 
                
                Spacer()
                
            }
            .padding()
            .padding(.bottom, 20)
            .navigationTitle("Review Video")
            .alert(isPresented: $showAlert) { 
                Alert(
                    title: Text("Saved!"),
                    message: Text("Your journal entry has been saved."),
                    dismissButton: .default(Text("OK"))
                )
            }
        
    }
    
    private func saveToDatabase() {
        guard let videoURL = videoURL else { return }
        
        isSaving = true 
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { 
            let entry = JournalEntry(
                id: UUID(),
                date: Date(),
                type: .video,
                content: transcript, 
                fileURL: videoURL.absoluteString 
            )
            
            journalManager.saveJournalEntry(entry: entry) 
            journalManager.fetchAndUpdateEntries()
            
            isSaving = false 
            showAlert = true

        }
    }
}
