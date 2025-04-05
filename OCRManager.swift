import SwiftUI
import Vision
import UIKit

class OCRManager {
    func recognizeText(from image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            DispatchQueue.main.async { completion("Error: Could not convert UIImage to CGImage.") }
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion("Error: \(error.localizedDescription)")
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    completion("No text found.")
                    return
                }
                
                let recognizedText = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")
                
                completion(recognizedText.isEmpty ? "No text detected." : recognizedText)
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true 
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async { completion("Failed to process image.") }
            }
        }
    }
}
