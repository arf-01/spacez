import SwiftUI

struct DetailsView: View {
    let apod: APOD

    var body: some View {
        ScrollView { // Wrap the entire content in a ScrollView
            VStack(spacing: 20) {
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

                Text(apod.title)
                    .font(.title)
                    .fontWeight(.bold)

                Text(apod.date)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text(apod.explanation)
                    .font(.body)
                    .padding()
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
