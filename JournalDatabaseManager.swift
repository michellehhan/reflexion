import Foundation
import SwiftUI

// Journal Database Manager
class JournalDatabaseManager: ObservableObject {
    static let shared = JournalDatabaseManager()
    
    private let userDefaultsKey = "SavedJournalEntries"
    
    // Published list of entries for real-time UI updates
    @Published var entries: [JournalEntry] = []
    
    private init() {
        entries = fetchJournalEntries()
        checkForFirstLaunch()
    }
    
    // Save or Update Journal Entry
    func saveJournalEntry(entry: JournalEntry) {
        var allEntries = fetchJournalEntries()
        
        if let index = allEntries.firstIndex(where: { $0.id == entry.id }) {
            allEntries[index] = entry // Update existing entry
        } else {
            allEntries.append(entry) // Add new entry
        }
        
        saveToUserDefaults(allEntries)
    }
    
    
    // Fetch Entries
    func fetchJournalEntries() -> [JournalEntry] {
        guard let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode([JournalEntry].self, from: savedData) else {
            return []
        }
        return decoded.sorted { $0.date > $1.date } // Sort newest --> oldest
    }
    
    func fetchAndUpdateEntries() {
        DispatchQueue.main.async {
            self.entries = self.fetchJournalEntries() 
        }
    }
    
    func saveArtEntry(imagePath: String, caption: String, type: EntryType, aiMoodEnabled: Bool) {
        let mood = aiMoodEnabled ? analyzeAIMood(for: imagePath) : nil
        
        let newEntry = JournalEntry(
            id: UUID(),
            date: Date(),
            type: type,
            content: caption,
            fileURL: imagePath,
            emotionTag: mood
        )
        
        saveJournalEntry(entry: newEntry)
        fetchAndUpdateEntries()
    }
    
    // AI Mood Analysis (prototype)
    func analyzeAIMood(for imagePath: String) -> String {
        let possibleMoods =  ["Joyful 😊", "Calm 🌿", "Energetic ⚡", "Stressed 😖", "Sad 😞", "Reflective 🤔"]
        return possibleMoods.randomElement() ?? "Neutral 😐"
    }
    
    // Save to UserDefaults
    private func saveToUserDefaults(_ entries: [JournalEntry]) {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
            DispatchQueue.main.async {
                self.entries = entries
            }
        }
    }
    
    private func checkForFirstLaunch() {
        if entries.isEmpty { 
            let exampleEntry = JournalEntry(
                id: UUID(),
                date: Date(),
                type: .text,
                content: """
                Hi Apple!  Welcome to Reflexion! 👋
                
                This is an example journal entry. Reflexion offers multiple ways to express yourself—whether through writing, speech, video, or even art. You can track your emotions over time and reflect on past entries. 
                
                Tap "New Entry" below to start journaling in a way that works best for you.
                """,
                fileURL: nil,
                emotionTag: "Reflective 🤔"
            )
            saveJournalEntry(entry: exampleEntry)
        }
    }
}
