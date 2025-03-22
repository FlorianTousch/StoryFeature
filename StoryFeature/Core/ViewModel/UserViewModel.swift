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

    init(service: UserService = JSONUserService()) {
        self.service = service
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
}
