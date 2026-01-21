import Foundation
import UIKit
import ImageIO

// MARK: - UIImage Downsampling Extension

private extension UIImage {
    /// Downsamples an image from a data source to the given point size, preserving aspect ratio.
    /// This is significantly more memory-efficient than loading the full image and then resizing.
    /// - Parameters:
    ///   - data: The image data to downsample
    ///   - pointSize: The target size in points (will be scaled to screen pixels)
    ///   - scale: The screen scale factor (e.g., 2.0 for Retina, 3.0 for Super Retina)
    /// - Returns: A downsampled UIImage, or nil if downsampling failed
    static func downsample(data: Data, to pointSize: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            return nil
        }

        // Calculate the max dimension in pixels
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale

        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary

        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }

        return UIImage(cgImage: downsampledImage)
    }
}

// MARK: - Image Cache

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

    /// Retrieve a cached image, optionally downsampling it to the target size.
    /// - Parameters:
    ///   - url: The URL of the cached image
    ///   - targetSize: The size at which the image will be displayed. If nil, returns full resolution.
    /// - Returns: A UIImage, downsampled if targetSize is provided, or nil if not cached
    func getCachedImage(for url: URL, targetSize: CGSize? = nil) -> UIImage? {
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
            guard let cachedResponse = cache.cachedResponse(for: request) else {
                return nil
            }

            // Downsample if a target size is provided
            if let targetSize = targetSize {
                // Only downsample if the image is larger than needed
                // (small images are fine to load at full resolution)
                return UIImage.downsample(data: cachedResponse.data, to: targetSize)
            } else {
                return UIImage(data: cachedResponse.data)
            }
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

    /// Store image data directly (for already-downloaded or downsampled images).
    /// - Parameters:
    ///   - data: The image data to store
    ///   - url: The URL associated with this image
    func storeImageData(_ data: Data, for url: URL) {
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

    /// Download and downsample an image from a URL, storing the downsampled version in cache.
    /// - Parameters:
    ///   - url: The URL to download from
    ///   - targetSize: The size at which the image will be displayed
    /// - Returns: The downsampled UIImage, or nil if download failed
    func fetchAndDownsampleImage(for url: URL, targetSize: CGSize) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)

        // Downsample the image before storing
        guard let downsampledImage = UIImage.downsample(data: data, to: targetSize) else {
            // Fallback: if downsampling fails, try loading normally
            guard let image = UIImage(data: data) else {
                throw ImageCacheError.invalidImageData
            }
            return image
        }

        // Store the original data (not downsampled) so we can re-downsample for different sizes
        storeImageData(data, for: url)

        return downsampledImage
    }

    /// Clear all cached images (useful for memory warnings or user logout)
    func clearCache() {
        cache.removeAllCachedResponses()
        queue.async(flags: .barrier) {
            self.storageTimes.removeAll()
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

// MARK: - Errors

enum ImageCacheError: Error {
    case invalidImageData
}
