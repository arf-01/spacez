import SwiftUI
import FirebaseAuth

struct APOD: Identifiable, Decodable {
    let id = UUID() // Unique identifier for SwiftUI List
    let title: String
    let url: String
    let explanation: String
    let date: String
}

struct HomeView: View {
    @State private var apods: [APOD] = []  // Array to store APOD data
    @State private var isLoading = false  // State to indicate loading status
    @Binding var isLoggedIn: Bool         // Logout binding

    var body: some View {
        NavigationView {
            VStack {
                if apods.isEmpty {
                    ProgressView("Loading photos...")
                        .onAppear {
                            fetchAPODs()
                        }
                } else {
                    List(apods) { apod in
                        NavigationLink(destination: DetailsView(apod: apod)) {
                            APODRow(apod: apod)
                        }
                    }
                }

                Button("Logout") {
                    logout()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 10)
            }
            .navigationTitle("NASA APOD")
        }
    }

    // Function to fetch APOD data from the NASA API
    func fetchAPODs() {
        guard !isLoading else { return }
        isLoading = true

        let urlString = "https://api.nasa.gov/planetary/apod?api_key=uQ2ut3wEUsVYR0WrbUmEpuvmB5Lp4IwcrJTnkBYZ&count=10"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            isLoading = false
            if let data = data {
                do {
                    let fetchedAPODs = try JSONDecoder().decode([APOD].self, from: data)
                    DispatchQueue.main.async {
                        apods = fetchedAPODs
                    }
                } catch {
                    print("Error decoding APOD data: \(error)")
                }
            } else if let error = error {
                print("Error fetching APOD data: \(error)")
            }
        }.resume()
    }

    // Logout function
    func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

// Row view for each APOD
struct APODRow: View {
    let apod: APOD

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: apod.url)) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else if phase.error != nil {
                    Color.red // Error placeholder
                } else {
                    ProgressView()
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(apod.title)
                    .font(.headline)
                Text(apod.date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

