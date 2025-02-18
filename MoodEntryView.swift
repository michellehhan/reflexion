//
//  MoodEntryView.swift
//  reflexion
//
//  Created by Michelle Han on 2/17/25.
//

import Foundation
import SwiftUI

struct MoodEntryView: View {
    var body: some View {
        VStack {
            Text("Mood Entry View")
                .font(.title)

            Toggle("High Contrast Mode", isOn: .constant(false))
                .padding()

            Toggle("Enable Face ID", isOn: .constant(true))
                .padding()
        }
    }
}

struct MoodEntryView_Previews: PreviewProvider {
    static var previews: some View {
        MoodEntryView()
    }
}

