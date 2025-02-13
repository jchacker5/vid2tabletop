import Foundation
import Vision
import CoreML
import PythonKit

/// Service responsible for YOLO-based object detection and tracking
class YOLOProcessingService {
    static let shared = YOLOProcessingService()
    private let torch = Python.import("torch")
    private let YOLO = Python.import("ultralytics").YOLO
    
    // YOLO models for different detection tasks
    private lazy var playerDetectionModel = YOLO("yolov8n-pose.pt")  // For player pose detection
    private lazy var ballDetectionModel = YOLO("yolov8n.pt")  // For ball detection
    private lazy var trackingModel = YOLO("yolov8n.pt")  // For object tracking
    
    private init() {
        setupModels()
    }
    
    private func setupModels() {
        // Configure models for optimal performance on Vision Pro
        let device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
        playerDetectionModel.to(device)
        ballDetectionModel.to(device)
        trackingModel.to(device)
    }
    
    /// Process video frames using YOLO for detection and tracking
    /// - Parameters:
    ///   - videoURL: URL of the YouTube video
    ///   - progressHandler: Closure to report processing progress
    /// - Returns: Tuple containing player and ball tracking results
    func processVideo(url: String, progressHandler: @escaping (Double) -> Void) async throws -> (players: [TrackingResult], ball: [TrackingResult]) {
        // Track players using pose detection
        let playerResults = try await trackPlayers(url: url, progressHandler: { progress in
            progressHandler(progress * 0.5) // First half of progress
        })
        
        // Track ball using object detection
        let ballResults = try await trackBall(url: url, progressHandler: { progress in
            progressHandler(0.5 + progress * 0.5) // Second half of progress
        })
        
        return (players: playerResults, ball: ballResults)
    }
    
    private func trackPlayers(url: String, progressHandler: @escaping (Double) -> Void) async throws -> [TrackingResult] {
        let results = try await Python.await(playerDetectionModel.track(
            url,
            show: false,
            tracker: "bytetrack.yaml",
            classes: [0], // Person class only
            conf: 0.5,
            iou: 0.45
        ))
        
        return convertPythonResults(results)
    }
    
    private func trackBall(url: String, progressHandler: @escaping (Double) -> Void) async throws -> [TrackingResult] {
        let results = try await Python.await(ballDetectionModel.track(
            url,
            show: false,
            tracker: "bytetrack.yaml",
            classes: [32], // Sports ball class
            conf: 0.4,
            iou: 0.3
        ))
        
        return convertPythonResults(results)
    }
    
    private func convertPythonResults(_ results: PythonObject) -> [TrackingResult] {
        var trackingResults: [TrackingResult] = []
        
        for result in results {
            let boxes = result.boxes
            let keypoints = result.keypoints
            
            for i in 0..<Python.len(boxes) {
                let box = boxes[i]
                let trackID = Int(box.id.item()) ?? -1
                let confidence = Float(box.conf.item()) ?? 0.0
                let bbox = box.xyxy[0].tolist()
                
                var keypointArray: [CGPoint] = []
                if keypoints != Python.None {
                    let points = keypoints[i].data[0].tolist()
                    for j in stride(from: 0, to: Python.len(points), by: 3) {
                        keypointArray.append(CGPoint(
                            x: CGFloat(Float(points[j].item()) ?? 0),
                            y: CGFloat(Float(points[j+1].item()) ?? 0)
                        ))
                    }
                }
                
                trackingResults.append(TrackingResult(
                    id: trackID,
                    boundingBox: CGRect(
                        x: CGFloat(Float(bbox[0].item()) ?? 0),
                        y: CGFloat(Float(bbox[1].item()) ?? 0),
                        width: CGFloat(Float(bbox[2].item()) ?? 0) - CGFloat(Float(bbox[0].item()) ?? 0),
                        height: CGFloat(Float(bbox[3].item()) ?? 0) - CGFloat(Float(bbox[1].item()) ?? 0)
                    ),
                    keypoints: keypointArray,
                    confidence: confidence
                ))
            }
        }
        
        return trackingResults
    }
}

/// Represents a single tracking result from YOLO
struct TrackingResult {
    let id: Int
    let boundingBox: CGRect
    let keypoints: [CGPoint]
    let confidence: Float
} 