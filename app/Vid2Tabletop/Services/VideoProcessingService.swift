import Foundation
import Vision
import AVFoundation
import YouTubeiOSPlayerHelper
import RealityKit
import CoreML
import PythonKit

/// Service responsible for processing YouTube videos and converting them to 3D tabletop representations
@MainActor
class VideoProcessingService: NSObject, ObservableObject, YTPlayerViewDelegate {
    static let shared = VideoProcessingService()
    private let courtVisualizer = CourtVisualizer.shared
    private let yoloProcessor = YOLOProcessingService.shared
    
    @Published private(set) var player: AVPlayer?
    @Published private(set) var isProcessing = false
    @Published private(set) var processingProgress: Double = 0
    @Published private(set) var gameMetadata: GameMetadata?
    
    private var playerView: YTPlayerView?
    private var videoAsset: AVAsset?
    private var timeObserver: Any?
    
    enum VideoProcessingError: Error {
        case invalidURL
        case downloadFailed
        case processingFailed
        case courtDetectionFailed
        case playerDetectionFailed
        case ballDetectionFailed
        case yoloError(String)
    }
    
    private override init() {
        super.init()
        setupTimeObserver()
    }
    
    private func setupTimeObserver() {
        // Observe video playback time for synchronization
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            self?.updateVisualization(at: time)
        }
    }
    
    /// Process a YouTube video and convert it to a 3D tabletop representation
    /// - Parameters:
    ///   - url: The YouTube video URL
    ///   - progressHandler: Closure to report processing progress (0.0 to 1.0)
    /// - Throws: VideoProcessingError if processing fails
    func processYouTubeVideo(url: String, progressHandler: @escaping (Double) -> Void) async throws {
        isProcessing = true
        processingProgress = 0
        
        guard let videoID = extractYouTubeID(from: url) else {
            throw VideoProcessingError.invalidURL
        }
        
        // Initialize video playback
        try await setupVideoPlayback(videoID: videoID)
        
        // Process video using YOLO
        let trackingResults = try await yoloProcessor.processVideo(url: url) { progress in
            processingProgress = progress * 0.7 // YOLO processing is 70% of total progress
            progressHandler(processingProgress)
        }
        
        // Convert tracking results to 3D coordinates
        let coordinates = try await convertToTableTop(
            players: trackingResults.players,
            ball: trackingResults.ball.first
        )
        
        // Extract game metadata
        gameMetadata = try await extractGameMetadata(from: url)
        
        // Update visualization
        courtVisualizer.updatePlayerPositions(coordinates.players)
        if let ballPos = coordinates.ballPosition {
            courtVisualizer.updateBallPosition(ballPos)
        }
        
        isProcessing = false
        processingProgress = 1.0
        progressHandler(1.0)
    }
    
    private func setupVideoPlayback(videoID: String) async throws {
        // Create YouTube player view
        let playerView = YTPlayerView()
        playerView.delegate = self
        self.playerView = playerView
        
        // Load video
        return try await withCheckedThrowingContinuation { continuation in
            playerView.load(withVideoId: videoID, playerVars: [
                "playsinline": 1,
                "controls": 1,
                "modestbranding": 1,
                "rel": 0
            ])
            
            // Wait for video to be ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                continuation.resume()
            }
        }
    }
    
    private func updateVisualization(at time: CMTime) {
        // Update court visualization based on current video time
        Task {
            if let currentFrame = try? await extractFrame(at: time) {
                let results = try? await yoloProcessor.processFrame(currentFrame)
                if let results = results {
                    let coordinates = try? await convertToTableTop(
                        players: results.players,
                        ball: results.ball.first
                    )
                    if let coordinates = coordinates {
                        courtVisualizer.updatePlayerPositions(coordinates.players)
                        if let ballPos = coordinates.ballPosition {
                            courtVisualizer.updateBallPosition(ballPos)
                        }
                    }
                }
            }
        }
    }
    
    private func extractFrame(at time: CMTime) async throws -> CGImage {
        guard let asset = videoAsset else {
            throw VideoProcessingError.processingFailed
        }
        
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        return try await withCheckedThrowingContinuation { continuation in
            generator.generateCGImageAsynchronously(for: time) { image, _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let image = image {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(throwing: VideoProcessingError.processingFailed)
                }
            }
        }
    }
    
    private func extractYouTubeID(from url: String) -> String? {
        let patterns = [
            "(?<=v=)[a-zA-Z0-9_-]{11}",
            "(?<=be/)[a-zA-Z0-9_-]{11}",
            "(?<=embed/)[a-zA-Z0-9_-]{11}",
            "(?<=youtu.be/)[a-zA-Z0-9_-]{11}"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)) {
                let range = Range(match.range, in: url)!
                return String(url[range])
            }
        }
        return nil
    }
    
    private func downloadAndExtractFrames(videoID: String) async throws -> [CGImage] {
        return try await withCheckedThrowingContinuation { continuation in
            // Initialize YouTube player view
            let playerView = YTPlayerView()
            self.playerView = playerView
            
            // Load video and extract frames
            playerView.load(withVideoId: videoID, playerVars: [
                "playsinline": 1,
                "controls": 0,
                "modestbranding": 1
            ])
            
            // Extract frames using AVFoundation
            // Note: This is a placeholder. Real implementation would need to:
            // 1. Wait for video to load
            // 2. Extract frames at regular intervals
            // 3. Handle memory management for large videos
            continuation.resume(throwing: VideoProcessingError.processingFailed)
        }
    }
    
    private func detectCourtPlayersAndBall(in frames: [CGImage]) async throws -> (CourtData, [VNHumanBodyPoseObservation], CGPoint?) {
        var courtData = CourtData()
        var playerObservations: [VNHumanBodyPoseObservation] = []
        var ballPositions: [CGPoint] = []
        
        // Configure Vision requests
        let courtRequest = VNDetectRectanglesRequest()
        courtRequest.minimumAspectRatio = 1.5 // Court is typically rectangular
        courtRequest.maximumAspectRatio = 2.5
        
        let playerRequest = VNDetectHumanBodyPoseRequest()
        
        // Ball detection request (if model is available)
        var requests: [VNRequest] = [courtRequest, playerRequest]
        if let ballDetector = ballDetector {
            let ballRequest = VNCoreMLRequest(model: ballDetector)
            requests.append(ballRequest)
        }
        
        for frame in frames {
            let handler = VNImageRequestHandler(cgImage: frame)
            try await handler.perform(requests)
            
            if let courtResults = courtRequest.results {
                courtData.updateWithDetections(courtResults)
            }
            
            if let playerResults = playerRequest.results as? [VNHumanBodyPoseObservation] {
                playerObservations.append(contentsOf: playerResults)
            }
            
            if let ballRequest = requests.last as? VNCoreMLRequest,
               let results = ballRequest.results as? [VNRecognizedObjectObservation],
               let ballObservation = results.first(where: { $0.labels.first?.identifier == "basketball" }) {
                ballPositions.append(ballObservation.boundingBox.center)
            }
        }
        
        // Use median position for ball to reduce noise
        let medianBallPosition = ballPositions.isEmpty ? nil : calculateMedianPosition(ballPositions)
        
        return (courtData, playerObservations, medianBallPosition)
    }
    
    private func calculateMedianPosition(_ positions: [CGPoint]) -> CGPoint {
        let sortedX = positions.map { $0.x }.sorted()
        let sortedY = positions.map { $0.y }.sorted()
        
        let midIndex = positions.count / 2
        let medianX = sortedX[midIndex]
        let medianY = sortedY[midIndex]
        
        return CGPoint(x: medianX, y: medianY)
    }
    
    private func convertToTableTop(
        players: [TrackingResult],
        ball: TrackingResult?
    ) async throws -> (players: [PlayerPosition], ballPosition: SIMD3<Float>?) {
        // Convert player positions to 3D space
        let playerPositions = players.map { result -> PlayerPosition in
            let center = result.boundingBox.center
            return PlayerPosition(
                position: SIMD3<Float>(
                    Float(center.x),
                    0,
                    Float(center.y)
                ),
                confidence: result.confidence
            )
        }
        
        // Convert ball position if available
        var ballPos: SIMD3<Float>? = nil
        if let ball = ball {
            let center = ball.boundingBox.center
            ballPos = SIMD3<Float>(
                Float(center.x),
                0.1, // Slightly above court
                Float(center.y)
            )
        }
        
        return (players: playerPositions, ballPosition: ballPos)
    }
    
    private func extractGameMetadata(from url: String) async throws -> GameMetadata {
        // Use Vision's text recognition to extract game clock and score
        // This is a placeholder implementation
        return GameMetadata(
            gameClock: "12:00",
            quarter: 1,
            homeScore: 0,
            awayScore: 0
        )
    }
    
    // MARK: - YTPlayerViewDelegate
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        // Create AVPlayer for synchronized playback
        if let videoURL = playerView.videoUrl {
            let asset = AVAsset(url: videoURL)
            self.videoAsset = asset
            let playerItem = AVPlayerItem(asset: asset)
            self.player = AVPlayer(playerItem: playerItem)
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch state {
        case .playing:
            player?.play()
        case .paused:
            player?.pause()
        case .ended:
            player?.seek(to: .zero)
        default:
            break
        }
    }
}

/// Represents the court's perspective transform
struct CourtTransform {
    func transform(position: CGPoint) -> CGPoint {
        // Implementation would transform 2D screen coordinates to court coordinates
        return position
    }
}

/// Represents detected court features and player positions
struct CourtData {
    var courtLines: [VNRectangleObservation] = []
    var playerPositions: [CGPoint] = []
    
    mutating func updateWithDetections(_ detections: [VNObservation]) {
        guard let rectangles = detections as? [VNRectangleObservation] else { return }
        
        // Filter and update court lines based on size and position
        courtLines = rectangles.filter { rectangle in
            // Add filtering logic for court line detection
            return true
        }
    }
}

/// Represents game metadata extracted from the video
struct GameMetadata {
    let gameClock: String
    let quarter: Int
    let homeScore: Int
    let awayScore: Int
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
} 
