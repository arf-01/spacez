import SwiftUI
import FirebaseAuth

struct APOD: Codable, Identifiable {
    let id = UUID()  // For SwiftUI List
    let title: String
    let url: String
    let date: String
    let explanation: String
}

struct HomeView: View {
    @State private var apods: [APOD] = [] // Array to store APOD data
    @State private var isLoading = false // Loading state
    @Binding var isLoggedIn: Bool        // Logout binding

    var body: some View {
        NavigationView {
            VStack {
                if apods.isEmpty && isLoading {
                    ProgressView("Loading photos...")
                        .onAppear {
                            fetchAPODs()
                        }
                } else {
                    List {
                        ForEach(apods) { apod in
                            NavigationLink(destination: DetailsView(apod: apod)) {
                                APODRow(apod: apod)
                            }
                        }

                        // Infinite scrolling trigger
                        if !isLoading {
                            Color.clear
                                .onAppear {
                                    fetchAPODs()
                                }
                        } else {
                            ProgressView("Loading more...")
                        }
                    }
                }

                Button("Logout") {
                    logout()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("NASA APOD")
        }
    }

    func fetchAPODs() {
        guard !isLoading else { return }
        isLoading = true

        let urlString = "https://api.nasa.gov/planetary/apod?api_key=uQ2ut3wEUsVYR0WrbUmEpuvmB5Lp4IwcrJTnkBYZ&count=10"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let data = data {
                do {
                    let fetchedAPODs = try JSONDecoder().decode([APOD].self, from: data)
                    DispatchQueue.main.async {
                        apods.append(contentsOf: fetchedAPODs)
                    }
                } catch {
                    print("Error decoding APOD data: \(error)")
                }
            } else if let error = error {
                print("Error fetching APOD data: \(error)")
            }
        }.resume()
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
