//
//  VideoStoryView.swift
//  StoryFeature
//
//  Created by Florianto on 22/03/2025.
//

import SwiftUI
import AVKit

struct VideoStoryView: View {
    let url: URL
    let startOffset: Double
    let onTimeUpdate: ((Double) -> Void)?

    @State private var player: AVPlayer?
    @State private var timeObserverToken: Any?

    var body: some View {
        Group {
            if let player {
                VideoPlayer(player: player)
                    .onDisappear { cleanUpPlayer() }
            } else {
                Color.black
                    .onAppear { setupPlayer() }
            }
        }
        .ignoresSafeArea()
    }

    private func setupPlayer() {
        let asset = AVAsset(url: url)

        Task {
            do {
                _ = try await asset.load(.isPlayable)

                let playerItem = AVPlayerItem(asset: asset)

                let endTime = CMTime(seconds: startOffset + 10, preferredTimescale: 1)
                playerItem.forwardPlaybackEndTime = endTime

                let newPlayer = AVPlayer(playerItem: playerItem)

                let interval = CMTime(seconds: 0.05, preferredTimescale: 600)
                let token = newPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { currentTime in
                    let elapsed = currentTime.seconds - startOffset
                    onTimeUpdate?(elapsed)
                }
                timeObserverToken = token

                let startTime = CMTime(seconds: startOffset, preferredTimescale: 1)
                newPlayer.seek(to: startTime, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
                    newPlayer.play()
                }

                self.player = newPlayer
            } catch {
                print("Error loading asset:", error)
            }
        }
    }

    private func cleanUpPlayer() {
        player?.pause()
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
        }
        timeObserverToken = nil
        self.player = nil
    }
}
