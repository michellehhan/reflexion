import Foundation
import SwiftUI
import UIKit
import Vision
import VisionKit

struct OCRView: View {
    @State private var selectedImage: UIImage?
    @State private var recognizedText: String = ""
    @State private var isImagePickerPresented = false
    @State private var isShowingResult = false
    @State private var isLoading = false 
    private let ocrManager = OCRManager()
    
    var body: some View {
        NavigationStack{
                VStack(spacing: 16) {
                    Text("Scan Journal Page").font(.title).bold()
                    // Image Preview
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 500)
                            .cornerRadius(10)
                    } else {
                        Text("No Image Selected")
                            .foregroundColor(.gray)
                            .frame(height: 500)
                            .frame(maxWidth: .infinity)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                    }
                    
                    if isLoading {
                        ProgressView("Extracting text...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    }
                    
                    HStack {
                        Button(action: { isImagePickerPresented = true }) {
                            Text("Choose Image")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: processImage) {
                            Text("Extract Text")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedImage != nil ? Color.green : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .disabled(selectedImage == nil)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationDestination(isPresented: $isShowingResult) { 
                    OCRResultView(recognizedText: recognizedText)
                }
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(image: $selectedImage)
                }
            
        }
    }
    
    // Process image and extract text
    private func processImage() {
        guard let image = selectedImage else { return }
        
        isLoading = true
        
        ocrManager.recognizeText(from: image) { extractedText in
            DispatchQueue.main.async {
                isLoading = false
                recognizedText = extractedText
                isShowingResult = true
            }
        }
    }
}

struct OCRView_Previews: PreviewProvider {
    static var previews: some View {
        OCRView()
    }
}

