import SwiftUI

struct NewEntryView: View {
    var body: some View {
        NavigationView {
            ZStack {
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("How would you like to journal today?")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    
                    
                    ScrollView {
                        VStack(spacing: 15) {
                            JournalOption(destination: TextEntryView(), icon: "pencil", text: "✍️ Writing (Typing)")
                            JournalOption(destination: AudioEntryView(), icon: "mic.fill", text: "🎤 Audio Recording")
                            JournalOption(destination: VideoEntryView(), icon: "video.fill", text: "📹 Video Journaling")
                            JournalOption(destination: OCRView(), icon: "camera.viewfinder", text: "🖼 Picture of Journal Page")
                            JournalOption(destination: ArtSelectionView(), icon: "paintbrush.fill", text: "🎨 Drawing/Sketching")
                            JournalOption(destination: MoodEntryView(), icon: "slider.horizontal.3", text: "😀 Quick Mood Entry")
                        }
                        .padding()
                    }
                    
                    Spacer() 
                }
                .padding(.top, 10)
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct JournalOption<Destination: View>: View {
    let destination: Destination
    let icon: String
    let text: String
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: icon)
                    .font(.title2) 
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.blue.opacity(0.8))
                    .clipShape(Circle()) 
                
                Text(text)
                    .font(.system(size: 20, weight: .medium)) 
                    .foregroundColor(Color(.label))
                    .padding(.leading, 10)
                
                Spacer()
                Image(systemName: "chevron.right") 
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                Color(UIColor { $0.userInterfaceStyle == .dark ? .black : .white })
                    .opacity(0.9)
            )
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}

struct NewEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NewEntryView()
    }
}
