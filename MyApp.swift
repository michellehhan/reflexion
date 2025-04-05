import SwiftUI

class ThemeManager: ObservableObject {
    @Published var selectedTheme: Theme = .system
    
    enum Theme: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System Default"
    }
    
    func updateTheme(to theme: Theme) {
        selectedTheme = theme
    }
}

@main
struct MyApp: App {
    @StateObject var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager) 
                .preferredColorScheme(themeManager.selectedTheme == .dark ? .dark : .light)
        }
    }
}
