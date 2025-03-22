//
//  PaginatedUsers.swift
//  StoryFeature
//
//  Created by Florianto on 22/03/2025.
//

struct PaginatedUsers: Decodable {
    let pages: [UserPage]
}

struct UserPage: Decodable {
    let users: [UserDTO]
}

struct UserDTO: Decodable {
    let id: Int
    let name: String
    let profilePictureURL: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case profilePictureURL = "profile_picture_url"
    }
}
