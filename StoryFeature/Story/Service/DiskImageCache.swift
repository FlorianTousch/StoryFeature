//
//  DiskImageCache.swift
//  StoryFeature
//
//  Created by Florianto on 22/03/2025.
//

import SwiftUI

final class DiskImageCache: ImageCacheProtocol {
    static let shared = DiskImageCache()

    private let fileManager = FileManager.default
    private let folderName = "story_image_cache"

    /// URL pointing to the `Caches/story_image_cache` folder
    private lazy var cacheDirectoryURL: URL = {
        let cacheDirs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let folder = cacheDirs.appendingPathComponent(folderName, isDirectory: true)

        if !fileManager.fileExists(atPath: folder.path) {
            try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }()

    /// Retrieves the image from disk if it exists
    func image(for url: URL) -> UIImage? {
        let fileURL = cacheDirectoryURL.appendingPathComponent(fileName(for: url))
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }

    /// Stores the image in the designated folder
    func set(_ image: UIImage, for url: URL) {
        let fileURL = cacheDirectoryURL.appendingPathComponent(fileName(for: url))
        // We can choose JPEG/PNG depending on the image format
        if let data = image.jpegData(compressionQuality: 1.0) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    /// Generates a file name (e.g. "300?u=15.jpg").
    /// Optionally, you can use a hash (MD5/SHA1) to avoid issues with special characters.
    private func fileName(for url: URL) -> String {
        // Hash the entire URL
        let absString = url.absoluteString
        let hash = absString.md5 // (Extension to be implemented)
        return "\(hash).jpg"
    }
}

extension String {
    var md5: String {
        // Minimal example
        // For a real project, see CommonCrypto or CryptoKit.
        // https://developer.apple.com/documentation/CryptoKit
        // ...
        return self // Replace this with an actual hash implementation
    }
}
