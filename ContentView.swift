import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    VStack {
                        Image(systemName: "book.fill")
                            .font(.system(size: 50, weight: .bold))
                        Text("Journals")
                            .font(.system(size: 22, weight: .bold))
                    }
                }
                .tag(0)

            NewEntryView()
                .tabItem {
                    VStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 50, weight: .bold))
                        Text("New Entry")
                            .font(.system(size: 22, weight: .bold))
                    }
                }
                .tag(1)

            EntryViewerView()
                .tabItem {
                    VStack {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 50, weight: .bold))
                        Text("Past Entries")
                            .font(.system(size: 22, weight: .bold))
                    }
                }
                .tag(2)

            InsightsView()
                .tabItem {
                    VStack {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 50, weight: .bold))
                        Text("Insights")
                            .font(.system(size: 22, weight: .bold))
                    }
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    VStack {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 50, weight: .bold))
                        Text("Settings")
                            .font(.system(size: 22, weight: .bold))
                    }
                }
                .tag(4)
        }
        .background(Color.black.ignoresSafeArea()) // ✅ Black Background
        .toolbarBackground(Color.black, for: .tabBar) // ✅ Ensures TabView is fully black
        .accentColor(.blue) // ✅ Highlights selected tab in blue
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
