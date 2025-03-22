//
//  StoryFlowFullScreenView.swift
//  StoryFeature
//
//  Created by Florianto on 22/03/2025.
//

import SwiftUI
import AVKit

struct StoryFlowFullScreenView: View {
    @Environment(\.dismiss) var dismiss

    let profiles: [UserEntity]
    @State private var currentProfileIndex: Int
    @ObservedObject var viewModel: UserViewModel

    var currentStories: [Story] {
        let user = profiles[currentProfileIndex]
        return [
            Story(id: "\(user.id)-photo-1", mediaType: .photo, url: URL(string: "https://images.unsplash.com/photo-1742590794643-5b401ed198b4?q=80&w=2487&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")!),
            Story(id: "\(user.id)-photo-2", mediaType: .photo, url: URL(string: "https://plus.unsplash.com/premium_photo-1677556743433-8ace1c020781?q=80&w=2487&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")!),
            Story(id: "\(user.id)-video", mediaType: .video(offset: 0), url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!),
            Story(id: "\(user.id)-photo-3", mediaType: .photo, url: URL(string: "https://images.unsplash.com/photo-1742401571210-d24df76632b9?q=80&w=2487&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")!)
        ]
    }

    @State private var currentStoryIndex: Int = 0
    @State private var segmentProgress: Double = 0
    @State private var manualNavigation = false
    @State private var verticalOffset: CGFloat = 0

    let photoDuration: Double = 10.0
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()

    init(profiles: [UserEntity], startProfileIndex: Int, viewModel: UserViewModel) {
        self.profiles = profiles
        _currentProfileIndex = State(initialValue: startProfileIndex)
        self.viewModel = viewModel
    }

    var currentProfile: UserEntity {
        profiles[currentProfileIndex]
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if currentStoryIndex >= currentStories.count {
                Color.clear.onAppear {
                    goToNextProfile()
                }
            } else {
                let story = currentStories[currentStoryIndex]
                Group {
                    switch story.mediaType {
                    case .photo:
                        PhotoStoryView(url: story.url)
                    case .video(let offset):
                        VideoStoryView(url: story.url, startOffset: offset) { elapsed in
                            if manualNavigation { return }
                            segmentProgress = min(elapsed / 10.0, 1)
                            if segmentProgress >= 1 {
                                goToNextStory()
                            }
                        }
                    }
                }
                .id("\(currentProfile.id)-\(currentStoryIndex)")
            }

            VStack(spacing: 8) {
                ProfileHeaderView(profileName: currentProfile.name, profileImageURL: currentProfile.profilePictureURL)
                AnimatedProgressBarView(total: currentStories.count, currentIndex: currentStoryIndex, progress: segmentProgress)
                    .padding(.horizontal, 16)
                    .animation(.linear, value: segmentProgress)
                Spacer()
                HStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .contentShape(Rectangle())
                        .onTapGesture { goToPreviousStory() }
                    Rectangle()
                        .foregroundColor(.clear)
                        .contentShape(Rectangle())
                        .onTapGesture { goToNextStory() }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.top, 16)
            .zIndex(9999)
            .id(currentProfile.id)
        }
        .offset(y: verticalOffset)
        .gesture(
            DragGesture(minimumDistance: 20)
                .onChanged { value in
                    verticalOffset = max(0, value.translation.height)
                }
                .onEnded { value in
                    if value.translation.height > 100 {
                        dismiss()
                    } else {
                        withAnimation { verticalOffset = 0 }
                    }
                }
        )
        .onChange(of: currentProfileIndex) {
            segmentProgress = 0
            manualNavigation = false
            currentStoryIndex = 0
        }
        .onReceive(timer) { _ in
            if manualNavigation { return }
            if currentStoryIndex < currentStories.count {
                let story = currentStories[currentStoryIndex]
                if case .photo = story.mediaType {
                    segmentProgress += 0.02 / photoDuration
                    if segmentProgress >= 1 {
                        goToNextStory()
                    }
                }
            }
        }
        .onAppear {
            segmentProgress = 0
        }
        .transition(.opacity)
    }

    func goToNextStory() {
        manualNavigation = true

        if currentStoryIndex < currentStories.count - 1 {
            currentStoryIndex += 1
        } else {
            goToNextProfile()
            return
        }
        segmentProgress = 0
        DispatchQueue.main.async {
            manualNavigation = false
        }
    }

    func goToPreviousStory() {
        manualNavigation = true

        if currentStoryIndex > 0 {
            currentStoryIndex -= 1
        } else {
            goToPreviousProfile()
            return
        }
        segmentProgress = 0
        DispatchQueue.main.async {
            manualNavigation = false
        }
    }

    func goToNextProfile() {
        // Réinitialise la progression et le flag de navigation manuelle
        segmentProgress = 0
        manualNavigation = false
        if currentProfileIndex < profiles.count - 1 {
            currentProfileIndex += 1
        } else {
            currentProfileIndex = 0
        }
        currentStoryIndex = 0
    }

    func goToPreviousProfile() {
        segmentProgress = 0
        manualNavigation = false
        if currentProfileIndex > 0 {
            currentProfileIndex -= 1
            currentStoryIndex = 0
        } else {
            dismiss()
        }
    }
}
