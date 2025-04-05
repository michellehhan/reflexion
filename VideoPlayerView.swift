import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoURL: URL
    @State private var player: AVPlayer?
    
    var body: some View {
            VStack {
                
                if FileManager.default.fileExists(atPath: videoURL.path) {
                    VideoPlayer(player: player)
                        .frame(height: 700)
                        .cornerRadius(10)
                        .padding()
                    Spacer()
                } else {
                    Text("❌ Video file not found at \(videoURL.path)")
                        .foregroundColor(.red)
                        .padding()
                    Spacer()
                }
                
            }
            .frame(maxHeight: .infinity, alignment: .center)
            .onAppear {
                validateAndLoadVideo()
            }
        
    }
    
    private func validateAndLoadVideo() {
        if FileManager.default.fileExists(atPath: videoURL.path) {
            print("✅ Video file found at: \(videoURL.path)")
            self.player = AVPlayer(url: videoURL)
        } else {
            print("❌ Video file does not exist at path: \(videoURL.path)")
        }
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView(videoURL: URL(fileURLWithPath: "/path/to/local/video.mp4"))
    }
}
