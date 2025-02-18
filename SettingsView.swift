//
//  SettingsView.swift
//  reflexion
//
//  Created by Michelle Han on 2/17/25.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Display & Accessibility")) {
                Toggle("Use High Contrast", isOn: .constant(false)) // In practice, bind to a setting
                // More accessibility toggles or dynamic type settings...
            }
            Section(header: Text("Notifications")) {
                Toggle("Daily Reminder", isOn: .constant(true))
            }
            Section(header: Text("Security")) {
                Toggle("Use Face ID to Unlock", isOn: .constant(true))
            }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
