//
//  ArtistSelectionView.swift
//  MoodTunesFE
//
//  Created by Abhishek Ambastha on 9/19/24.
//

import SwiftUI

struct ArtistSelectionView: View {
    let accessToken: String
    @State private var searchText: String = ""
    @State private var searchResults: [Artist] = []
    @State private var selectedArtists: [Artist] = []
    
    var body: some View {
        VStack {
            // Header text
            Text("Select 5-6 Artists")
                .font(.largeTitle)
                .bold()
                .padding(.top, 20)
            
            // Search bar
            TextField("Search for an artist...", text: $searchText, onEditingChanged: { _ in
                if searchText.count >= 1 {
                    fetchArtists(query: searchText)
                }
            })
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal)

            // Display the search results in a scrollable list
            if !searchResults.isEmpty {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(searchResults) { artist in
                            Button(action: {
                                if selectedArtists.count < 6 && !selectedArtists.contains(where: { $0.id == artist.id }) {
                                    selectedArtists.append(artist)
                                }
                            }) {
                                Text(artist.name)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray4))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
            }

            // Display selected artists
            if !selectedArtists.isEmpty {
                VStack {
                    Text("Selected Artists:")
                        .font(.headline)
                        .padding(.top, 10)

                    ForEach(selectedArtists) { artist in
                        Text(artist.name)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                }
            }
            
            Spacer()
        }
        .navigationBarTitle("Artist Selection", displayMode: .inline)
    }

    // Fetch artist data from Spotify API based on user input
    func fetchArtists(query: String) {
        guard let url = URL(string: "https://api.spotify.com/v1/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&type=artist") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let result = try? JSONDecoder().decode(SpotifySearchResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.searchResults = result.artists.items
                }
            }
        }.resume()
    }
}

// Artist model to decode JSON data
struct Artist: Identifiable, Codable {
    let id: String
    let name: String
}

struct SpotifySearchResponse: Codable {
    struct Artists: Codable {
        let items: [Artist]
    }
    let artists: Artists
}
