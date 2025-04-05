import Foundation
import SwiftUI

struct HomeView: View {
    let backgroundImg = "Home Screen.png"
    
    var body: some View {
        NavigationStack {
            GeometryReader {geometry in 
                ZStack {
                    // Background Image
                    Image(uiImage: loadImage(named: backgroundImg) ?? UIImage())
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .ignoresSafeArea()
                        .edgesIgnoringSafeArea(.all)
                        .clipped()
                        .opacity(0.85)
                        .zIndex(-1) 
                    
                    VStack {
                        Spacer()
                        
                        NavigationLink(destination: NewEntryView()) {
                            Text("Start a New Journal Entry")
                                .font(.system(size: 24, weight: .bold)) 
                                .padding()
                                .frame(width: UIScreen.main.bounds.width * 0.6, 
                                       height: (UIScreen.main.bounds.width * 0.6) * 0.13)
                                .background(Color(hex: "#926799")) 
                                .foregroundColor(Color(hex: "#FAF3F3")) 
                                .cornerRadius(30) 
                        }
                        .padding(.top, 90)
                        
                        Spacer() 
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
    }
    
    // Load Img Func
    private func loadImage(named fileName: String) -> UIImage? {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            if let image = UIImage(contentsOfFile: fileURL.path) {
                return image
            }
        }
        return UIImage(named: fileName) 
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b, a: Double
        switch hex.count {
        case 6: // RGB (No Alpha)
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
            a = 1.0
        case 8: // ARGB
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
            a = Double((int >> 24) & 0xFF) / 255.0
        default:
            r = 1.0
            g = 1.0
            b = 1.0
            a = 1.0
        }
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
