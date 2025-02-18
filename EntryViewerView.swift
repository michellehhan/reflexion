//
//  EntryViewerView.swift
//  reflexion
//
//  Created by Michelle Han on 2/17/25.
//

import Foundation
import SwiftUI

struct EntryViewerView: View {
    var body: some View {
        VStack {
            Text("Past Journals")
                .font(.title)
            
            List {
                ForEach(0..<5, id: \.self) { _ in
                    HStack {
                        Image(systemName: "note.text")
                        Text("Sample Entry")
                        Spacer()
                        Text("🟢 Happy")
                    }
                }
            }
        }
    }
}

struct EntryViewerView_Previews: PreviewProvider {
    static var previews: some View {
        EntryViewerView()
    }
}
