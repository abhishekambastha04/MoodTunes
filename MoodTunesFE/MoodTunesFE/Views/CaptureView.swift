//
//  CaptureView.swift
//  MoodTunesFE
//
//  Created by Abhishek Ambastha on 9/14/24.
//

import SwiftUI
import UIKit

struct CaptureView: View {
    @State private var showImagePicker = false
    @State private var pickerType: ImagePicker.PickerType?
    @State private var selectedImage: UIImage?
    @State private var isUploadButtonSelected = false
    @State private var isSelfieButtonSelected = false
    @State private var isUploading = false
    @State private var uploadResult: String?
    // spotify variables
    @State private var isLoggedIn = false
    @State private var accessToken: String = ""

    var body: some View {
        ZStack {
            Image("lightgreen")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.blue, lineWidth: 6)
                        )
                        .shadow(radius: 10)
                        .padding(10)
                } else {
                    Text("No photo selected")
                        .padding()
                }

                HStack {
                    Button(action: {
                        pickerType = .photoLibrary
                        showImagePicker = true
                        isUploadButtonSelected.toggle()
                    }) {
                        Text("Upload Photo")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 125, height: 100)
                            .background(Color.darkGreen)
                            .cornerRadius(10)
                            .shadow(radius: isUploadButtonSelected ? 5 : 0)
                            .scaleEffect(isUploadButtonSelected ? 1.1 : 1)
                            .offset(y: isUploadButtonSelected ? -5 : 0)
                    }

                    Button(action: {
                        pickerType = .camera
                        isSelfieButtonSelected.toggle()
                        showImagePicker = true
                    }) {
                        Text("Take Selfie")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 125, height: 100)
                            .background(Color.darkGreen)
                            .cornerRadius(10)
                            .shadow(radius: isSelfieButtonSelected ? 5 : 0)
                            .scaleEffect(isSelfieButtonSelected ? 1.1 : 1)
                            .offset(y: isSelfieButtonSelected ? -5 : 0)
                    }
                    .padding()
                }

                Button(action: {
                    if let selectedImage = selectedImage {
                        isUploading = true
                        uploadImage(selectedImage)
                    }
                }) {
                    Text("Next")
                        .padding()
                        .background(selectedImage == nil ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(selectedImage == nil) // Disable the button if no image is selected
                .padding()

                if isUploading {
                    ProgressView("Uploading...")
                        .padding()
                }

                if let result = uploadResult {
                    Text("Upload result: \(result)")
                        .padding()
                }
                
                if uploadResult == "Upload successful!" {
                    if isLoggedIn {
                        Text("Logged in with Spotify!")
                            .font(.largeTitle)
                            .padding()

                        Text("Access Token:")
                        Text(accessToken)
                        .foregroundColor(.green)
                        .padding()
                    }
                    else {
                        Button(action: {
                            openSpotifyLogin()  // Redirect to Spotify OAuth
                        }) {
                            Text("Continue with Spotify")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                }
                
            }
            .padding()
        }
        .sheet(isPresented: $showImagePicker) {
            if let pickerType = pickerType {
                ImagePicker(pickerType: pickerType, selectedImage: $selectedImage)
            }
        }
        .onOpenURL {  url in
            handleSpotifyRedirect(url)
        }
    }
    
    
    func handleSpotifyRedirect(_ url: URL) {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           let queryItems = components.queryItems,
           let token = queryItems.first(where: { $0.name == "token" })?.value {
            // Store the access token
            self.accessToken = token
            self.isLoggedIn = true
        } else {
            print("Failed to get access token from the redirect URL.")
        }
    }
    
    func openSpotifyLogin() {
        if let url = URL(string: "http://172.16.225.108:5001/spotify_login") {
            UIApplication.shared.open(url)
        }
    }

    private func uploadImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to Data")
            return
        }

        let url = URL(string: "http://172.16.225.108:5001/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Create boundary and headers
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Build body data
        var body = Data()

        // Add the image data to the request body
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"selfie.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)

        // End the body
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        // Create URLSession to upload the image
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isUploading = false
            }

            if let error = error {
                print("Error uploading image: \(error)")
                DispatchQueue.main.async {
                    uploadResult = "Failed to upload image."
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error with response status code")
                DispatchQueue.main.async {
                    uploadResult = "Upload failed. Please try again."
                }
                return
            }

            if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                print("Response from server: \(jsonString)")
                DispatchQueue.main.async {
                    uploadResult = "Upload successful!"
                }
            }
        }
        task.resume()
    }
}

extension Color {
    static let darkGreen = Color(red: 0.1, green: 0.5, blue: 0.2)
}

