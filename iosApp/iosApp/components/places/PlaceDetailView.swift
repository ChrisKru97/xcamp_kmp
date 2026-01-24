import SwiftUI
import shared

struct PlaceDetailView: View {
    let place: Place

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                placeHeroImage
                placeContent
            }
        }
        .navigationTitle(place.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.background)
        .accessibilityLabel(place.name)
        .accessibilityHint(Strings.Places.shared.DETAIL_DESCRIPTION_HINT)
    }

    private var placeHeroImage: some View {
        HeroAsyncImageWithFallback(
            url: place.imageUrlURL,
            fallbackIconName: "photo",
            height: 250
        )
        .accessibilityHidden(true)  // Decorative hero image
    }

    private var placeContent: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Use description_ to avoid conflict with Swift's built-in .description
            if let description = place.description_, !description.isEmpty {
                GlassCard {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.white)
                        .lineSpacing(4)
                }
                .padding(.top, -CornerRadius.large)
                .padding(.horizontal, Spacing.md)
            }

            if let lat = place.latitude, let lon = place.longitude {
                Button {
                    openInMaps(latitude: lat.doubleValue, longitude: lon.doubleValue, name: place.name)
                } label: {
                    HStack {
                        Image(systemName: "map.fill")
                        Text(Strings.Places.shared.OPEN_IN_MAPS)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                    }
                    .foregroundColor(.primary)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .fill(.ultraThinMaterial)
                    )
                }
                .accessibilityHint("Opens this location in Apple Maps")
                .padding(.horizontal, Spacing.md)
            }

            Spacer(minLength: Spacing.xxl)
        }
        .padding(.top, Spacing.xl)
    }

    private func openInMaps(latitude: Double, longitude: Double, name: String) {
        let region = "ll=\(latitude),\(longitude)"
        guard let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let url = URL(string: "http://maps.apple.com/?\(region)&q=\(encodedName)") else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Previews

#Preview("Place Detail View - With Description") {
    NavigationStack {
        PlaceDetailView(place: Place(
            id: "test",
            name: "Test Place",
            description: "This is a longer description that should wrap nicely. It can contain multiple lines of text describing the place in detail.",
            priority: 1,
            latitude: 50.0,
            longitude: 14.0,
            image: nil,
            imageUrl: nil
        ))
    }
    .preferredColorScheme(.dark)
}

#Preview("Place Detail View - Without Description") {
    NavigationStack {
        PlaceDetailView(place: Place(
            id: "test2",
            name: "Place Without Description",
            description: nil,
            priority: 2,
            latitude: 50.5,
            longitude: 14.5,
            image: nil,
            imageUrl: nil
        ))
    }
    .preferredColorScheme(.light)
}

#Preview("Place Detail View - Without Location") {
    NavigationStack {
        PlaceDetailView(place: Place(
            id: "test3",
            name: "Place Without Location",
            description: "A place that has a description but no GPS coordinates.",
            priority: 3,
            latitude: nil,
            longitude: nil,
            image: nil,
            imageUrl: nil
        ))
    }
    .preferredColorScheme(.dark)
}
