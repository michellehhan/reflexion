import SwiftUI
import AVFoundation

struct AudioReviewView: View {
    let audioURL: URL?
    let transcript: String
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var playbackProgress: Double = 0
    @State private var timer: Timer?
    
    @State private var isSaving = false
    @State private var showAlert = false 
    
    @ObservedObject var journalManager = JournalDatabaseManager.shared 
    
    @State private var selectedMood: String? = nil
    let moodOptions = ["Joyful 😊", "Calm 🌿", "Energetic ⚡", "Stressed 😖", "Sad 😞", "Reflective 🤔"]
    
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Review Audio")
                .font(.title)
                .bold()
            
            // Transcript Display
            ScrollView {
                Text(transcript.isEmpty ? "No transcript available." : transcript)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
            }
            .frame(height: 200)
            
            VStack {
                Text("Select a Mood")
                    .font(.headline)
                
                Picker("Mood", selection: $selectedMood) {
                    ForEach(moodOptions, id: \.self) { mood in
                        Text(mood).tag(mood as String?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 250) 
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            }
            
            // Playback Progress Bar
            VStack {
                Slider(value: $playbackProgress, in: 0...1, onEditingChanged: { _ in
                    seekAudio()
                })
                .accentColor(.blue)
                
                Text("\(formattedTime(playbackProgress * (audioPlayer?.duration ?? 0)))") 
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            
            // Play/Pause Button
            Button(action: togglePlayback) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.largeTitle)
                    .frame(width: 60, height: 60)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            
            // Add to Journal Button
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
        .navigationTitle("Review Audio")
        .onAppear {
            setupAudioPlayer()
        }
        .alert(isPresented: $showAlert) { 
            Alert(
                title: Text("Saved!"),
                message: Text("Your journal entry has been saved."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // Audio Player
    private func setupAudioPlayer() {
        guard let url = audioURL else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if let duration = audioPlayer?.duration, duration > 0 {
                    playbackProgress = (audioPlayer?.currentTime ?? 0) / duration
                }
            }
        } catch {
            print("❌ Failed to load audio: \(error.localizedDescription)")
        }
    }
    
    private func saveToDatabase() {
        guard let audioURL = audioURL, let mood = selectedMood else { return }
        
        isSaving = true 
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // Simulate saving delay
            let entry = JournalEntry(
                id: UUID(),
                date: Date(),
                type: .audio,
                content: transcript, 
                fileURL: audioURL.absoluteString, 
                emotionTag: mood
            )
            
            journalManager.saveJournalEntry(entry: entry)
            
            journalManager.fetchAndUpdateEntries()

            isSaving = false
            showAlert = true
            
        }
    }


    // Toggle Play/Pause
    private func togglePlayback() {
        guard let player = audioPlayer else { return }
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
    
    // Seek Audio When Slider Moves
    private func seekAudio() {
        if let duration = audioPlayer?.duration {
            audioPlayer?.currentTime = duration * playbackProgress
        }
    }
    
    private func formattedTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
}
