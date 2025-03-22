//
//  PhotoStoryView.swift
//  StoryFeature
//
//  Created by Florianto on 22/03/2025.
//

import SwiftUI

struct PhotoStoryView: View {
    let url: URL

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            AsyncImage(url: url, transaction: Transaction(animation: .none)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else if phase.error != nil {
                    Color.red.ignoresSafeArea()
                } else {
                    ProgressView().ignoresSafeArea()
                }
            }
        }
    }
}
