//
//  VideoEntryView.swift
//  reflexion
//
//  Created by Michelle Han on 2/17/25.
//

import SwiftUI
import AVFoundation
import Speech

// MARK: - VideoEntryView

struct VideoEntryView: View {
    @StateObject private var captureManager = CaptureSessionManager()
    @StateObject private var speechTranscriber = SpeechTranscriber()
    
    // For storing the final transcript if needed
    @State private var fullTranscript: String = ""
    
    // Track whether we are recording
    @State private var isRecording = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Camera Preview
            VideoPreviewView(session: captureManager.captureSession)
                .frame(height: 300)
                .background(Color.black.opacity(0.8))
            
            // Live Transcript
            ScrollView {
                Text(speechTranscriber.currentTranscription)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
            }
            .frame(height: 150)
            
            // Record / Stop Button
            Button(action: {
                if isRecording {
                    // Stop
                    captureManager.stopRecording()
                    speechTranscriber.stopTranscription()
                    fullTranscript = speechTranscriber.currentTranscription
                } else {
                    // Start
                    captureManager.startRecording()
                    speechTranscriber.startTranscription()
                }
                isRecording.toggle()
            }) {
                Text(isRecording ? "Stop Recording" : "Start Recording")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isRecording ? Color.red : Color.blue)
                    .cornerRadius(10)
            }
            
            // If you want to show the final transcript
            if !fullTranscript.isEmpty && !isRecording {
                Text("Final Transcript:")
                    .font(.headline)
                Text(fullTranscript)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            captureManager.configureSession()
        }
        .onDisappear {
            captureManager.stopRecording()
            speechTranscriber.stopTranscription()
        }
        .navigationTitle("Video Journal")
    }
}

// MARK: - VideoPreviewView (Camera Preview in SwiftUI)

struct VideoPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: PreviewUIView, context: Context) {}
}

// A simple UIView that hosts an AVCaptureVideoPreviewLayer
class PreviewUIView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}

// MARK: - CaptureSessionManager (Manages AVCaptureSession + Video Recording)

class CaptureSessionManager: NSObject, ObservableObject {
    let captureSession = AVCaptureSession()
    private var videoOutput = AVCaptureMovieFileOutput()
    
    override init() {
        super.init()
    }
    
    func configureSession() {
        // Configure camera
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .front),
              let mic = AVCaptureDevice.default(.builtInMicrophone,
                                                for: .audio,
                                                position: .unspecified) else {
            print("ERROR: Unable to access camera or microphone.")
            return
        }
        
        do {
            captureSession.beginConfiguration()
            
            // Add video input
            let videoInput = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
            
            // Add audio input
            let audioInput = try AVCaptureDeviceInput(device: mic)
            if captureSession.canAddInput(audioInput) {
                captureSession.addInput(audioInput)
            }
            
            // Add movie output
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            
            // Set session preset (HD quality, for example)
            if captureSession.canSetSessionPreset(.high) {
                captureSession.sessionPreset = .high
            }
            
            captureSession.commitConfiguration()
            
            // Start running the capture session
            captureSession.startRunning()
        } catch {
            print("ERROR setting up capture session: \(error.localizedDescription)")
        }
    }
    
    func startRecording() {
        guard !videoOutput.isRecording else { return }
        
        // Create a temporary file URL
        let outputPath = NSTemporaryDirectory() + "videoJournal-\(UUID().uuidString).mp4"
        let outputFileURL = URL(fileURLWithPath: outputPath)
        
        videoOutput.startRecording(to: outputFileURL, recordingDelegate: self)
    }
    
    func stopRecording() {
        guard videoOutput.isRecording else { return }
        videoOutput.stopRecording()
    }
}

extension CaptureSessionManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        if let error = error {
            print("Recording error: \(error.localizedDescription)")
        } else {
            print("Video saved to: \(outputFileURL)")
            // You could move or save the file to your app’s documents, or store URL in your data model
        }
    }
}

// MARK: - SpeechTranscriber (Manages Live Speech-to-Text)

class SpeechTranscriber: NSObject, ObservableObject {
    private let audioEngine = AVAudioEngine()
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    @Published var currentTranscription: String = ""
    
    func startTranscription() {
        // Request permission to transcribe
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus != .authorized {
                    print("Speech Recognition not authorized.")
                } else {
                    self.beginTranscription()
                }
            }
        }
    }
    
    private func beginTranscription() {
        do {
            // Reset any existing tasks
            recognitionTask?.cancel()
            recognitionTask = nil
            
            // Create the recognition request
            request = SFSpeechAudioBufferRecognitionRequest()
            guard let request = request else { return }
            
            // Configure audio session
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            // Setup audio engine
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
                request.append(buffer)
            }
            
            // Start audio engine
            audioEngine.prepare()
            try audioEngine.start()
            
            // Start recognition
            recognitionTask = speechRecognizer?.recognitionTask(with: request) { result, error in
                if let result = result {
                    DispatchQueue.main.async {
                        self.currentTranscription = result.bestTranscription.formattedString
                    }
                }
                if error != nil {
                    // On error or completion, stop
                    self.stopTranscription()
                }
            }
        } catch {
            print("Error setting up speech recognition: \(error.localizedDescription)")
        }
    }
    
    func stopTranscription() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        request = nil
        // Audio session teardown if desired
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

struct VideoEntryView_Previews: PreviewProvider {
    static var previews: some View {
        VideoEntryView()
    }
}
