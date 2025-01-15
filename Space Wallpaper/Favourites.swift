import SwiftUI
import Firebase
import FirebaseAuth

struct FavouritesView: View {
    @State private var favouriteImages: [String] = [] // Array to store favourite image URLs
    @State private var isLoading = true // Loading state
    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading Favourites...")
                } else if favouriteImages.isEmpty {
                    Text("No favourite images found!")
                        .font(.headline)
                        .foregroundColor(.gray)
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(favouriteImages, id: \.self) { imageUrl in
                                AsyncImage(url: URL(string: imageUrl)) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .cornerRadius(10)
                                    } else if phase.error != nil {
                                        Color.red
                                            .frame(height: 200)
                                            .cornerRadius(10)
                                    } else {
                                        ProgressView()
                                            .frame(height: 200)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Favourites")
            .onAppear {
                fetchFavourites()
            }
        }
    }

    func fetchFavourites() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            isLoading = false
            return
        }

        db.collection("users")
            .document(userId)
            .collection("images")
            .getDocuments { snapshot, error in
                isLoading = false

                if let error = error {
                    print("Error fetching favourites: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    return
                }

                favouriteImages = documents.compactMap { doc in
                    doc.data()["imageUrl"] as? String
                }
            }
    }
}
