//
//  UserService.swift
//  StoryFeature
//
//  Created by Florianto on 22/03/2025.
//

import Foundation

protocol UserService {
    func loadAllPages() throws -> [UserPage]
    func fetchPage(index: Int) throws -> UserPage?
}

final class JSONUserService: UserService {
    private var allPages: [UserPage] = []

    func loadAllPages() throws -> [UserPage] {
        if !allPages.isEmpty { return allPages }
        guard let url = Bundle.main.url(forResource: "users", withExtension: "json") else {
            throw JSONError.fileNotFound
        }
        let data = try Data(contentsOf: url)
        let paginated = try JSONDecoder().decode(PaginatedUsers.self, from: data)
        allPages = paginated.pages
        return allPages
    }

    func fetchPage(index: Int) throws -> UserPage? {
        let pages = try loadAllPages()
        guard index < pages.count else { return nil }
        return pages[index]
    }

    enum JSONError: Error {
        case fileNotFound
    }
}
