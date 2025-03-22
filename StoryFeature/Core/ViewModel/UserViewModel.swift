//
//  UserViewModel.swift
//  StoryFeature
//
//  Created by Florianto on 22/03/2025.
//

import SwiftUI
import SwiftData

@MainActor
class UserViewModel: ObservableObject {
    private let service: UserService
    @Published var currentPageIndex = 0

    @Published var seenStoryIDs: Set<String> = []
    @Published var likedStoryIDs: Set<String> = []

    init(service: UserService = JSONUserService()) {
        self.service = service
        loadPersistedSeen()
        loadPersistedLikes()
    }

    func loadNextPageIfNeeded(context: ModelContext) {
        do {
            guard let page = try service.fetchPage(index: currentPageIndex) else {
                return
            }
            for dto in page.users {
                let existing = try context.fetch(
                    FetchDescriptor<UserEntity>()
                ).first(where: { $0.id == dto.id })

                if let user = existing {
                    user.name = dto.name
                    user.profilePictureURL = dto.profilePictureURL
                } else {
                    let newUser = UserEntity(
                        id: dto.id,
                        name: dto.name,
                        profilePictureURL: dto.profilePictureURL
                    )
                    context.insert(newUser)
                }
            }
            try context.save()
            currentPageIndex += 1
        } catch {
            print("Pagination error:", error)
        }
    }

    // MARK: - Seen Stories Persistence

    func markStoryAsSeen(storyID: String) {
        seenStoryIDs.insert(storyID)
        persistSeen()
    }

    func hasUnseenStories(user: UserEntity) -> Bool {
        let expectedStoryIDs = [
            "\(user.id)-photo-1",
            "\(user.id)-photo-2",
            "\(user.id)-video",
            "\(user.id)-photo-3"
        ]
        return expectedStoryIDs.contains { !seenStoryIDs.contains($0) }
    }

    private func loadPersistedSeen() {
        let array = UserDefaults.standard.stringArray(forKey: "seenStoryIDs") ?? []
        seenStoryIDs = Set(array)
    }

    private func persistSeen() {
        let array = Array(seenStoryIDs)
        UserDefaults.standard.set(array, forKey: "seenStoryIDs")
    }

    // MARK: - Liked Stories Persistence

    func toggleLike(storyID: String) {
        if likedStoryIDs.contains(storyID) {
            likedStoryIDs.remove(storyID)
        } else {
            likedStoryIDs.insert(storyID)
        }
        persistLikes()
    }

    func isLiked(storyID: String) -> Bool {
        likedStoryIDs.contains(storyID)
    }

    private func loadPersistedLikes() {
        let array = UserDefaults.standard.stringArray(forKey: "likedStoryIDs") ?? []
        likedStoryIDs = Set(array)
    }

    private func persistLikes() {
        let array = Array(likedStoryIDs)
        UserDefaults.standard.set(array, forKey: "likedStoryIDs")
    }
}
