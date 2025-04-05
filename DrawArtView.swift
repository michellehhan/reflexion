import SwiftUI

struct DrawArtView: View {
    @State private var drawnImage: UIImage?
    @State private var brushColor: Color = .black
    @State private var brushSize: CGFloat = 5.0
    @State private var detectedMood: String? = nil
    @State private var selectedMood: String = " "
    @State private var isAnalyzing = false
    @State private var caption: String = ""
    @State private var showSuccessMessage = false
    @State private var isSaving = false
    @State private var selectedPalette: String = "Warm 🔥"
    
     @ObservedObject var journalManager = JournalDatabaseManager.shared
    
    let colorPalettes: [String: [Color]] = [
        "Warm 🔥": [.red, .orange, .yellow, .pink],
        "Cool ❄️": [.blue, .cyan, .teal, .green],
        "Pastel 🌸": [.pink, .mint],
        "Neon 🌟": [.yellow, .green, .purple, .blue]
    ]
    
    // Mood Options
    let moodOptions = ["Joyful 😊", "Calm 🌿", "Energetic ⚡", "Stressed 😖", "Sad 😞", "Reflective 🤔"]

    
    var body: some View {
            VStack(spacing: 16) {
                Text("Draw on Canvas")
                    .font(.title)
                    .bold()
                
                // Drawing Canvas
                CanvasView(drawnImage: $drawnImage, brushColor: $brushColor, brushSize: $brushSize)
                    .frame(height: 300)
                    .border(Color.gray, width: 1)
                    .background(Color.white)
                
                // Mood-Based Color Presets + Pinned Picker
                VStack {
                    Picker("Select Palette", selection: $selectedPalette) {
                        ForEach(colorPalettes.keys.sorted(), id: \.self) { palette in
                            Text(palette)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    HStack {

                        if let colors = colorPalettes[selectedPalette] {
                            ForEach(colors, id: \.self) { color in
                                Button(action: {
                                    brushColor = color
                                }) {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Circle()
                                                .stroke(brushColor == color ? Color.white.opacity(0.9) : Color.gray, lineWidth: brushColor == color ? 3 : 1)
                                        )
                                        .shadow(radius: brushColor == color ? 4 : 0) // Glow effect
                                }
                            }
                        }
                        
                        Button(action: {}) {
                            ColorPicker("", selection: $brushColor)
                                .labelsHidden()
                                .frame(width: 40, height: 40)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.5), lineWidth: 2))
                                .shadow(radius: 4)
                        }
                    }
                }
                
                // Brush Settings
                HStack {
                    Text("Size:")
                    Slider(value: $brushSize, in: 1...10)
                }
                .padding(.horizontal)
                
