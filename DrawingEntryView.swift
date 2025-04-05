import Foundation
import SwiftUI

struct ArtSelectionView: View {
    var body: some View {
            VStack(spacing: 20) {
                Text("Create an Art Entry")
                    .font(.title)
                    .bold()
                    .padding(.top, 20)
                
                // Upload Art Button
                NavigationLink(destination: UploadArtView()) {
                    HStack {
                        Image(systemName: "photo.fill.on.rectangle.fill")
                        Text("Upload Artwork")
                            .bold()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                // Draw Art Button
                NavigationLink(destination: DrawArtView()) {
                    HStack {
                        Image(systemName: "pencil.tip.crop.circle")
                        Text("Draw on Canvas")
                            .bold()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Art Entry")
    }
}

struct ArtSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ArtSelectionView()
    }
}
