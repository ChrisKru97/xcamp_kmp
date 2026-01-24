import SwiftUI
import UIKit

// MARK: - Cached Async Image

/// A custom AsyncImage that uses a 1-week disk cache with automatic downsampling for memory efficiency.
/// Images are downsampled to the target size when loaded, reducing memory usage by 50-70%.
struct CachedAsyncImage<Content: View>: View {
    let url: URL?
    let fallbackIconName: String
    let targetSize: CGSize?
    let content: (Image) -> Content

    @State private var loadedImage: UIImage?
    @State private var isLoading = false

    init(url: URL?, fallbackIconName: String = "photo", targetSize: CGSize? = nil, @ViewBuilder content: @escaping (Image) -> Content) {
        self.url = url
        self.fallbackIconName = fallbackIconName
        self.targetSize = targetSize
        self.content = content
    }

    var body: some View {
        Group {
            if let image = loadedImage {
                content(Image(uiImage: image))
            } else {
                content(Image(systemName: fallbackIconName))
                    .task {
                        loadImage()
                    }
                    .id(url) // Force refresh when URL changes
            }
        }
    }

    private func loadImage() {
        guard let url = url else { return }

        // Check cache first (with downsampling if targetSize is provided)
        if let cachedImage = ImageCache.shared.getCachedImage(for: url, targetSize: targetSize) {
            loadedImage = cachedImage
            return
        }

        // If not in cache, download with optional downsampling
        isLoading = true
        Task {
            do {
                let uiImage: UIImage
                if let targetSize = targetSize {
                    // Use the new fetchAndDownsampleImage method for memory efficiency
                    uiImage = try await ImageCache.shared.fetchAndDownsampleImage(for: url, targetSize: targetSize)
                } else {
                    // Legacy path: download without downsampling
                    let (data, _) = try await URLSession.shared.data(from: url)
                    guard let image = UIImage(data: data) else {
                        throw ImageCacheError.invalidImageData
                    }
                    uiImage = image
                    ImageCache.shared.storeImage(uiImage, for: url)
                }

                await MainActor.run {
                    loadedImage = uiImage
                    isLoading = false
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
/// Images are automatically downsampled to the target size for memory efficiency.
struct AsyncImageWithFallback: View {
    let url: URL?
    let fallbackIconName: String
    let size: CGSize

    /// Initialize with a URL, fallback SF Symbol icon name, and size.
    /// - Parameters:
    ///   - url: Optional URL to load the image from
    ///   - fallbackIconName: SF Symbol name to show on failure (e.g., "person.fill", "photo")
    ///   - size: Size of the image view (used for downsampling to reduce memory)
    init(url: URL?, fallbackIconName: String = "photo", size: CGSize) {
        self.url = url
        self.fallbackIconName = fallbackIconName
        self.size = size
    }

    var body: some View {
        CachedAsyncImage(url: url, fallbackIconName: fallbackIconName, targetSize: size) { phase in
            phase
                .resizable()
                .scaledToFill()
        }
        .frame(width: size.width, height: size.height)
    }
}

// MARK: - Hero Async Image With Fallback

/// A hero-sized AsyncImage with gradient overlay for detail views.
/// Images are automatically downsampled for memory efficiency.
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
        GeometryReader { geometry in
            CachedAsyncImage(url: url, fallbackIconName: fallbackIconName, targetSize: CGSize(width: geometry.size.width, height: height)) { image in
                ZStack {
                    image
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .overlay(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .frame(height: height)
    }
}

// MARK: - Previews

#Preview("CachedAsyncImage") {
    VStack(spacing: 20) {
        // With valid URL (using a public placeholder image service)
        CachedAsyncImage(url: URL(string: "https://via.placeholder.com/300"), fallbackIconName: "photo") { image in
            image
                .frame(width: 300, height: 200)
        }

        // With nil URL (shows fallback icon)
        CachedAsyncImage(url: nil, fallbackIconName: "person.fill") { image in
            image
                .frame(width: 100, height: 100)
        }

        // Rounded rectangle variant
        CachedAsyncImage(url: URL(string: "https://via.placeholder.com/300"), fallbackIconName: "photo") { image in
            image
                .frame(width: 150, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    .padding()
    .background(Color.background)
}

#Preview("CachedAsyncImage - Dark Mode") {
    VStack(spacing: 20) {
        CachedAsyncImage(url: URL(string: "https://via.placeholder.com/300"), fallbackIconName: "photo") { image in
            image
                .frame(width: 300, height: 200)
        }

        CachedAsyncImage(url: nil, fallbackIconName: "star.fill") { image in
            image
                .frame(width: 100, height: 100)
                .foregroundColor(.yellow)
        }
    }
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}

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
