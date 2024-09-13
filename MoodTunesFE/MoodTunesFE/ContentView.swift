//
//  ContentView.swift
//  MoodTunesFE
//
//  Created by Abhishek Ambastha on 8/30/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image("MoodTunes")
                .resizable()
                .scaledToFit() // Maintain aspect ratio
                .frame(width: 300, height: 250)
                .cornerRadius(40) // Round the corners
                .shadow(color: .gray, radius: 10, x: 0, y: 5) // Add shadow
                .padding() // Add padding around the image
            Spacer() // Pushes the content to the top
        }
        .padding() // Add padding to the VStack if needed
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

