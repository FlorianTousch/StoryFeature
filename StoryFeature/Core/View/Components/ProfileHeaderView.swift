//
//  ProfileHeaderView.swift
//  StoryFeature
//
//  Created by Florianto on 22/03/2025.
//

import SwiftUI

struct ProfileHeaderView: View {
    let profileName: String
    let profileImageURL: String

    var body: some View {
        HStack {
            if let url = URL(string: profileImageURL) {
                CachedAsyncImage(url: url)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 40, height: 40)
            }
            Text(profileName)
                .foregroundColor(.white)
                .font(.headline)
            Spacer()
        }
        .padding(.horizontal, 16)
        .id(profileImageURL)
    }
}
