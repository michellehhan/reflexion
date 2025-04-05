import SwiftUI

struct MoodEntryView: View {
    @State private var selectedMood: String? = nil
    @State private var energyLevel: Double = 3
    @State private var focusLevel: Double = 3
    @State private var sleepQuality: Double = 3
    @State private var socialConnection: Double = 3
    @State private var experiencedStress: Bool? = nil
    @State private var stressLevel: Double = 3
    @State private var smileToday: Bool? = nil
    @State private var smileReason: String = ""
    @State private var gratitudeToday: Bool? = nil
    @State private var gratitudeReason: String = ""
    @State private var focusTomorrow: Bool? = nil
    @State private var focusGoal: String = ""
    
    @State private var isSaving = false
    @State private var showSuccessMessage = false
    
    @ObservedObject var journalManager = JournalDatabaseManager.shared
    
    let moodOptions = ["Joyful 😊", "Calm 🌿", "Energetic ⚡", "Stressed 😖", "Sad 😞", "Reflective 🤔"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 35) {
                
                Text("How are you feeling today?")
                    .font(.title)
                    .bold()
                    .padding(.top, 20)
                
                // Mood Selection (Required)
                VStack {
                    Text("Select Your Mood")
                        .font(.title2)
                    
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 15) {
                        ForEach(moodOptions, id: \.self) { mood in
                            Button(action: { selectedMood = mood }) {
                                Text(mood)
                                    .frame(maxWidth: .infinity, minHeight: 65)
                                    .background(selectedMood == mood ? Color(hex: "#f6d9ff") : Color.gray.opacity(0.2))
                                    .foregroundColor(Color(.label))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Energy Level
                sliderQuestion("How was your energy today?", value: $energyLevel, color: .purple, description: energyDescription(energyLevel))
                
                // Focus Level
                sliderQuestion("How was your focus today?", value: $focusLevel, color: .blue, description: focusDescription(focusLevel))
                
                // Sleep Quality 
                sliderQuestion("How well did you sleep last night?", value: $sleepQuality, color: .orange, description: sleepDescription(sleepQuality))
                
                // Social Connection
                sliderQuestion("Did you feel socially connected or isolated today?", value: $socialConnection, color: .green, description: socialDescription(socialConnection))
                
                // Did anything make you smile?
                yesNoQuestion("Did anything make you smile today?", selectedOption: $smileToday)
                
                if smileToday == true {
                    textInputField("What made you smile?", text: $smileReason)
                }
                
                // Stress & Frustration
                yesNoQuestion("Did you experience any stress or frustration today?", selectedOption: $experiencedStress)
                
                if experiencedStress == true {
                    sliderQuestion("Rate Your Stress Level", value: $stressLevel, color: .red, description: stressDescription(stressLevel))
                }
                
                // Gratitude
                yesNoQuestion("Is there anything that you're grateful for today?", selectedOption: $gratitudeToday)
                
                if gratitudeToday == true {
                    textInputField("What are you grateful for?", text: $gratitudeReason)
                }
                
                // Focus Tomorrow
                yesNoQuestion("Is there anything you’d like to focus on tomorrow?", selectedOption: $focusTomorrow)
                
                if focusTomorrow == true {
                    textInputField("What would you like to focus on?", text: $focusGoal)
                }
                
                // Save Entry Button
                Button(action: saveToDatabase) {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        Text(" Save to Journal")
                            .bold()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isSaving ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(selectedMood == nil || isSaving)
                .padding(.bottom, 80)
            }
            .padding()
        }
        .navigationTitle("Quick Mood Entry")
        .alert(isPresented: $showSuccessMessage) { 
            Alert(
                title: Text("Saved!"),
                message: Text("Your mood entry has been recorded."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // Helper Functions
    private func sliderQuestion(_ title: String, value: Binding<Double>, color: Color, description: String) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.title3).bold()
            
            Slider(value: value, in: 1...5, step: 1)
                .accentColor(color)
                .padding()
            
            Text(description)
                .font(.subheadline)
                .bold()
        }
    }
    
    private func yesNoQuestion(_ title: String, selectedOption: Binding<Bool?>) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.title3).bold()
            
            HStack(spacing: 20) {
                yesNoButton("Yes", isSelected: selectedOption.wrappedValue == true) { selectedOption.wrappedValue = true }
                yesNoButton("No", isSelected: selectedOption.wrappedValue == false) { selectedOption.wrappedValue = false }
            }
        }
    }
    
    private func yesNoButton(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .frame(width: 100, height: 60)
                .background(isSelected ? Color(hex: "#f6d9ff") : Color.gray.opacity(0.2))
                .foregroundColor(Color(.label))
                .cornerRadius(12)
        }
    }
    
    private func textInputField(_ title: String, text: Binding<String>) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.headline)
            TextField("", text: text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .frame(height: 50)
        }
    }
    
    private func saveToDatabase() {
        guard let mood = selectedMood else { return } 
        
        isSaving = true
        
        var moodEntrySummary = """
    Mood: \(mood)
    Energy: \(energyDescription(energyLevel))
    Focus: \(focusDescription(focusLevel))
    Sleep: \(sleepDescription(sleepQuality))
    Social: \(socialDescription(socialConnection))
    """
        
        if let experiencedStress = experiencedStress {
            moodEntrySummary += "\nStress: \(experiencedStress ? stressDescription(stressLevel) : "No Stress")"
        }
        
        if let smileToday = smileToday {
            moodEntrySummary += "\nSmile Today: \(smileToday ? "Yes" : "No")"
            if smileToday, !smileReason.isEmpty {
                moodEntrySummary += " - \(smileReason)"
            }
        }
        
        if let gratitudeToday = gratitudeToday {
            moodEntrySummary += "\nGratitude: \(gratitudeToday ? "Yes" : "No")"
            if gratitudeToday, !gratitudeReason.isEmpty {
                moodEntrySummary += " - \(gratitudeReason)"
            }
        }
        
        if let focusTomorrow = focusTomorrow {
            moodEntrySummary += "\nFocus Tomorrow: \(focusTomorrow ? "Yes" : "No")"
            if focusTomorrow, !focusGoal.isEmpty {
                moodEntrySummary += " - \(focusGoal)"
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let entry = JournalEntry(
                id: UUID(),
                date: Date(),
                type: .moodEntry, 
                content: moodEntrySummary, 
                fileURL: nil,
                emotionTag: mood
            )
            
            journalManager.saveJournalEntry(entry: entry)
            journalManager.fetchAndUpdateEntries()
            
            isSaving = false
            showSuccessMessage = true
        }
    }
    
    private func energyDescription(_ value: Double) -> String {
        ["Exhausted", "Low Energy", "Neutral", "Energetic", "Supercharged!"][Int(value) - 1]
    }
    
    private func focusDescription(_ value: Double) -> String {
        ["Very Distracted", "Unfocused", "Neutral", "Focused", "Deep Work"][Int(value) - 1]
    }
    
    private func sleepDescription(_ value: Double) -> String {
        ["Terrible Sleep", "Poor", "Average", "Good", "Amazing"][Int(value) - 1]
    }
    
    private func socialDescription(_ value: Double) -> String {
        ["Very Isolated", "Somewhat Isolated", "Neutral", "Somewhat Connected", "Very Connected"][Int(value) - 1]
    }
    
    private func stressDescription(_ value: Double) -> String {
        ["No Stress", "Mild", "Moderate", "High", "Overwhelmed"][Int(value) - 1]
    }
}

struct MoodEntryView_Previews: PreviewProvider {
    static var previews: some View {
        MoodEntryView()
    }
}
