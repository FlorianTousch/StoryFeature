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
            Story(id: "\(user.id)-photo-1", mediaType: .photo, url: URL(string: "https://images.unsplash.com/photo-1742590794643-5b401ed198b4?q=80&w=2487&auto=format&fit=crop&ixlib=rb-4.0.3")!),
            Story(id: "\(user.id)-photo-2", mediaType: .photo, url: URL(string: "https://plus.unsplash.com/premium_photo-1677556743433-8ace1c020781?q=80&w=2487&auto=format&fit=crop&ixlib=rb-4.0.3")!),
            Story(id: "\(user.id)-video", mediaType: .video(offset: 0), url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!),
            Story(id: "\(user.id)-photo-3", mediaType: .photo, url: URL(string: "https://images.unsplash.com/photo-1742401571210-d24df76632b9?q=80&w=2487&auto=format&fit=crop&ixlib=rb-4.0.3")!)
        ]
    }

    @State private var currentStoryIndex: Int = 0
    @State private var segmentProgress: Double = 0
    @State private var manualNavigation = false
    @State private var verticalOffset: CGFloat = 0
    @State private var heartScale: CGFloat = 1.0

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
                Color.clear.onAppear { goToNextProfile() }
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
                ProfileHeaderView(profileName: currentProfile.name,
                                  profileImageURL: currentProfile.profilePictureURL)
                AnimatedProgressBarView(total: currentStories.count,
                                        currentIndex: currentStoryIndex,
                                        progress: segmentProgress)
                    .padding(.horizontal, 16)
                    .animation(.linear, value: segmentProgress)
                Spacer()
            }
            .padding(.top, 16)
            .zIndex(9999)
            .id(currentProfile.id)

            HStack(spacing: 0) {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { goToPreviousStory() }
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { goToNextStory() }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .zIndex(500)

            VStack {
                Spacer()
                Button {
                    let storyID = currentStories[currentStoryIndex].id
                    viewModel.toggleLike(storyID: storyID)
                    withAnimation(.easeInOut(duration: 0.2)) {
                        heartScale = 1.5
                    }
                    withAnimation(.easeInOut(duration: 0.2).delay(0.2)) {
                        heartScale = 1.0
                    }
                } label: {
                    Image(systemName: viewModel.isLiked(storyID: currentStories[currentStoryIndex].id) ? "heart.fill" : "heart")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                        .scaleEffect(heartScale)
                }
                .padding(.bottom, 40)
            }
            .zIndex(1000)
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
        .simultaneousGesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onEnded { value in
                    let horizontal = value.translation.width
                    if abs(horizontal) > 100 {
                        if horizontal > 0 {
                            goToPreviousProfile()
                        } else {
                            goToNextProfile()
                        }
                    }
                }
        )
        .onChange(of: currentProfileIndex) { _ in
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

    // MARK: - Navigation functions

    func goToNextStory() {
        manualNavigation = true
        let currentID = currentStories[currentStoryIndex].id
        viewModel.markStoryAsSeen(storyID: currentID)

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
