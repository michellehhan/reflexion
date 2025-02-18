//
//  DrawingEntryView.swift
//  reflexion
//
//  Created by Michelle Han on 2/17/25.
//

import Foundation
import SwiftUI

struct DrawingEntryView: View {
    var body: some View {
        VStack {
            Text("Drawing Entry View")
                .font(.title)

            Toggle("High Contrast Mode", isOn: .constant(false))
                .padding()

            Toggle("Enable Face ID", isOn: .constant(true))
                .padding()
        }
    }
}

struct DrawingEntryView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingEntryView()
    }
}
