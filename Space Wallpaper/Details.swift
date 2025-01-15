import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct DetailsView: View {
    let apod: APOD
    @State private var firestoreMessage: String = "Waiting for Firestore operation..."
    @State private var isLoved = false
    private let db = Firestore.firestore()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Image with overlayed love icon
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: apod.url)) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFit()
                        } else if phase.error != nil {
                            Color.red // Error placeholder
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(height: 300)
                    .cornerRadius(10)

                    // Love icon overlay
                    Button(action: {
                        saveLovedImage()
                    }) {
                        Image(systemName: isLoved ? "heart.fill" : "heart")
                            .foregroundColor(isLoved ? .red : .white)
                            .padding(10)
                            .background(Circle().fill(Color.black.opacity(0.6)))
                            .font(.title)
                            .padding(10)
                    }
                }

                // Title
                Text(apod.title)
                    .font(.title)
                    .fontWeight(.bold)

                // Date
                Text(apod.date)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // Explanation
                Text(apod.explanation)
                    .font(.body)
                    .padding()

                Divider()

                // Status Message
                Text(firestoreMessage)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .padding()
            .onAppear {
                checkIfLoved()
                        }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Firestore Function

    /// Saves the image to Firestore for the authenticated user.
    func saveLovedImage() {
        let userRef = db.collection("users")
            .document(Auth.auth().currentUser?.uid ?? "")
            .collection("images")
        
        // Check if the image is already loved
        if isLoved {
            
            return
        }
        
        // Save the image to Firestore
        userRef.addDocument(data: [
            "imageUrl": apod.url,
            
        ]) { error in
            if let error = error {
                firestoreMessage = "Error: \(error.localizedDescription)"
            } else {
                isLoved = true
                firestoreMessage = "Image added to loved images!"
            }
        }
    }

    
    func checkIfLoved() {
        let userRef = db.collection("users")
            .document(Auth.auth().currentUser?.uid ?? "")
            .collection("images")
        
        // Query to check if the imageUrl exists
        userRef.whereField("imageUrl", isEqualTo: apod.url).getDocuments { snapshot, _ in
            // Check if any documents were returned (i.e., the image is loved)
            isLoved = !snapshot!.documents.isEmpty
        }
    }

}
