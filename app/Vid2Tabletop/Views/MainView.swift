import SwiftUI
import RealityKit
import RealityKitContent
import AVKit

struct MainView: View {
    @State private var show2DVideo = true
    @State private var windowLayout: WindowLayout = .sideBySide
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    enum WindowLayout {
        case sideBySide
        case stackedVertical
        case tableTopOnly
    }
    
    var body: some View {
        @Bindable var courtVisualizer = CourtVisualizer.shared
        
        NavigationStack {
            HStack(spacing: 0) {
                // 3D Tabletop View
                TabletopView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // 2D Video View (Optional)
                if show2DVideo {
                    VideoPlayerView()
                        .frame(maxWidth: windowLayout == .sideBySide ? .infinity : nil,
                               maxHeight: windowLayout == .stackedVertical ? .infinity : nil)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    // Layout Controls
                    Menu {
                        Button(action: { windowLayout = .sideBySide }) {
                            Label("Side by Side", systemImage: "rectangle.split.2x1")
                        }
                        Button(action: { windowLayout = .stackedVertical }) {
                            Label("Stacked", systemImage: "rectangle.split.1x2")
                        }
                        Button(action: { windowLayout = .tableTopOnly }) {
                            Label("Tabletop Only", systemImage: "rectangle")
                        }
                    } label: {
                        Label("Layout", systemImage: "rectangle.3.group")
                    }
                    
                    // Toggle 2D Video
                    Toggle(isOn: $show2DVideo) {
                        Label("Show 2D Video", systemImage: "video")
                    }
                    
                    // Settings
                    Button(action: { openWindow(id: "settings") }) {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .ornament(attachmentAnchor: .scene) {
                VStack {
                    if courtVisualizer.isProcessing {
                        ProgressView("Processing Video", value: courtVisualizer.processingProgress)
                            .progressViewStyle(.circular)
                            .padding()
                    }
                    
                    if let metadata = courtVisualizer.gameMetadata {
                        GameMetadataView(metadata: metadata)
                            .padding()
                    }
                }
                .ornamentBackground(.regularMaterial)
            }
        }
    }
}

struct TabletopView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var courtScale: Float = 1.0
    @State private var courtRotation: Float = 0.0
    
    var body: some View {
        RealityView { content in
            // Load the basketball court model
            Task {
                try? await CourtVisualizer.shared.setupCourt(in: content)
            }
        }
        .gesture(
            // Pinch to scale
            MagnifyGesture()
                .onChanged { value in
                    courtScale = Float(value.magnification)
                }
        )
        .gesture(
            // Rotate with two fingers
            RotateGesture()
                .onChanged { value in
                    courtRotation = Float(value.rotation.degrees)
                }
        )
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // Recenter view when becoming active
                Task {
                    try? await CourtVisualizer.shared.recenterCourt()
                }
            }
        }
    }
}

struct VideoPlayerView: View {
    @ObservedObject private var videoProcessor = VideoProcessingService.shared
    
    var body: some View {
        Group {
            if let player = videoProcessor.player {
                VideoPlayer(player: player)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
            } else {
                ContentUnavailableView(
                    "No Video",
                    systemImage: "video.slash",
                    description: Text("Load a YouTube video to begin")
                )
            }
        }
    }
}

struct GameMetadataView: View {
    let metadata: GameMetadata
    
    var body: some View {
        HStack(spacing: 20) {
            Text(metadata.gameClock)
                .font(.title)
                .monospacedDigit()
            
            Text("Q\(metadata.quarter)")
                .font(.headline)
            
            HStack(spacing: 8) {
                Text("\(metadata.homeScore)")
                    .font(.title2)
                Text("-")
                Text("\(metadata.awayScore)")
                    .font(.title2)
            }
            .monospacedDigit()
        }
    }
} 