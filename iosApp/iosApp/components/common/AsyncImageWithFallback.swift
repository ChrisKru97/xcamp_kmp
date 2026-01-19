import SwiftUI

// MARK: - Async Image With Fallback

/// A reusable AsyncImage component with consistent loading, failure, and empty states.
struct AsyncImageWithFallback: View {
    let url: URL?
    let fallbackIconName: String
    let size: CGSize

    /// Initialize with a URL, fallback SF Symbol icon name, and size.
    /// - Parameters:
    ///   - url: Optional URL to load the image from
    ///   - fallbackIconName: SF Symbol name to show on failure (e.g., "person.fill", "photo")
    ///   - size: Size of the image view
    init(url: URL?, fallbackIconName: String = "photo", size: CGSize) {
        self.url = url
        self.fallbackIconName = fallbackIconName
        self.size = size
    }

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                Image(systemName: fallbackIconName)
                    .foregroundColor(.secondary)
            case .empty:
                ProgressView()
            @unknown default:
                Image(systemName: fallbackIconName)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: size.width, height: size.height)
    }
}

// MARK: - Hero Async Image With Fallback

/// A hero-sized AsyncImage with gradient overlay for detail views.
struct HeroAsyncImageWithFallback: View {
    let url: URL?
    let fallbackIconName: String
    let height: CGFloat

    /// Initialize with a URL, fallback SF Symbol icon name, and height.
    /// - Parameters:
    ///   - url: Optional URL to load the image from
    ///   - fallbackIconName: SF Symbol name to show on failure (e.g., "person.fill", "photo")
    ///   - height: Height of the hero image
    init(url: URL?, fallbackIconName: String = "photo", height: CGFloat = 300) {
        self.url = url
        self.fallbackIconName = fallbackIconName
        self.height = height
    }

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                ZStack {
                    Color.secondary.opacity(0.3)
                    Image(systemName: fallbackIconName)
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                }
            case .empty:
                ZStack {
                    Color.secondary.opacity(0.3)
                    ProgressView()
                }
            @unknown default:
                ZStack {
                    Color.secondary.opacity(0.3)
                    Image(systemName: fallbackIconName)
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .clipped()
        .overlay(
            LinearGradient(
                colors: [.clear, .black.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Previews

#Preview("AsyncImageWithFallback - Thumbnail") {
    HStack(spacing: 20) {
        AsyncImageWithFallback(
            url: URL(string: "https://example.com/image.jpg"),
            fallbackIconName: "person.fill",
            size: CGSize(width: 80, height: 80)
        )
        .clipShape(Circle())

        AsyncImageWithFallback(
            url: nil,
            fallbackIconName: "person.fill",
            size: CGSize(width: 80, height: 80)
        )
        .clipShape(Circle())
    }
    .padding()
}

#Preview("HeroAsyncImageWithFallback") {
    VStack(spacing: 20) {
        HeroAsyncImageWithFallback(
            url: URL(string: "https://example.com/hero.jpg"),
            fallbackIconName: "person.fill",
            height: 250
        )

        HeroAsyncImageWithFallback(
            url: nil,
            fallbackIconName: "photo",
            height: 250
        )
    }
}
