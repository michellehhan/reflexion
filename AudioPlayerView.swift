
import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    let audioURL: URL
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var playbackProgress: Double = 0
    @State private var timer: Timer?
    
    var body: some View {

            VStack(spacing: 10) {
                Spacer()
                Text("🎵 Audio Playback")
                    .font(.headline)
                // Playback Progress Bar
                Slider(value: $playbackProgress, in: 0...1, onEditingChanged: { _ in
                    seekAudio()
                })
                .accentColor(.blue)
                
                // Timer
                Text("\(formattedTime(playbackProgress * (audioPlayer?.duration ?? 0)))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Play/Pause Button
                Button(action: togglePlayback) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.largeTitle)
                        .frame(width: 60, height: 60)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding()
            .onAppear {
                setupAudioPlayer()
            }
        
    }
    
    // Initialize Audio Player
    private func setupAudioPlayer() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
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
    
    // Format Time
    private func formattedTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
