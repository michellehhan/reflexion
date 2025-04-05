import Foundation
import SwiftUI
import AVFoundation

struct EntryViewerView: View {
    @ObservedObject var databaseManager = JournalDatabaseManager.shared

    @State private var selectedEntry: JournalEntry?
    @State private var filterEmotion: String? = nil
    
    var filteredEntries: [JournalEntry] {
        var list = databaseManager.entries
        if let filterEmotion = filterEmotion {
            list = list.filter { $0.emotionTag == filterEmotion }
        }
        return list
    }
    
        var body: some View {
            NavigationStack {
                VStack(alignment: .leading) { 
                    
                    // Filter by Emotion
                    HStack(alignment: .center, spacing: 20) { 
                        Text("Filter by Emotion")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) { 
                                let emotions = ["Joyful 😊", "Calm 🌿", "Energetic ⚡", "Stressed 😖", "Sad 😞", "Reflective 🤔"]
                                
                                ForEach(emotions, id: \.self) { emotion in
                                    Button(action: {
                                        filterEmotion = (filterEmotion == emotion) ? nil : emotion
                                    }) {
                                        Text(emotion)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 15)
                                            .background(filterEmotion == emotion ? Color(hex: "#E5BBF1") : Color(.secondarySystemBackground))
                                            .foregroundColor(filterEmotion == emotion ? .white : .primary)
                                            .cornerRadius(10)
                                    }
                                }
                                Button(action: {
                                    filterEmotion = nil
                                }) {
                                    Text("Clear Filter")
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 15)
                                        .background(Color.red.opacity(0.7)) 
                                        .foregroundColor(.white) 
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
        
                    
                    // List of Entries
                    if filteredEntries.isEmpty {
                        Text("No saved journal entries.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List(filteredEntries) { entry in 
                            NavigationLink(destination: JournalEntryDetailView(entry: entry)) {
                                HStack {
                                    entryThumbnail(entry: entry)
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(8)
                                    
                                    VStack(alignment: .leading) {
                                        Text(entry.type.rawValue)
                                            .font(.headline)
                                        Text(entry.content)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .lineLimit(2)
                                            .truncationMode(.tail)
                                        Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                    }
                                    
                                    Spacer()
                                    
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    databaseManager.fetchAndUpdateEntries()
                }
                .navigationTitle("Journal Entries")
            
        }
    }
    
    // Entry Thumbnails
    private func entryThumbnail(entry: JournalEntry) -> some View {
        switch entry.type {
        case .text:
            return AnyView(Text("📝").font(.largeTitle))
            
        case .audio:
            return AnyView(Image(systemName: "waveform")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)) 
            
        case .video:
            return AnyView(Image(systemName: "play.rectangle")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40))
            
        case .ocr:
            return AnyView(Image(systemName: "doc.text.magnifyingglass")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)) 
            
        case .drawnArt, .uploadedArt:
            if let fileURL = entry.fileURL, let image = UIImage(contentsOfFile: fileURL) {
                return AnyView(Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))) 
            } else {
                return AnyView(Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)) 
            }
        case .moodEntry:
            return AnyView(Image(systemName: "face.smiling")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40))
            
        }
    }
        
}

// Full Journal Entry View
struct JournalEntryDetailView: View {
    let entry: JournalEntry
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(entry.type.rawValue)
                    .font(.title)
                    .bold()
                
                if let emotionTag = entry.emotionTag {
                    Text("Emotion: \(emotionTag)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(hex: "#e5bbf1"))
                        .cornerRadius(10) 
                        .padding(.top, 15) 
                        .padding(.bottom, 15)
                }
                
                ScrollView {
                    if entry.type != .ocr && entry.type != .moodEntry {
                        Text(entry.content)
                            .font(.system(size: 22))
                            .padding()
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.72)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(height: 250)
                
                // Audio Playback
                if entry.type == .audio {
                    if let fileURL = validFileURL(from: entry.fileURL) {
                        AudioPlayerView(audioURL: fileURL)
                    } else {
                        Text("❌ Audio file not found or invalid URL")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                
                // Video Playback
                if entry.type == .video {
                    if let fileURL = validFileURL(from: entry.fileURL) {
                        VStack {
                            VideoPlayerView(videoURL: fileURL)
                                .frame(maxWidth: .infinity) 
                                .frame(height: 500) 
                                .cornerRadius(12)
                                .shadow(radius: 5)
                                .padding()
                            Spacer()
                            Spacer()
                        }
                    } else {
                        Text("❌ Video file not found or invalid URL")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                
                // Drawn/Uploaded Art 
                if entry.type == .drawnArt || entry.type == .uploadedArt, let fileURL = entry.fileURL, let image = loadImage(from: fileURL) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 600)
                        .cornerRadius(12)
                        .padding()
                }
                
                // OCR Scanned Text
                if entry.type == .ocr {
                    ScrollView {
                        Text(entry.content)
                            .font(.system(size: 20))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                    }
                    .frame(height: 400)
                }
                
                
                // Mood Entry
                if entry.type == .moodEntry {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(entry.content)
                            .font(.title2)                            .frame(maxWidth: UIScreen.main.bounds.width * 0.9, alignment: .leading) 
                            .multilineTextAlignment(.leading)
                            .padding()
                            .lineSpacing(8)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding(.bottom, 100)
        }
        .padding()
        .navigationTitle("Entry Details")
    }
    private func loadOCRImage(from url: URL) -> UIImage {
        guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
            return UIImage(systemName: "doc.text.magnifyingglass")! 
        }
        return image
    }
}

private func validFileURL(from filePath: String?) -> URL? {
    guard var correctedPath = filePath, !correctedPath.isEmpty else {
        return nil
    }
    
    if correctedPath.hasPrefix("file:/") {
        correctedPath = correctedPath.replacingOccurrences(of: "file:/", with: "")
    } else if correctedPath.hasPrefix("file://") {
        correctedPath = correctedPath.replacingOccurrences(of: "file://", with: "")
    }
    
    let fileURL = URL(fileURLWithPath: correctedPath)
    
    if FileManager.default.fileExists(atPath: fileURL.path) {
        return fileURL
    } else {
        print("❌ Video file not found at path: \(fileURL.path)")
        return nil
    }
}

private func loadImage(from path: String?) -> UIImage? {
    guard let path = path, !path.isEmpty else {
        print("❌ Invalid file path: \(String(describing: path))")
        return nil
    }
    
    let fileURL = URL(fileURLWithPath: path)
    
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
        print("❌ File does not exist: \(fileURL.path)")
        return nil
    }
    
    do {
        let data = try Data(contentsOf: fileURL)
        if let image = UIImage(data: data) {
            return image
        } else {
            print("❌ Failed to convert data to UIImage: \(fileURL.path)")
            return nil
        }
    } catch {
        print("❌ Error loading image: \(error.localizedDescription)")
        return nil
    }
}

struct EntryViewerView_Previews: PreviewProvider {
    static var previews: some View {
        EntryViewerView()
    }
}
