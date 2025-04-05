
import Foundation
import SwiftUI
import AVFoundation
import Speech

struct AudioEntryView: View {
    @StateObject private var audioRecorder = AudioRecorderManager() 
    @StateObject private var speechTranscriber = SpeechTranscriber() 
    
    @State private var isRecording = false 
    @State private var fullTranscript: String = ""
    @State private var recordingDate = Date()
    @State private var navigateToReview = false
    
    var body: some View {
        
        NavigationStack{
            ScrollView{
            VStack(spacing: 20) {
                
                Text("Audio Entry")
                    .font(.title)
                    .bold()
                
                // Live Transcript Box
                ScrollViewReader { scrollView in
                    ScrollView {
                        VStack {
                            Text(speechTranscriber.currentTranscription.isEmpty ? "Start speaking..." : speechTranscriber.currentTranscription)
                                .font(.body)
                                .frame(width: UIScreen.main.bounds.width * 0.6, alignment: .leading)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                                .id("Bottom")
                        }
                    }
                    .frame(height: 150)
                    .onChange(of: speechTranscriber.currentTranscription) { _ in
                        withAnimation {
                            scrollView.scrollTo("Bottom", anchor: .bottom) 
                        }
                    }
                }
                
                HStack(spacing: 2) {
                    ForEach(0..<30, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.blue)
                            .frame(width: 3, height: CGFloat(max(5, (audioRecorder.audioLevels.indices.contains(index) ? audioRecorder.audioLevels[index] + 100 : -160) * 1.2))) 
                    }
                }
                .frame(width: UIScreen.main.bounds.width * 0.7, height: 30) 
                .padding()
                .padding(.bottom, 50)
                
                // Circular Record Button
                Button(action: {
                    if isRecording {
                        audioRecorder.stopRecording()
                        speechTranscriber.stopTranscription()
                        fullTranscript = speechTranscriber.currentTranscription
                    } else {
                        recordingDate = Date()
                        audioRecorder.startRecording()
                        speechTranscriber.startTranscription()
                    }
                    isRecording.toggle()
                }) {
                    Circle()
                        .fill(isRecording ? Color.red : Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: isRecording ? 6 : 40)
                                .fill(Color(UIColor.systemBackground))
                                .frame(width: isRecording ? 30 : 80, height: isRecording ? 30 : 80)
                        )
                }
                .padding()
                
                
                // Recording Timer
                Text("Recording Time: \(formattedTime(audioRecorder.recordingTime))")
                    .font(.headline)
                
                // Record / Stop Button
                HStack {
                    Button(action: {
                        if isRecording {
                            audioRecorder.stopRecording()
                            speechTranscriber.stopTranscription()
                            fullTranscript = speechTranscriber.currentTranscription
                            
                            navigateToReview = true
                        } else {
                            recordingDate = Date()
                            audioRecorder.startRecording()
                            speechTranscriber.startTranscription()
                        }
                        isRecording.toggle()
                    }) {
                        Text(isRecording ? "Pause Recording" : "Start Recording")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isRecording ? Color.orange : Color.blue)
                            .cornerRadius(10)
                    }
                    
                    
                    
                    
                    if !fullTranscript.isEmpty {
                        Button(action: { navigateToReview = true }) {
                            Text("Finished? Review Audio")
                                .bold()
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top)
                        .navigationDestination(isPresented: $navigateToReview) {
                            AudioReviewView(audioURL: audioRecorder.audioFileURL, transcript: fullTranscript)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        }
    }
    // Format Timer as MM:SS
    private func formattedTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct AudioEntryView_Previews: PreviewProvider {
    static var previews: some View {
        AudioEntryView()
    }
}
