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

    // Sélectionne l'utilisateur pour ouvrir ses stories en full screen
    @State private var selectedUser: UserEntity?

    var body: some View {
        NavigationView {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(users, id: \.id) { user in
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
                        .onTapGesture {
                            // Au tap, on ouvre les stories du user
                            selectedUser = user
                        }
                        .onAppear {
                            // Pagination pour charger plus d'utilisateurs
                            if let index = users.firstIndex(where: { $0.id == user.id }),
                               index == users.count - 2 {
                                viewModel.loadNextPageIfNeeded(context: context)
                            }
                        }
                    }
                }
                .padding()
                Spacer()
            }
            .navigationTitle("Users")
        }
        .fullScreenCover(item: $selectedUser) { user in
            if let index = users.firstIndex(of: user) {
                StoryFlowFullScreenView(
                    profiles: users,
                    startProfileIndex: index,
                    viewModel: viewModel
                )
            }
        }
        .task {
            viewModel.loadNextPageIfNeeded(context: context)
        }
    }
}
