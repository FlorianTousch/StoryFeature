//
//  UsersListView.swift
//  StoryFeature
//
//  Created by Florianto on 22/03/2025.
//

import SwiftUI
import SwiftData

struct UsersListView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = UserViewModel()

    @Query var users: [UserEntity]

    init() {
        _users = Query(
            filter: nil,
            sort: [SortDescriptor<UserEntity>(\.id, order: .forward)]
        )
    }

    var body: some View {
        NavigationView {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(Array(users.enumerated()), id: \.element.id) { (index, user) in
                        VStack {
                            if let profileURL = URL(string: user.profilePictureURL) {
                                CachedAsyncImage(url: profileURL)
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 80, height: 80)
                            }

                            Text(user.name)
                                .font(.caption)
                        }
                        .onAppear {
                            if index == users.count - 2 {
                                viewModel.loadNextPageIfNeeded(context: context)
                            }
                        }
                    }
                }
                .padding()

                Spacer()
            }
        }
        .task {
            viewModel.loadNextPageIfNeeded(context: context)
        }
    }
}
