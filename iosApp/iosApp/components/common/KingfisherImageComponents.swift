import SwiftUI
import Kingfisher

// MARK: - Async Image With Fallback

/// Kingfisher-powered async image with fallback SF Symbol.
/// Automatically handles caching, loading states, and memory management.
struct AsyncImageWithFallback: View {
    let url: URL?
    let fallbackIconName: String
    let size: CGSize

    init(url: URL?, fallbackIconName: String = "photo", size: CGSize) {
        self.url = url
        self.fallbackIconName = fallbackIconName
        self.size = size
    }

    var body: some View {
        Group {
            if let url = url {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
            } else {
                Image(systemName: fallbackIconName)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary)
                    .frame(width: size.width, height: size.height)
            }
        }
    }
}

// MARK: - Hero Async Image With Fallback

/// Hero-sized Kingfisher image with gradient overlay for detail views.
struct HeroAsyncImageWithFallback: View {
    let url: URL?
    let fallbackIconName: String
    let height: CGFloat

    init(url: URL?, fallbackIconName: String = "photo", height: CGFloat = 300) {
        self.url = url
        self.fallbackIconName = fallbackIconName
        self.height = height
    }

    var body: some View {
        GeometryReader { geometry in
            Group {
                if let url = url {
                    KFImage(url)
                        .resizable()
                        .scaledToFill()
                        .frame(height: height)
                        .frame(maxWidth: .infinity)
                } else {
                    ZStack {
                        Color.clear
                        Image(systemName: fallbackIconName)
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                    }
                    .frame(height: height)
                    .frame(maxWidth: .infinity)
                }
            }
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

#Preview("AsyncImageWithFallback") {
    VStack(spacing: 20) {
        AsyncImageWithFallback(
            url: URL(string: "https://via.placeholder.com/300"),
            fallbackIconName: "person.fill",
            size: CGSize(width: 80, height: 80)
        )
        .clipShape(Circle())

        AsyncImageWithFallback(
            url: nil,
            fallbackIconName: "photo",
            size: CGSize(width: 150, height: 150)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .padding()
    .background(Color.background)
}

#Preview("HeroAsyncImageWithFallback") {
    VStack(spacing: 20) {
        HeroAsyncImageWithFallback(
            url: URL(string: "https://via.placeholder.com/600x300"),
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
