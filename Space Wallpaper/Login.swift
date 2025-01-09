//
//  Login.swift
//  Space Wallpaper
//
//  Created by Abu Loman Hossain Shuvo on 1/9/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoggedIn = false
    @State private var showSignup = false

    var body: some View {
        if isLoggedIn {
            HomeView(isLoggedIn: $isLoggedIn)
        } else {
            VStack(spacing: 20) {
                Text("Login")
                    .font(.largeTitle)
                    .bold()

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                Button("Login") {
                    login()
                }
                .buttonStyle(.borderedProminent)

                Button("Sign Up") {
                    showSignup = true
                }
                .foregroundColor(.blue)
                .sheet(isPresented: $showSignup) {
                    SignupView()
                }
            }
            .padding()
        }
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isLoggedIn = true
            }
        }
    }
}
