import Foundation
import UIKit

/// Shared image cache with 1-week expiration for Speaker and Place images
class ImageCache {
    static let shared = ImageCache()

    private let cache: URLCache
    private var storageTimes: [URL: Date] = [:]

    private init() {
        // Configure cache with 50MB memory and 500MB disk capacity
        let memoryCapacity = 50 * 1024 * 1024
        let diskCapacity = 500 * 1024 * 1024

        self.cache = URLCache(
            memoryCapacity: memoryCapacity,
            diskCapacity: diskCapacity,
            diskPath: "xcamp_image_cache"
        )
    }

    func getCachedImage(for url: URL) -> UIImage? {
        // Check if we have a stored timestamp
        if let storedDate = storageTimes[url] {
            let cacheAge = Date().timeIntervalSince(storedDate)
            let oneWeekInSeconds: TimeInterval = 7 * 24 * 60 * 60

            if cacheAge >= oneWeekInSeconds {
                // Cache expired, remove it
                storageTimes.removeValue(forKey: url)
                cache.removeCachedResponse(for: URLRequest(url: url))
                return nil
            }
        }

        // Check URLCache
        let request = URLRequest(url: url)
        if let cachedResponse = cache.cachedResponse(for: request) {
            return UIImage(data: cachedResponse.data)
        }
        return nil
    }

    func storeImage(_ image: UIImage, for url: URL) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let response = URLResponse(
            url: url,
            mimeType: "image/jpeg",
            expectedContentLength: data.count,
            textEncodingName: nil
        )
        let cachedResponse = CachedURLResponse(response: response, data: data)
        let request = URLRequest(url: url)
        cache.storeCachedResponse(cachedResponse, for: request)
        storageTimes[url] = Date()
    }
}
