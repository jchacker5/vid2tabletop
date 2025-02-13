import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let url: URL
    @StateObject private var playerViewModel = VideoPlayerViewModel()
    
    var body: some View {
        VideoPlayer(player: playerViewModel.player)
            .onAppear {
                playerViewModel.setupPlayer(with: url)
            }
            .onDisappear {
                playerViewModel.cleanup()
            }
            .ornament(
                visibility: playerViewModel.isPlaying ? .hidden : .visible,
                attachmentAnchor: .scene
            ) {
                Button(action: { playerViewModel.togglePlayback() }) {
                    Image(systemName: playerViewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                }
            }
    }
}

class VideoPlayerViewModel: ObservableObject {
    @Published var isPlaying = false
    let player = AVPlayer()
    private var timeObserver: Any?
    
    func setupPlayer(with url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        
        // Add time observer for synchronization with 3D view
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1/30, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            queue: .main
        ) { [weak self] time in
            // Notify about playback position for 3D sync
            NotificationCenter.default.post(
                name: .playbackPositionChanged,
                object: nil,
                userInfo: ["time": time]
            )
        }
    }
    
    func togglePlayback() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
    
    func cleanup() {
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
        }
        player.pause()
    }
}

extension Notification.Name {
    static let playbackPositionChanged = Notification.Name("playbackPositionChanged")
} 