//
//  HomeView.swift
//  reflexion
//
//  Created by Michelle Han on 2/17/25.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack {
            // 🏠 Welcome Section
            VStack(spacing: 10) {
                Text("Welcome to Reflexion")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)

                Text("Journaling, your way.")
                    .font(.title2)
                    .foregroundColor(.gray)

                // ➕ Start a New Journal Entry
                NavigationLink(destination: NewEntryView()) {
                    Text("Start a New Journal Entry")
                        .bold()
                        .padding()
                        .frame(maxWidth: 400)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()

        }
    }
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
