//
//  StoryFeatureApp.swift
//  StoryFeature
//
//  Created by Florianto on 22/03/2025.
//

import SwiftUI

@main
struct StoryFeatureApp: App {
    var body: some Scene {
        WindowGroup {
            UsersListView()
                .modelContainer(for: UserEntity.self)
        }
    }
}
