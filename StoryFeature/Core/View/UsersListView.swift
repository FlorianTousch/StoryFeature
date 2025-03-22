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

    @Query(sort: [SortDescriptor<UserEntity>(\.id, order: .forward)]) var users: [UserEntity]

    @State private var selectedUser: UserEntity?

    var body: some View {
        NavigationView {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    let sortedUsers = users.sorted { u1, u2 in
                        let unseen1 = viewModel.hasUnseenStories(user: u1)
                        let unseen2 = viewModel.hasUnseenStories(user: u2)
                        if unseen1 == unseen2 {
                            return u1.id < u2.id
                        } else {
                            return unseen1 && !unseen2
                        }
                    }
                    ForEach(sortedUsers, id: \.id) { user in
                        Button {
                            selectedUser = user
                        } label: {
                            ProfileItemView(user: user, hasUnseenStories: viewModel.hasUnseenStories(user: user))
                        }
                    }
                }
                .padding()
                Spacer()
            }
            .navigationTitle("Users")
            .fullScreenCover(item: $selectedUser) { user in
                StoryFlowFullScreenView(profiles: users, startProfileIndex: index(of: user), viewModel: viewModel)
            }
        }
        .task {
            viewModel.loadNextPageIfNeeded(context: context)
        }
    }

    func index(of user: UserEntity) -> Int {
        users.firstIndex(where: { $0.id == user.id }) ?? 0
    }
}
