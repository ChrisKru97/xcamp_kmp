import SwiftUI
import shared

// MARK: - Entity Extensions for Image URL

/// Protocol for entities that can be displayed in EntityDetailView
protocol EntityDetailRepresentable {
    var imageUrl: String? { get }
    var name: String { get }
    var description_: String? { get }
}

extension Place: EntityDetailRepresentable {}
extension Speaker: EntityDetailRepresentable {}

extension EntityDetailRepresentable {
    /// Extracts URL from the entity's imageUrl property
    var imageUrlURL: URL? {
        guard let urlString = imageUrl, !urlString.isEmpty else { return nil }
        return URL(string: urlString)
    }
}
