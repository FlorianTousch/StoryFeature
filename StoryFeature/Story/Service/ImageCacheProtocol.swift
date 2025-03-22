//
//  ImageCacheProtocol.swift
//  StoryFeature
//
//  Created by Florianto on 22/03/2025.
//

import SwiftUI

protocol ImageCacheProtocol {
    func image(for url: URL) -> UIImage?
    func set(_ image: UIImage, for url: URL)
}
