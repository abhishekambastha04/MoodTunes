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
    @State private var showHomeView = false
    
    var body: some View {
        NavigationView {
            VStack {
                Image("MoodTunes")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 250)
                    .cornerRadius(40)
                    .shadow(color: .gray, radius: 10, x: 0, y: 5)
                    .padding()
                
                Spacer()
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5.0)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5.0)
                
                Button(action: login) {
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
                
                Spacer()
                
                // Sign Up option
                HStack {
                    Text("Don't have an account?")
                    NavigationLink(destination: SignUpView()) {
                        Text("Sign Up Now")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 40)
                
                NavigationLink(destination: HomeView(), isActive: $showHomeView) {
                    EmptyView()
                }
            }
            .padding()
            .background(
                Image("lightgreen")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
        }
    }
    
    func login() {
        guard let url = URL(string: "http://192.168.0.84:5001/login") else {
            print("Invalid URL")
            return
        }
        
        let loginData = ["email": email, "password": password]
        
        guard let requestBody = try? JSONSerialization.data(withJSONObject: loginData) else {
            print("Failed to serialize request body")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Network error:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                // Check the response JSON for the message
                DispatchQueue.main.async {
                    print("Login successful block reached")
                    loginMessage = "Login successful"
                    showHomeView = true
                }
                
            } else {
                DispatchQueue.main.async {
                    print("Login failed")
                    loginMessage = "Login failed. Invalid username and/or password"
                }
            }
        }.resume()
    }
}