                // Caption
                TextField("Write a caption...", text: $caption)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // Mood Analysis
                VStack {
                    Text("🎭 How do you feel about this drawing?")
                        .font(.headline)
                    
                    HStack {
                        Menu("Select Mood") {
                            ForEach(moodOptions, id: \.self) { mood in
                                Button(mood) { 
                                    selectedMood = mood 
                                    detectedMood = nil
                                }
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                        
                        Button(action: analyzeMood) {
                            HStack {
                                if isAnalyzing {
                                    ProgressView()
                                }
                                Text("🎭 Auto-Detect Mood")
                            }
                        }
                        .padding()
                        .background(isAnalyzing ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(isAnalyzing)
                    }
                    
                    Text("Selected Mood: \(detectedMood ?? selectedMood)")
                        .font(.subheadline)
                        .padding(.bottom, 5)
                }
                
                // Save Entry
                Button(action: saveEntry) {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        Text("Save to Journal")
                    }
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isSaving ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(drawnImage == nil || isSaving)
                
                Spacer()
                
            }
            .padding()
            .navigationTitle("Draw Art")
            .alert(isPresented: $showSuccessMessage) { 
                Alert(
                    title: Text("Saved!"),
                    message: Text("Your journal entry has been saved."),
                    dismissButton: .default(Text("OK"))
                )
            }
    }
    
    func extractDominantColor(from image: UIImage) -> UIColor {
        guard let cgImage = image.cgImage else { return .white }
        
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter(name: "CIAreaAverage")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputImage = filter?.outputImage else { return .white }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext()
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        
        let r = CGFloat(bitmap[0]) / 255.0
        let g = CGFloat(bitmap[1]) / 255.0
        let b = CGFloat(bitmap[2]) / 255.0
        
        print("Extracted Color - R:\(bitmap[0]) G:\(bitmap[1]) B:\(bitmap[2]) -> Adjusted: R:\(Int(r * 255)) G:\(Int(g * 255)) B:\(Int(b * 255))")
        
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
    
    func isColor(_ color1: UIColor, closeTo color2: UIColor, tolerance: CGFloat = 0.25) -> Bool {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return abs(r1 - r2) < tolerance && abs(g1 - g2) < tolerance && abs(b1 - b2) < tolerance
    }
    
    func analyzeMood() {
        isAnalyzing = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let image = drawnImage else {
                DispatchQueue.main.async {
                    detectedMood = "Could not analyze"
                    isAnalyzing = false
                }
                return
            }
            
            let dominantColor = extractDominantColor(from: image)
            
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            dominantColor.getRed(&r, green: &g, blue: &b, alpha: &a)
            
            print("Extracted Color - R:\(Int(r * 255)) G:\(Int(g * 255)) B:\(Int(b * 255))")
            
            let mood: String
            if r > 0.7 && g > 0.7 && b > 0.7 {
                mood = "Reflective 🤔"  // Very light/white colors
            } else if isColor(dominantColor, closeTo: .red, tolerance: 0.25) || isColor(dominantColor, closeTo: .orange) {
                mood = "Energetic ⚡"
            } else if isColor(dominantColor, closeTo: .blue, tolerance: 0.25) || isColor(dominantColor, closeTo: .cyan) {
                mood = "Calm 🌿"
            } else if isColor(dominantColor, closeTo: .green, tolerance: 0.25) {
                mood = "Reflective 🤔"
            } else if isColor(dominantColor, closeTo: .purple, tolerance: 0.25) || isColor(dominantColor, closeTo: .gray, tolerance: 0.25) {
                mood = "Sad 😞"
            } else if isColor(dominantColor, closeTo: .black, tolerance: 0.25) || isColor(dominantColor, closeTo: .darkGray, tolerance: 0.25) {
                mood = "Stressed 😖"
            } else {
                mood = "Joyful 😊"
            }
            
            DispatchQueue.main.async {
                print("Detected Mood: \(mood)") // Debugging
                detectedMood = mood
                isAnalyzing = false
            }
        }
    }
    
    // Save Drawn Art Entry
    func saveEntry() {
        guard let image = drawnImage else {
            print("❌ No image found to save.")
            return
        }
        
        isSaving = true
        
        if let filePath = saveImageToDocuments(image: image) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { 
                let entry = JournalEntry(
                    id: UUID(),
                    date: Date(),
                    type: .drawnArt,
                    content: caption.isEmpty ? "No Caption" : caption,
                    fileURL: filePath, 
                    emotionTag: detectedMood ?? selectedMood
                )
                
                journalManager.saveJournalEntry(entry: entry)
                isSaving = false
                showSuccessMessage = true
                
            }
        } else {
            isSaving = false
            print("❌ Failed to save drawn image.")
        }
    }
}

func saveImageToDocuments(image: UIImage) -> String? {
    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
        print("❌ Failed to convert image to JPEG data.")
        return nil
    }
    
    let fileManager = FileManager.default
    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileName = "drawing_\(UUID().uuidString).jpg" // Unique filename
    let fileURL = documentsURL.appendingPathComponent(fileName)
    
    do {
        try imageData.write(to: fileURL)
        print("✅ Image saved at: \(fileURL.path)")
        return fileURL.path 
    } catch {
        print("❌ Error saving image: \(error)")
        return nil
    }
}

struct DrawArtView_Previews: PreviewProvider {
    static var previews: some View {
        DrawArtView()
    }
}
