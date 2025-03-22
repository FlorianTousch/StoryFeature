//
//  ProfileItemView.swift
//  StoryFeature
//
//  Created by Florianto on 22/03/2025.
//

import SwiftUI

struct ProfileItemView: View {
    let user: UserEntity
    let hasUnseenStories: Bool

    var body: some View {
        VStack {
            if let profileURL = URL(string: user.profilePictureURL) {
                CachedAsyncImage(url: profileURL)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(hasUnseenStories ? Color.blue : Color.gray.opacity(0.5),
                                    lineWidth: 3)
                    )
            } else {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 80, height: 80)
            }
            Text(user.name)
                .font(.caption)
        }
    }
}
