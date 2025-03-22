//
//  AnimatedProgressBarView.swift
//  StoryFeature
//
//  Created by Florianto on 22/03/2025.
//


import SwiftUI

struct AnimatedProgressBarView: View {
    let total: Int
    let currentIndex: Int
    let progress: Double

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { i in
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .foregroundColor(Color.white.opacity(0.4))
                        if i < currentIndex {
                            RoundedRectangle(cornerRadius: 2)
                                .foregroundColor(.white)
                                .frame(width: geo.size.width)
                        } else if i == currentIndex {
                            RoundedRectangle(cornerRadius: 2)
                                .foregroundColor(.white)
                                .frame(width: geo.size.width * CGFloat(progress))
                        }
                    }
                }
                .frame(height: 4)
            }
        }
        .frame(height: 4)
    }
}