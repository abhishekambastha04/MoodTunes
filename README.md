# MoodTunes
Personalized Playlist Generator

MoodTunes is a mobile app that generates personalized playlists based on your mood. Users can upload a selfie or a short video clip, and using cloud machine learning services for facial recognition and emotion analysis, the app determines the user's emotional state. It then utilizes the Spotify API to generate a playlist that matches the user's mood.

Tech Stack
* Frontend: SwiftUI
* Backend: Flask (Python)
* Cloud Services: AWS Rekognition (for facial recognition and emotion analysis), AWS Cognito (user authentication)
* Music API: Spotify API
* Storage: (To be decided, e.g., S3)
* Database: (MongoDB) for Playlist History, Redis for Caching requests

Features
* Capture or upload an image or video to analyze your mood.
* Generate a personalized Spotify playlist based on the detected mood.
* Store user preferences and playlist history.