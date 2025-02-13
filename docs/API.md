# Vid2Tabletop API Reference

## Core Services

### VideoProcessingService

Main service responsible for video processing and synchronization.

```swift
class VideoProcessingService: ObservableObject {
    // Published Properties
    @Published private(set) var player: AVPlayer?
    @Published private(set) var isProcessing: Bool
    @Published private(set) var processingProgress: Double
    @Published private(set) var gameMetadata: GameMetadata?

    // Main Processing Method
    func processYouTubeVideo(url: String, progressHandler: @escaping (Double) -> Void) async throws
}
```

#### Key Methods

- `processYouTubeVideo(url:progressHandler:)`: Process YouTube video and convert to 3D
- `setupVideoPlayback(videoID:)`: Initialize video playback
- `updateVisualization(at:)`: Update 3D visualization at specific time
- `extractFrame(at:)`: Extract video frame at specific time

### YOLOProcessingService

Handles ML-based detection and tracking using YOLO.

```swift
class YOLOProcessingService {
    // Main Processing Methods
    func processVideo(url: String, progressHandler: @escaping (Double) -> Void) async throws -> (players: [TrackingResult], ball: [TrackingResult])
    func processFrame(_ frame: CGImage) async throws -> (players: [TrackingResult], ball: [TrackingResult])
}
```

#### Key Methods

- `processVideo(url:progressHandler:)`: Process entire video for tracking
- `processFrame(_:)`: Process single frame for real-time tracking
- `trackPlayers(url:progressHandler:)`: Track player positions
- `trackBall(url:progressHandler:)`: Track ball position

### CourtVisualizer

Manages 3D visualization using RealityKit.

```swift
class CourtVisualizer {
    // Setup and Update Methods
    func setupCourt(in content: RealityViewContent) async throws
    func updatePlayerPositions(_ positions: [PlayerPosition])
    func updateBallPosition(_ position: SIMD3<Float>)
    func updateGameMetadata(_ metadata: GameMetadata)
}
```

## Views

### MainView

Primary app interface with window management.

```swift
struct MainView: View {
    // State Properties
    @State private var show2DVideo: Bool
    @State private var windowLayout: WindowLayout

    // Window Layout Options
    enum WindowLayout {
        case sideBySide
        case stackedVertical
        case tableTopOnly
    }
}
```

### TabletopView

3D court visualization with gesture controls.

```swift
struct TabletopView: View {
    // State Properties
    @State private var courtScale: Float
    @State private var courtRotation: Float

    // Gesture Support
    // - Pinch to zoom
    // - Rotate with two fingers
    // - Drag to move
}
```

## Data Models

### TrackingResult

Represents a single tracking result from YOLO.

```swift
struct TrackingResult {
    let id: Int
    let boundingBox: CGRect
    let keypoints: [CGPoint]
    let confidence: Float
}
```

### GameMetadata

Represents game metadata extracted from video.

```swift
struct GameMetadata {
    let gameClock: String
    let quarter: Int
    let homeScore: Int
    let awayScore: Int
}
```

## Usage Examples

### Processing a YouTube Video

```swift
let videoProcessor = VideoProcessingService.shared

do {
    try await videoProcessor.processYouTubeVideo(url: "https://youtube.com/watch?v=...") { progress in
        print("Processing: \(progress * 100)%")
    }
} catch {
    print("Error processing video: \(error)")
}
```

### Updating Court Visualization

```swift
let courtVisualizer = CourtVisualizer.shared

// Update player positions
courtVisualizer.updatePlayerPositions(playerPositions)

// Update ball position
courtVisualizer.updateBallPosition(ballPosition)

// Update game metadata
courtVisualizer.updateGameMetadata(metadata)
```
