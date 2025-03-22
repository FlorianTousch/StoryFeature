//
//  CachedAsyncImage.swift
//  StoryFeature
//
//  Created by Florianto on 22/03/2025.
//

import SwiftUI

struct CachedAsyncImage: View {
    let url: URL
    let cache: ImageCacheProtocol

    @State private var downloadedImage: UIImage?
    @State private var isLoading = false

    init(url: URL, cache: ImageCacheProtocol = DiskImageCache.shared) {
        self.url = url
        self.cache = cache
    }

    var body: some View {
        ZStack {
            if let downloadedImage {
                Image(uiImage: downloadedImage)
                    .resizable()
                    .scaledToFill()
            } else if isLoading {
                ProgressView()
            } else {
                Color.gray
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        if let cached = cache.image(for: url) {
            downloadedImage = cached
            return
        }

        isLoading = true
        Task {
            do {
//                try await Task.sleep(for: .seconds(2))
                let (data, _) = try await URLSession.shared.data(from: url)
                if let img = UIImage(data: data) {
                    cache.set(img, for: url)
                    downloadedImage = img
                }
            } catch {
                print("Image download error:", error)
            }
            isLoading = false
        }
    }
}
