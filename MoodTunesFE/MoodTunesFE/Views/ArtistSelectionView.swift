//
//  ArtistSelectionView.swift
//  MoodTunesFE
//
//  Created by Abhishek Ambastha on 9/19/24.
//

import SwiftUI

struct ArtistSelectionView: View {
    let accessToken: String
    let detectedEmotion: [[String: Any]]
    @State private var searchText: String = ""
    @State private var searchResults: [Artist] = []
    @State private var selectedArtists: [Artist] = []
    @State private var isGeneratingPlaylist = false
    // playlist stuff
    @State private var playlist: [Track] = [] // Store the playlist here
    @State private var isPlaylistReady = false
    
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
                
                    if selectedArtists.count >= 5 && isGeneratingPlaylist == false {
                        Button(action: {
                        isGeneratingPlaylist = true
                        generatePlaylist()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            isGeneratingPlaylist = false
                        }
                    }) {
                        Text("Generate Playlist")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.top, 20)
                        }
                        NavigationLink(
                            destination: ReviewPlaylistView(playlist: playlist, accessToken: accessToken),
                            isActive: $isPlaylistReady  // Bind the navigation to the state
                        ) {
                            EmptyView()
                        }
                    }
                    else if isGeneratingPlaylist {
                        VStack {
                            ProgressView()  // Circular rotating animation
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)  // You can adjust the size if needed
                                .padding(.top, 20)

                            Text("Generating Playlist...")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.top, 10)
                        }
                    }
                }
            }
            Spacer()
        }
        .navigationBarTitle("Artist Selection", displayMode: .inline)
    }
    
    // send data to backend to generate playlist
    func generatePlaylist() {
        guard let url = URL(string: "http://192.168.0.84:5001/generate_playlist") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Prepare the body data for the request
        let artistIds = selectedArtists.map { $0.id }
        let body: [String: Any] = [
            "detectedEmotion": detectedEmotion,
            "selectedArtists": artistIds,
            "accessToken": accessToken
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Failed to serialize JSON body: \(error)")
            return
        }
        // Make the API call
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    guard let data = data else {
                        print("No data received")
                        return
                    }
                    // Decode the playlist from JSON
                    do {
                        let playlistResponse = try JSONDecoder().decode(PlaylistResponse.self, from: data)
                        DispatchQueue.main.async {
                            self.playlist = playlistResponse.tracks
                            self.isPlaylistReady = true // Playlist is ready, trigger navigation
                        }
                    } catch {
                        print("Failed to decode playlist: \(error)")
                    }
                } else {
                    print("Error: Server returned status code \(httpResponse.statusCode)")
                }
            }
        }.resume()
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

struct PlaylistResponse: Codable {
    let tracks: [Track]
}

// Track model to represent each song in the playlist
struct Track: Identifiable, Codable {
    let id: String
    let name: String
    let artist: String
}
