
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 80) {
                Text("⚙️ Settings")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)
                
                // Appearance Settings
                VStack(spacing: 15) {
                    Text("🌗 Select Theme")
                        .font(.title2)
                        .bold()
                    
                    Menu {
                        ForEach(ThemeManager.Theme.allCases, id: \.self) { theme in
                            Button(action: { themeManager.selectedTheme = theme }) {
                                Text(theme.rawValue)
                            }
                        }
                    } label: {
                        Text("\(themeManager.selectedTheme.rawValue)")
                            .font(.title3)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(12)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.4)
                }
                .padding()
                .frame(width: UIScreen.main.bounds.width * 0.65)
                .background(
                    Color(UIColor { $0.userInterfaceStyle == .dark ? .black : .white })
                        .opacity(0.9)
                )
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 2)
                
                // Future Developments
                VStack(alignment: .leading, spacing: 15) {
                    Text("💡 Future Ideas from the Developer")
                        .font(.title)
                        .bold()
                        .padding(.bottom, 5)
                    
                    bulletPoint(text: "🔠 Increased font sizes for better readability")
                    bulletPoint(text: "🔳 High contrast mode for accessibility")
                    bulletPoint(text: "🔒 Face ID security for past entries")
                    bulletPoint(text: "🫀 Connect to Apple Health for mood tracking")
                }
                .padding()
                .frame(width: UIScreen.main.bounds.width * 0.65) 
                .background(
                    Color(UIColor { $0.userInterfaceStyle == .dark ? .black : .white })
                        .opacity(0.9)
                )
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 2)
                
                // Thank You
                Text("Thank you for using Reflexion! 🫶")
                    .font(.title2)
                    .bold()
                    .padding()
                    .frame(width: UIScreen.main.bounds.width * 0.65)
                    .background(Color(hex: "#926799")) 
                    .foregroundColor(Color(hex: "#FAF3F3")) 
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.top, 10) 
                
                Spacer().frame(height: 50)
            }
            .padding()
        }
        .navigationTitle("Settings")
        .onAppear {
            print("Current theme: \(themeManager.selectedTheme.rawValue)")
        }
    }
    
    private func bulletPoint(text: String) -> some View {
        HStack(alignment: .center) {
            Text("•")
                .font(.title)
                .foregroundColor(.blue)
            Text(text)
                .font(.title3)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ThemeManager())
    }
}
