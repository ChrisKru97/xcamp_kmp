import Foundation
import UIKit

/// Shared image cache with 1-week expiration for Speaker and Place images
/// Thread-safe using a serial queue for storageTimes access
class ImageCache {
    static let shared = ImageCache()

    private let cache: URLCache
    private var storageTimes: [URL: Date] = [:]
    private let queue = DispatchQueue(label: "cz.krutsche.xcamp.imagecache", attributes: .concurrent)

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
        return queue.sync {
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

        queue.async(flags: .barrier) {
            self.storageTimes[url] = Date()
        }
    }

    /// Clean up expired entries from storageTimes to prevent unbounded growth
    /// Call this periodically (e.g., on app launch/background)
    func cleanupExpiredEntries() {
        queue.async(flags: .barrier) {
            let oneWeekInSeconds: TimeInterval = 7 * 24 * 60 * 60
            let now = Date()

            // Remove entries that are older than a week
            self.storageTimes = self.storageTimes.filter { (_, storedDate) in
                now.timeIntervalSince(storedDate) < oneWeekInSeconds
            }

            // Also clean up any URLs that are no longer in the underlying URLCache
            let urls = Array(self.storageTimes.keys)
            for url in urls {
                let request = URLRequest(url: url)
                if self.cache.cachedResponse(for: request) == nil {
                    self.storageTimes.removeValue(forKey: url)
                }
            }
        }
    }
}
