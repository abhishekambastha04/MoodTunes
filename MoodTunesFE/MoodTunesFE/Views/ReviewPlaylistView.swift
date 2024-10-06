//
//  ReviewPlaylistView.swift
//  MoodTunesFE
//
//  Created by Abhishek Ambastha on 10/5/24.
//

import SwiftUI

//struct Track: Identifiable {
//    let id: String
//    let name: String
//    let artist: String
//}

struct ReviewPlaylistView: View {
    let playlist: [Track]
    
    var body: some View {
        VStack {
            Text("Your Playlist")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            List {
                ForEach(Array(playlist.enumerated()), id: \.element.id) { index, track in
                    HStack {
                        Text("\(index + 1)")
                            .foregroundColor(.white)
                            .frame(width: 30)
                        VStack(alignment: .leading) {
                            Text(track.name)
                                .font(.headline)
                            Text(track.artist)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .listRowBackground(index % 2 == 0 ? Color.green.opacity(0.7) : Color.green.opacity(0.3))
                }
            }
            .listStyle(PlainListStyle())
        }
    }
}

struct ReviewPlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewPlaylistView(playlist: [
            Track(id: "1", name: "Song 1", artist: "Artist 1"),
            Track(id: "2", name: "Song 2", artist: "Artist 2"),
            Track(id: "3", name: "Song 3", artist: "Artist 3"),
            Track(id: "4", name: "Song 4", artist: "Artist 4"),
            Track(id: "5", name: "Song 5", artist: "Artist 5")
        ])
    }
}
