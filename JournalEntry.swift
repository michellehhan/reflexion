import Foundation

// Journal Entry Types
enum EntryType: String, Codable {
    case text = "📝 Text"
    case audio = "🎙 Audio"
    case video = "📹 Video"
    case ocr = "📔 OCR Scanned Text"
    case drawnArt = "🎨 Drawn Art" 
    case uploadedArt = "🖼️ Uploaded Art"
    case moodEntry = "😀 Quick Mood Entry"
}

// Struct for Journal Entry
struct JournalEntry: Codable, Identifiable, Equatable { 
    let id: UUID
    let date: Date
    let type: EntryType
    let content: String // caption/transcript
    let fileURL: String? // aduio/video file path
    var emotionTag: String? //Moods
    
    static func == (lhs: JournalEntry, rhs: JournalEntry) -> Bool {
        return lhs.id == rhs.id
    }
}
