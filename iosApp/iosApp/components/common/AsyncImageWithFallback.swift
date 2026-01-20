import SwiftUI
import UIKit

// MARK: - Cached Async Image

/// A custom AsyncImage that uses a 1-week disk cache
struct CachedAsyncImage<Content: View>: View {
    let url: URL?
    let content: (Image) -> Content

    @State private var loadedImage: UIImage?
    @State private var isLoading = false

    init(url: URL?, @ViewBuilder content: @escaping (Image) -> Content) {
        self.url = url
        self.content = content
    }

    var body: some View {
        Group {
            if let image = loadedImage {
                content(Image(uiImage: image))
            } else {
                content(Image(systemName: "photo"))
                    .onAppear {
                        loadImage()
                    }
                    .id(url) // Force refresh when URL changes
            }
        }
    }

    private func loadImage() {
        guard let url = url else { return }

        // Check cache first
        if let cachedImage = ImageCache.shared.getCachedImage(for: url) {
            loadedImage = cachedImage
            return
        }

        // If not in cache, download
        isLoading = true
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let uiImage = UIImage(data: data) {
                    ImageCache.shared.storeImage(uiImage, for: url)
                    await MainActor.run {
                        loadedImage = uiImage
                        isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

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
        CachedAsyncImage(url: url) { phase in
            phase
                .resizable()
                .scaledToFill()
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
        CachedAsyncImage(url: url) { image in
            ZStack {
                image
                    .resizable()
                    .scaledToFill()
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
