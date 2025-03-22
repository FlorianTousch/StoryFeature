//
//  MediaType.swift
//  StoryFeature
//
//  Created by Florianto on 22/03/2025.
//

import Foundation
import SwiftUI

enum MediaType: Equatable {
    case photo
    case video(offset: Double)
}

struct Story: Identifiable, Equatable {
    let id: String
    let mediaType: MediaType
    let url: URL
}
