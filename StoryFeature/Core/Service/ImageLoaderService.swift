//
//  ImageLoaderServiceProtocol.swift
//  StoryFeature
//
//  Created by Florianto on 22/03/2025.
//


import UIKit
import SwiftUI

protocol ImageLoaderServiceProtocol {
    func loadImage(from url: URL) async throws -> UIImage
}

final class ImageLoaderService: ImageLoaderServiceProtocol {
    let cache: ImageCacheProtocol
    
    init(cache: ImageCacheProtocol = DiskImageCache.shared) {
        self.cache = cache
    }
    
    func loadImage(from url: URL) async throws -> UIImage {
        if let cached = cache.image(for: url) {
            return cached
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw URLError(.badServerResponse)
        }
        cache.set(image, for: url)
        return image
    }
}
