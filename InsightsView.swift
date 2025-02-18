//
//  InsightsView.swift
//  reflexion
//
//  Created by Michelle Han on 2/17/25.
//

import Foundation
import SwiftUI

struct InsightsView: View {
    var body: some View {
        VStack {
            Text("Mood Trends")
                .font(.title)
            
            // Placeholder graph
            Rectangle()
                .frame(height: 200)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        InsightsView()
    }
}
