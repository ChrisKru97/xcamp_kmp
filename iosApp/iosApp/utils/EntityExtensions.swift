import SwiftUI
import shared

// MARK: - Entity Extensions for Image URL

/// Protocol for entities that have imageUrl property
protocol HasImageUrl {
    var imageUrl: String? { get }
}

extension Speaker: HasImageUrl {}
extension Place: HasImageUrl {}

extension HasImageUrl {
    /// Extracts URL from the entity's imageUrl property
    /// - Returns: URL if imageUrl string is valid and non-empty, nil otherwise
    var imageUrlURL: URL? {
        guard let urlString = imageUrl, !urlString.isEmpty else { return nil }
        return URL(string: urlString)
    }
}
