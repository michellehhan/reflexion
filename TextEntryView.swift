//
//  TextEntryView.swift
//  reflexion
//
//  Created by Michelle Han on 2/17/25.
//

import Foundation
import SwiftUI

struct TextEntryView: View {
    @State private var entryText: String = "" // Stores user input
    @State private var showAlert: Bool = false // Save confirmation

    var body: some View {
        VStack {
            // 📖 Text Editor
            TextEditor(text: $entryText)
                .padding()
                .frame(height: 300)
                .border(Color.gray, width: 1)
                .cornerRadius(5)

            // 💾 Save Button
            Button(action: {
                saveEntry()
            }) {
                Text("Save Entry")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Saved!"), message: Text("Your journal entry has been saved."), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
        .navigationTitle("New Journal Entry")
        .navigationBarTitleDisplayMode(.inline)
    }

    // ✅ Simulated Save Function (Can connect to real data storage later)
    func saveEntry() {
        if !entryText.isEmpty {
            showAlert = true
            // Later, we will save this to CoreData or CloudKit
        }
    }
}

struct TextEntryView_Previews: PreviewProvider {
    static var previews: some View {
        TextEntryView()
    }
}
