import SwiftUI
import Kingfisher

struct FullscreenImageView: View {
    let imageURL: String?
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let urlString = imageURL, let url = URL(string: urlString) {
                KFImage(url)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = lastScale * value
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                },
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                    )
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white)
                    .shadow(radius: 5)
            }
            .padding()
        }
    }
}

// MARK: - Previews

#Preview("Fullscreen Image Viewer") {
    struct PreviewWrapper: View {
        @State private var isPresented = true

        var body: some View {
            ZStack {
                Color.background.ignoresSafeArea()

                if isPresented {
                    FullscreenImageView(
                        imageURL: "https://via.placeholder.com/800x600",
                        isPresented: $isPresented
                    )
                } else {
                    Button("Show Fullscreen") {
                        withAnimation {
                            isPresented = true
                        }
                    }
                }
            }
        }
    }

    return PreviewWrapper()
        .preferredColorScheme(.dark)
}
