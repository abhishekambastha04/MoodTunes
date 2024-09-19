//
//  SignUpView.swift
//  MoodTunesFE
//
//  Created by Abhishek Ambastha on 9/12/24.
//

import SwiftUI

extension CharacterSet {
    static let customSymbols: CharacterSet = {
        var symbols = CharacterSet.symbols
        symbols.insert(charactersIn: "@!#$%^&*()-_=+[]{}|;:',.<>?/")
        return symbols
    }()
}

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var signupError: String?
    @State private var confirmationCode: String = ""
    @State private var isSignUpComplete = false
    @State private var showConfirmationField = false
    @State private var signUpMessage: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("Create a new account for MoodTunes")
                    .font(.title)
                    .padding()

                TextField("Email", text: $email)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5.0)
                    .padding(.bottom, 10)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5.0)
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)

                Text("Password must contain at least one uppercase letter, lowercase letter, number, and symbol. Minimum length: 6 characters.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
                
                if let error = signupError {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                if showConfirmationField {
                    TextField("Confirmation Code", text: $confirmationCode)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(5.0)
                        .padding(.top, 10)
                    
                    Button(action: confirmSignUp) {
                        Text("Confirm Sign Up")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10.0)
                    }
                    .padding(.top, 20)
                    
                } else {
                    Button(action: signUp) {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200, height: 50)
                            .background(Color.green)
                            .cornerRadius(10.0)
                    }
                    .padding(.top, 20)
                }

                Text(signUpMessage)
                    .padding()
                    .foregroundColor(signUpMessage == "Sign up successful, check your email for confirmation." ? .green : .red)
                
                if isSignUpComplete {
                    NavigationLink(
                        destination: LoginView(),
                        isActive: $isSignUpComplete
                    ) {
                        EmptyView()
                    }
                }
                
                Spacer()
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
    
    func signUp() {
        guard validateFields() else {
            signupError = "Passwords must match and meet the required criteria."
            return
        }
        
        guard let url = URL(string: "http://192.168.0.145:5001/signup") else { return }
        
        let signUpData = ["email": email, "password": password]
        
        guard let requestBody = try? JSONSerialization.data(withJSONObject: signUpData) else { return }
        
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
                DispatchQueue.main.async {
                    signUpMessage = "Sign up successful, check your email for confirmation."
                    showConfirmationField = true
                }
            } else {
                if let result = try? JSONDecoder().decode([String: String].self, from: data) {
                    DispatchQueue.main.async {
                        signUpMessage = result["error"] ?? "Sign up failed"
                    }
                }
            }
        }.resume()
    }
    
    func validateFields() -> Bool {
        let isMatch = password == confirmPassword
        let isLengthValid = password.count >= 6
        let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasDigit = password.rangeOfCharacter(from: .decimalDigits) != nil
        let hasSymbol = password.rangeOfCharacter(from: .customSymbols) != nil
       
        print("Match:", isMatch)
        print("Length Valid:", isLengthValid)
        print("Has Uppercase:", hasUppercase)
        print("Has Lowercase:", hasLowercase)
        print("Has Digit:", hasDigit)
        print("Has Symbol:", hasSymbol)
       
        return isMatch && isLengthValid && hasUppercase && hasLowercase && hasDigit && hasSymbol
    }

    func confirmSignUp() {
        guard let url = URL(string: "http://192.168.0.145:5001/confirm-signup") else { return }
        
        let confirmationData = ["email": email, "confirmation_code": confirmationCode]
        
        guard let requestBody = try? JSONSerialization.data(withJSONObject: confirmationData) else { return }
        
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
                DispatchQueue.main.async {
                    signUpMessage = "Account confirmed, redirecting to login..."
                    isSignUpComplete = true
                }
            } else {
                if let result = try? JSONDecoder().decode([String: String].self, from: data) {
                    DispatchQueue.main.async {
                        signUpMessage = result["error"] ?? "Confirmation failed"
                    }
                }
            }
        }.resume()
    }
}
