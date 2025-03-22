//
//  UserEntity.swift
//  StoryFeature
//
//  Created by Florianto on 22/03/2025.
//

import SwiftData

@Model
class UserEntity {
    @Attribute(.unique) var id: Int
    var name: String
    var profilePictureURL: String

    init(id: Int, name: String, profilePictureURL: String) {
        self.id = id
        self.name = name
        self.profilePictureURL = profilePictureURL
    }
}
