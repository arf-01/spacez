//
//  Home.swift
//  Space Wallpaper
//
//  Created by Abu Loman Hossain Shuvo on 1/9/25.
//
import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @Binding var isLoggedIn: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome!")
                .font(.largeTitle)

            Button("Logout") {
                logout()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

