import SwiftUI
import UIKit

@available(iOS 15, *)
public enum PresentationDetent: Hashable, Sendable {
    case medium
    case large

    @available(iOS 16, *)
    var toNative: UISheetPresentationController.Detent {
        switch self {
        case .medium: return .medium()
        case .large: return .large()
        }
    }
}

@available(iOS 15, *)
private class PresentationDetentController: UIViewController {
    var detents: Set<PresentationDetent> = [.large]

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        guard let parent = parent,
              let sheet = parent.sheetPresentationController else { return }

        if #available(iOS 16.0, *) {
            sheet.detents = detents.compactMap { $0.toNative }
        } else {
            var allDetents: [UISheetPresentationController.Detent] = []
            if detents.contains(.medium) {
                allDetents.append(.medium())
            }
            if detents.contains(.large) {
                allDetents.append(.large())
            }
            sheet.detents = allDetents
        }
    }
}

@MainActor
@available(iOS 15, *)
public extension Backport where Content: View {
    func presentationDetents(_ detents: Set<PresentationDetent>) -> some View {
        content.background(PresentationDetentHost(detents: detents))
    }
}

@available(iOS 15, *)
private struct PresentationDetentHost: UIViewControllerRepresentable {
    let detents: Set<PresentationDetent>

    func makeUIViewController(context: Context) -> PresentationDetentController {
        let controller = PresentationDetentController()
        controller.detents = detents
        return controller
    }

    func updateUIViewController(_ uiViewController: PresentationDetentController, context: Context) {
        uiViewController.detents = detents
    }
}
