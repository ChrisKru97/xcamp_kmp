import SwiftUI
import Kingfisher

struct ArealHeroSection: View {
    let imageURL: String?
    let onTap: () -> Void

    @State private var isLoading: Bool = true
    @State private var hasImage: Bool = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(height: UIScreen.main.bounds.width * 9 / 16)
            } else if hasImage {
                GeometryReader { geometry in
                    let height = geometry.size.width * 9 / 16

                    Group {
                        if let url = URL(string: imageURL ?? "") {
                            KFImage(url)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Color.clear
                        }
                    }
                    .frame(width: geometry.size.width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onTap()
                    }
                    .onAppear {
                        if imageURL != nil && !imageURL!.isEmpty {
                            hasImage = true
                        }
                        isLoading = false
                    }
                }
                .frame(height: UIScreen.main.bounds.width * 9 / 16)
            } else {
                Color.clear
            }
        }
        .onAppear {
            if imageURL == nil || imageURL?.isEmpty == true {
                hasImage = false
            } else {
                hasImage = true
            }
            isLoading = false
        }
    }
}

// MARK: - Previews

#Preview("Areal Hero Section - With Image") {
    ArealHeroSection(imageURL: "https://via.placeholder.com/800x450") { }
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}

#Preview("Areal Hero Section - No Image") {
    ArealHeroSection(imageURL: nil) { }
    .padding()
    .background(Color.background)
    .preferredColorScheme(.light)
}
