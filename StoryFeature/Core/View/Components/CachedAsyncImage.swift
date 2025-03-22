//
//  CachedAsyncImage.swift
//  StoryFeature
//
//  Created by Florianto on 22/03/2025.
//

import SwiftUI
import Combine

struct CachedAsyncImage: View {
    let url: URL
    let loader: ImageLoaderServiceProtocol

    @State private var downloadedImage: UIImage?
    @State private var isLoading = false

    init(url: URL, loader: ImageLoaderServiceProtocol = ImageLoaderService()) {
        self.url = url
        self.loader = loader
    }

    var body: some View {
        ZStack {
            if let image = downloadedImage {
                Image(uiImage: image)
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
        if downloadedImage != nil { return }
        isLoading = true
        Task {
            do {
                let image = try await loader.loadImage(from: url)
                downloadedImage = image
            } catch {
                print("Image download error:", error)
            }
            isLoading = false
        }
    }
}
