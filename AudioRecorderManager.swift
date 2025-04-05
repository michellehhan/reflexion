import SwiftUI
import Foundation
import AVFoundation

class AudioRecorderManager: NSObject, ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var startTime: Date?
    
    @Published var recordingTime: TimeInterval = 0 // Tracks duration
    @Published var isPaused = false // Tracks pause state
    @Published var audioLevels: [Float] = Array(repeating: -160, count: 10) 
    var audioFileURL: URL?
    
    override init() {
        super.init()
        requestPermissions()
    }
    
    // Request mic permission
    private func requestPermissions() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if !granted {
                print("❌ Microphone access denied")
            }
        }
    }
    
    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try session.setActive(true)
            
            let fileName = "AudioJournal-\(UUID().uuidString).m4a"
            let filePath = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            self.audioFileURL = filePath
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: filePath, settings: settings)
            audioRecorder?.isMeteringEnabled = true 
            audioRecorder?.record()
            isPaused = false
            startTimer() 
            print("🎙 Recording started...")
        } catch {
            print("❌ Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func pauseRecording() {
        audioRecorder?.pause()
        isPaused = true
        stopTimer()
        print("⏸ Recording paused")
    }
    
    func resumeRecording() {
        audioRecorder?.record()
        isPaused = false
        startTimer()
        print("▶️ Resumed recording")
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        stopTimer()
        print("✅ Recording saved: \(audioFileURL?.absoluteString ?? "Unknown")")
    }
    
    func playRecording() {
        guard let url = audioFileURL else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("▶️ Playing audio...")
        } catch {
            print("❌ Failed to play recording: \(error.localizedDescription)")
        }
    }

    private func startTimer() {
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateAudioLevels()
            if let startTime = self.startTime {
                self.recordingTime = Date().timeIntervalSince(startTime)
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateAudioLevels() {
        audioRecorder?.updateMeters()
        let newLevel = audioRecorder?.averagePower(forChannel: 0) ?? -160
        DispatchQueue.main.async {
            self.audioLevels.removeFirst()
            self.audioLevels.append(newLevel)
        }
    }
    
}
