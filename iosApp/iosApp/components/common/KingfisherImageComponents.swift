import SwiftUI
import Kingfisher

struct AsyncImageWithFallback: View {
    let url: URL?
    let fallbackIconName: String
    let width: CGFloat?
    let height: CGFloat

    init(url: URL?, fallbackIconName: String = "photo", size: CGSize) {
        self.url = url
        self.fallbackIconName = fallbackIconName
        self.width = size.width
        self.height = size.height
    }

    init(url: URL?, fallbackIconName: String = "photo", height: CGFloat) {
        self.url = url
        self.fallbackIconName = fallbackIconName
        self.width = nil
        self.height = height
    }

    var body: some View {
        if let width = width {
            imageContent
                .frame(width: width, height: height)
        } else {
            imageContent
                .frame(height: height)
                .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var imageContent: some View {
        if let url = url {
            KFImage(url)
                .backgroundDecode()
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: fallbackIconName)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Previews

#Preview("Fixed Size") {
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

#Preview("Full Width") {
    VStack(spacing: 20) {
        AsyncImageWithFallback(
            url: URL(string: "https://via.placeholder.com/600x300"),
            fallbackIconName: "person.fill",
            height: 250
        )

        AsyncImageWithFallback(
            url: nil,
            fallbackIconName: "photo",
            height: 250
        )
    }
}
