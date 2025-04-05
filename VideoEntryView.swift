
import SwiftUI
import AVFoundation
import Speech


struct VideoEntryView: View {
    @StateObject private var captureManager = CaptureSessionManager()
    @StateObject private var speechTranscriber = SpeechTranscriber()
    
    @State private var fullTranscript: String = ""
    @State private var isRecording = false
    @State private var navigateToReview = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) { 
                    Text("Video Entry")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal)
                    
                    // Camera Preview
                    VideoPreviewView(session: captureManager.captureSession)
                        .frame(height: 500)
                        .background(Color.white.opacity(1))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    
                    // Live Transcript
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading) {
                                Text(speechTranscriber.currentTranscription)
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(8)
                                    .id("LatestTranscription")
                            }
                        }
                        .frame(height: 120)
                        .onChange(of: speechTranscriber.currentTranscription) { _ in
                            withAnimation {
                                proxy.scrollTo("LatestTranscription", anchor: .bottom)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Record / Stop Button
                    Button(action: {
                        if isRecording {
                            captureManager.stopRecording()
                            speechTranscriber.stopTranscription()
                            fullTranscript = speechTranscriber.currentTranscription
                        } else {
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
                            .padding(.horizontal)
                    }
                    
                    // Review Video Button
                    if let videoURL = captureManager.recordedVideoURL, !isRecording {
                        Button(action: { navigateToReview = true }) {
                            Text("Finished? Review Video")
                                .bold()
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .navigationDestination(isPresented: $navigateToReview) {
                            VideoReviewView(videoURL: videoURL, transcript: fullTranscript)
                        }
                    }
                    
                    Spacer(minLength: 60)
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    EmptyView() 
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true) 
            .onAppear {
                captureManager.configureSession()
            }
            .onDisappear {
                captureManager.stopRecording()
                speechTranscriber.stopTranscription()
            }
        }
    }
}

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

class PreviewUIView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}


class CaptureSessionManager: NSObject, ObservableObject {
    let captureSession = AVCaptureSession()
    private var videoOutput = AVCaptureMovieFileOutput()
    
    @Published var recordedVideoURL: URL? 

    override init() {
        super.init()
    }
    
    func configureSession() {
        // Configure camera
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let mic = AVCaptureDevice.default(.builtInMicrophone, for: .audio, position: .unspecified) else {
            print("ERROR: Unable to access camera or microphone.")
            return
        }
        
        do {
            captureSession.beginConfiguration()
            let videoInput = try AVCaptureDeviceInput(device: camera)
            let audioInput = try AVCaptureDeviceInput(device: mic)
            
            if captureSession.canAddInput(videoInput) { captureSession.addInput(videoInput) }
            if captureSession.canAddInput(audioInput) { captureSession.addInput(audioInput) }
            if captureSession.canAddOutput(videoOutput) { captureSession.addOutput(videoOutput) }
            
            captureSession.sessionPreset = .high
            captureSession.commitConfiguration()
            captureSession.startRunning()
        } catch {
            print("ERROR setting up capture session: \(error.localizedDescription)")
        }
    }
    
    func startRecording() {
        let outputPath = NSTemporaryDirectory() + "videoJournal-\(UUID().uuidString).mp4"
        let outputFileURL = URL(fileURLWithPath: outputPath)
        videoOutput.startRecording(to: outputFileURL, recordingDelegate: self)
    }
    
    func stopRecording() {
        videoOutput.stopRecording()
    }
}

extension CaptureSessionManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            let validPath = outputFileURL.absoluteString.replacingOccurrences(of: "file:/", with: "")
            self.recordedVideoURL = outputFileURL // ✅ Store recorded video URL
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
