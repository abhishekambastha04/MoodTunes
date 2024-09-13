//
//  LoginView.swift
//  MoodTunesFE
//
//  Created by Abhishek Ambastha on 9/12/24.
//

import SwiftUI
 
struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var loginMessage: String = ""

    var body: some View {
        VStack {
            
            Spacer()
            // Use the imported logo image
            Image("MoodTunes")
                .resizable()
                .scaledToFit() // Maintain aspect ratio
                .frame(width: 300, height: 250)
                .cornerRadius(40) // Round the corners
                .shadow(color: .gray, radius: 10, x: 0, y: 5) // Add shadow
                .padding() // Add padding around the image
            
            Spacer()
            
            TextField("Email", text: $email)
                .padding()
                .background(Color.white)
                .cornerRadius(5.0)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color.white)
                .cornerRadius(5.0)
            
            Button(action: {
                login()
            }) {
                Text("Login")
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200, height: 50)
                    .background(Color.green)
                    .cornerRadius(10.0)
            }
            .padding(.top, 20)
            
            Text(loginMessage)
                .padding()
                .foregroundColor(loginMessage == "Login successful" ? .green : .red)
        }
        .padding()
        .background(Color.green.opacity(0.2)) // dark green background
    }
    
    func login() {
        guard let url = URL(string: "http://localhost:5001/login") else { return } // Point to your Flask backend
        
        let loginData = ["email": email, "password": password]
        
        guard let requestBody = try? JSONSerialization.data(withJSONObject: loginData) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Network error:", error?.localizedDescription ?? "")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                // Handle successful login
                if let result = try? JSONDecoder().decode([String: String].self, from: data) {
                    DispatchQueue.main.async {
                        loginMessage = "Login successful"
                    }
                }
            } else {
                // Handle login failure
                if let result = try? JSONDecoder().decode([String: String].self, from: data) {
                    DispatchQueue.main.async {
                        loginMessage = result["error"] ?? "Login failed"
                    }
                }
            }
        }.resume()
    }
}
