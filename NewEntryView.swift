//
//  NewEntryView.swift
//  reflexion
//
//  Created by Michelle Han on 2/17/25.
//

import Foundation
import SwiftUI

struct NewEntryView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("How would you like to journal today?")
                    .font(.title2)
                    .padding()

                List {
                    NavigationLink(destination: TextEntryView()) {
                        Label("✍️ Writing (Typing)", systemImage: "pencil")
                    }
                    NavigationLink(destination: AudioEntryView()) {
                        Label("🎤 Audio Recording", systemImage: "mic.fill")
                    }
                    NavigationLink(destination: VideoEntryView()) {
                        Label("📹 Video Journaling", systemImage: "video.fill")
                    }
                    NavigationLink(destination: OCRView()) {
                        Label("🖼 Picture of Journal Page (AI OCR)", systemImage: "camera.viewfinder")
                    }
                    NavigationLink(destination: DrawingEntryView()) {
                        Label("🎨 Drawing/Sketching", systemImage: "paintbrush.fill")
                    }
                    NavigationLink(destination: MoodEntryView()) {
                        Label("😀 Sliders for Mood Ratings", systemImage: "slider.horizontal.3")
                    }
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct NewEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NewEntryView()
    }
}
