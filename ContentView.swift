import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0 
    
    var body: some View {
        ZStack {
     
            if selectedTab == 0 {
                Color(hex: "#FAF3F3")
                    .ignoresSafeArea()
            }

            VStack {
                Spacer()
                switch selectedTab {
                case 0:
                    HomeView()
                case 1:
                    NewEntryView()
                case 2:
                    EntryViewerView()
                case 3:
                    InsightsView()
                case 4:
                    SettingsView()
                default:
                    HomeView()
                }
                Spacer()
            }
            
            // Nav Bar
            VStack {
                Spacer()
                HStack {
                    CustomNavItem(icon: "book.fill", title: "Journals", tabIndex: 0, selectedTab: $selectedTab)
                    CustomNavItem(icon: "plus.circle.fill", title: "New Entry", tabIndex: 1, selectedTab: $selectedTab)
                    CustomNavItem(icon: "clock.fill", title: "Past Entries", tabIndex: 2, selectedTab: $selectedTab)
                    CustomNavItem(icon: "chart.bar.fill", title: "Insights", tabIndex: 3, selectedTab: $selectedTab)
                    CustomNavItem(icon: "gearshape.fill", title: "Settings", tabIndex: 4, selectedTab: $selectedTab)
                }
                .frame(height: 80) 
                .padding(.horizontal, 10)
                .padding(.bottom, -5)
                .background(Color(hex: "#FCEAFF"))
                .cornerRadius(20)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom) 
        }
        .edgesIgnoringSafeArea(.bottom) 
    }
}

struct CustomNavItem: View {
    let icon: String
    let title: String
    let tabIndex: Int
    @Binding var selectedTab: Int
    
    var body: some View {
        Button(action: {
            selectedTab = tabIndex 
        }) {
            VStack {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
                    .foregroundColor(selectedTab == tabIndex ? .blue : .gray)
                Text(title)
                    .font(.system(size: 14, weight: .bold)) 
                    .foregroundColor(selectedTab == tabIndex ? .blue : .gray)
            }
            .frame(maxWidth: .infinity) 
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
