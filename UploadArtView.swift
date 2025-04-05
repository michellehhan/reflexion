import SwiftUI
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct UploadArtView: View {
    @State private var selectedImage: UIImage?
    @State private var caption: String = ""
    @State private var detectedMood: String? = nil
    @State private var selectedMood: String? = nil  

    @State private var isAnalyzing = false
    @State private var isImagePickerPresented = false
    @State private var showSuccessMessage = false 
    @State private var isSaving = false
    
    @ObservedObject var journalManager = JournalDatabaseManager.shared
    
    private let availableMoods = ["Joyful 😊", "Calm 🌿", "Energetic ⚡", "Stressed 😖", "Sad 😞", "Reflective 🤔"]

    
    var body: some View {
            VStack(spacing: 16) {
                Text("Upload Artwork")
                    .font(.title)
                    .bold()
                
                // Image Selection
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(10)
                } else {
                    Text("No image selected")
                        .foregroundColor(.gray)
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                }
                
                // Choose Image Button
                Button(action: { isImagePickerPresented = true }) {
                    Text("Choose Image")
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // Caption Input
                TextField("Write a caption...", text: $caption)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // AI Mood Analysis
                VStack {
                    Text("🎭 How do you feel about this artwork?")
                        .font(.headline)
                    
                    HStack {
                        Menu("Select Mood") {
                            ForEach(availableMoods, id: \.self) { mood in
                                Button(mood) { 
                                    selectedMood = mood 
                                    detectedMood = nil // Override AI-detected mood
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
                    
                    Text("Selected Mood: \(selectedMood ?? detectedMood ?? "None")")
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
                .disabled(selectedImage == nil || isSaving)
                
                Spacer()
                
            }
            .padding()
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $selectedImage) 
            }
            .navigationTitle("Upload Art")
            .alert(isPresented: $showSuccessMessage) { 
                Alert(
                    title: Text("Saved!"),
                    message: Text("Your journal entry has been saved."),
                    dismissButton: .default(Text("OK"))
                )
            }
        
    }
    
    // Select Image Function
    func selectImage() {
        isImagePickerPresented = true
    }
    
    // Analyze Mood Based on Dominant Color
    func analyzeMood() {
        guard let image = selectedImage else {
            print("❌ Error: No image selected.")
            return
        }
        
        isAnalyzing = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let mood = self.detectMoodFromColor(image: image)
            
            DispatchQueue.main.async {
                self.detectedMood = mood
                self.isAnalyzing = false
            }
        }
    }
    
    // Extract Dominant Color
    func detectMoodFromColor(image: UIImage) -> String {
        guard let ciImage = CIImage(image: image) else { return "Reflective 🤔" }
        
        let filter = CIFilter.areaAverage()
        filter.inputImage = ciImage
        let context = CIContext()
        
        // Extract average color
        guard let outputImage = filter.outputImage else { return "Reflective 🤔" }
        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        
        let color = UIColor(red: CGFloat(bitmap[0]) / 255.0,
                            green: CGFloat(bitmap[1]) / 255.0,
                            blue: CGFloat(bitmap[2]) / 255.0,
                            alpha: CGFloat(bitmap[3]) / 255.0)
        
        return mapColorToMood(color)
    }
    
    // Map Color to Mood
    func mapColorToMood(_ color: UIColor) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        if red > 0.7 && green > 0.7 && blue > 0.2 { return "Joyful 😊" } // Warm yellow/orange
        if red > 0.7 && green < 0.4 && blue < 0.4 { return "Energetic ⚡" } // Red
        if red < 0.4 && green > 0.6 && blue < 0.4 { return "Calm 🌿" } // Green
        if red < 0.4 && green < 0.4 && blue > 0.7 { return "Sad 😞" } // Blue
        if red > 0.7 && green < 0.4 && blue > 0.7 { return "Stressed 😖" } // Purple
        return "Reflective 🤔" // Neutral/Gray
    }
    
    // Save Image to Documents Directory
    func saveImageToDocuments(image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Error: Could not convert image to data.")
            return nil
        }
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "image_\(UUID().uuidString).jpg" 
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
    
    // Save Art Entry
    func saveEntry() {
        guard let image = selectedImage else { 
            print("❌ Error: No image selected.") 
            return 
        }
        
        isSaving = true 
        
        guard let filePath = saveImageToDocuments(image: image) else {
            isSaving = false
            print("❌ Failed to save image.")
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { 
            let entry = JournalEntry(
                id: UUID(),
                date: Date(),
                type: .uploadedArt,
                content: caption.isEmpty ? "No Caption" : caption, 
                fileURL: filePath, 
                emotionTag: detectedMood
            )
            
            journalManager.saveJournalEntry(entry: entry)
            isSaving = false 
            showSuccessMessage = true 
            
            print("✅ Entry Saved with Image Path: \(filePath)")
            
        }
    }
}
