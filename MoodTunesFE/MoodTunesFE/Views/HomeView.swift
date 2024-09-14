//
//  HomeView.swift
//  MoodTunesFE
//
//  Created by Abhishek Ambastha on 9/14/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Spacer() // Pushes content to the center
            
            Text("Welcome to MoodTunes")
                .font(.largeTitle)
                .padding(.bottom, 50) // Adds space below the title
            
            // "View Your Playlist History" Button
            NavigationLink(destination: PlaylistHistoryView()) {
                Text("View Your Playlist History")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.bottom, 20) // Adds space between the buttons
            
            // "Take a Photo/Video" Button
            NavigationLink(destination: CaptureView()) {
                Text("Take a Photo/Video")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            
            Spacer() // Pushes content to the center
        }
        .padding()
        .navigationTitle("MoodTunes") // Title in the navigation bar
        .background(
            Image("lightgreen")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
}

