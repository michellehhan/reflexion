import SwiftUI
import AVFoundation

struct AudioJournalListView: View {
    @ObservedObject var databaseManager = JournalDatabaseManager.shared 
    @State private var selectedAudioURL: URL?
    
    var audioEntries: [JournalEntry] {
        databaseManager.entries.filter { $0.type == .audio } 
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if audioEntries.isEmpty {
                    Text("No saved audio journal entries.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(audioEntries) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(entry.content.isEmpty ? "No transcript available" : entry.content)
                                .font(.headline)
                            
                            Text("Recorded on: \(entry.date.formatted(date: .abbreviated, time: .shortened))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            if let fileURL = entry.fileURL, let url = URL(string: fileURL) {
                                Button(action: {
                                    selectedAudioURL = url
                                    playAudio(url: url)
                                }) {
                                    HStack {
                                        Image(systemName: "play.circle.fill")
                                        Text("Play Recording")
                                    }
                                }
                                .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("Saved Audio Journals")
        }
    }
    
    private func playAudio(url: URL) {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.play()
        } catch {
            print("❌ Error playing audio: \(error.localizedDescription)")
        }
    }
}
