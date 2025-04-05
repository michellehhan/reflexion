import SwiftUI
import Charts

struct InsightsView: View {
    @State private var selectedTimeframe: String = "Last Week"
    let timeframes = ["Last Week", "Last Month", "Last Year", "All Time"]
    
    @ObservedObject var journalManager = JournalDatabaseManager.shared
    
    var filteredEntries: [JournalEntry] {
        let now = Date()
        let calendar = Calendar.current
        
        return journalManager.entries.filter { entry in
            let entryDate = entry.date
            
            switch selectedTimeframe {
            case "Last Week":
                return calendar.isDate(entryDate, equalTo: now, toGranularity: .weekOfYear)
            case "Last Month":
                return calendar.isDate(entryDate, equalTo: now, toGranularity: .month)
            case "Last Year":
                return calendar.isDate(entryDate, equalTo: now, toGranularity: .year)
            default:
                return true 
            }
        }
    }
    
    var moodCounts: [String: Int] {
        let moods = ["Joyful 😊", "Calm 🌿", "Energetic ⚡", "Stressed 😖", "Sad 😞", "Reflective 🤔"]
        var counts = Dictionary(uniqueKeysWithValues: moods.map { ($0, 0) })
        
        for entry in filteredEntries {
            if let mood = entry.emotionTag {
                counts[mood, default: 0] += 1
            }
        }
        
        return counts
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Text("Mood Insights 📊")
                    .font(.title)
                    .bold()
                    .padding(.top, 20)
                
                // Timeframe Selector
                Menu {
                    ForEach(timeframes, id: \.self) { timeframe in
                        Button(timeframe) {
                            selectedTimeframe = timeframe
                        }
                    }
                } label: {
                    Text("🔄 Select Timeframe: \(selectedTimeframe)")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                // Mood Trends Over Time Bar Chart
                Text("📊 Mood Distribution (Bar)")
                    .font(.title2)
                    .bold()
                
                if filteredEntries.isEmpty {
                    Text("No data available for \(selectedTimeframe).")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    MoodBarChart(moodCounts: moodCounts)
                        .frame(height: 300)
                        .padding(.horizontal)
                }
                
                // Mood Distr Pie Chart
                Text("🥧 Mood Distribution (Pie)")
                    .font(.title2)
                    .bold()
                
                if filteredEntries.isEmpty {
                    Text("No data available for \(selectedTimeframe).")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    MoodPieChart(moodCounts: moodCounts)
                        .frame(height: 350)
                        .padding(.horizontal)
                        .animation(.easeInOut(duration: 3.5), value: moodCounts)
                }
                
                Spacer().frame(height: 50)
            }
            .padding()
        }
        .navigationTitle("Mood Insights")
    }
}

// Mood Trends Bar Chart
struct MoodBarChart: View {
    let moodCounts: [String: Int]
    
    var body: some View {
        Chart {
            ForEach(moodCounts.sorted(by: { $0.value > $1.value }), id: \.key) { mood, count in
                    BarMark(
                        x: .value("Mood Count", mood),
                        y: .value("Count", count)
                    )
                    .foregroundStyle(colorForMood(mood))
                    .cornerRadius(5)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .font(.subheadline)
                    .offset(y: 10)
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .font(.subheadline)
            }
        }
        .animation(.easeInOut(duration: 3.5), value: moodCounts)
    }
}

// Mood Distribution Pie Chart
struct MoodPieChart: View {
    let moodCounts: [String: Int]
    @State private var selectedMood: String? = nil
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                let total = moodCounts.values.reduce(0, +)
                let slices = createSlices(for: moodCounts, total: total)
                
                ZStack {
                    ForEach(slices.indices, id: \.self) { index in
                        let slice = slices[index]
                        
                        PieSliceView(
                            slice: slice,
                            center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2),
                            radius: min(geometry.size.width, geometry.size.height) / 2
                        )
                        .onTapGesture {
                            selectedMood = slice.mood
                        }
                    }
                }
            }
            .frame(width: 300, height: 300)
            
            if let mood = selectedMood {
                Text("\(mood) - \(moodCounts[mood] ?? 0) Entries (\(percentage(for: mood))%)")
                    .font(.headline)
                    .padding(.top, 10)
            }
            
            HStack(spacing: 15) {
                ForEach(moodCounts.keys.sorted(), id: \.self) { mood in
                    HStack {
                        Circle()
                            .fill(colorForMood(mood))
                            .frame(width: 18, height: 18) 
                        Text(mood)
                            .font(.headline) 
                    }
                }
            }
            .padding(.top, 10)
        }
    }
    
    private func createSlices(for moodCounts: [String: Int], total: Int) -> [PieSlice] {
        var slices: [PieSlice] = []
        var startAngle: Angle = .degrees(0)
        
        for (mood, count) in moodCounts {
            let proportion = Double(count) / Double(total)
            let endAngle = startAngle + .degrees(proportion * 360)
            let slice = PieSlice(startAngle: startAngle, endAngle: endAngle, color: colorForMood(mood), mood: mood)
            slices.append(slice)
            startAngle = endAngle
        }
        
        return slices
    }
    
    private func percentage(for mood: String) -> String {
        let total = moodCounts.values.reduce(0, +)
        let count = moodCounts[mood] ?? 0
        return String(format: "%.1f", (Double(count) / Double(total)) * 100)
    }
}

// Pie Slice Data Model
struct PieSlice {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    let mood: String
}

// Pie Slice View
struct PieSliceView: View {
    let slice: PieSlice
    let center: CGPoint
    let radius: CGFloat
    
    var body: some View {
        Path { path in
            path.move(to: center)
            path.addArc(center: center, radius: radius, startAngle: slice.startAngle, endAngle: slice.endAngle, clockwise: false)
            path.closeSubpath()
        }
        .fill(slice.color)
    }
}

// Mood Color Helper
func colorForMood(_ mood: String) -> Color {
    switch mood {
    case "Joyful 😊": return .yellow
    case "Calm 🌿": return .green
    case "Energetic ⚡": return .orange
    case "Stressed 😖": return .red
    case "Sad 😞": return .blue
    case "Reflective 🤔": return .purple
    default: return .gray
    }
}

struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        InsightsView()
    }
}
