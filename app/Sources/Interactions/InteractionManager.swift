import SwiftUI
import RealityKit
import ARKit

class InteractionManager: ObservableObject {
    // MARK: - Properties
    @Published var selectedPlayer: Player?
    @Published var cameraAngle: SIMD3<Float> = .zero
    @Published var tableScale: Float = 1.0
    
    // Voice command recognition
    private let speechRecognizer = SFSpeechRecognizer()
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // Eye tracking
    private var focusEntity: Entity?
    private var lastGazeTimestamp: TimeInterval = 0
    
    // MARK: - Gesture Handlers
    
    func handlePinchGesture(_ gesture: MagnifyGesture.Value) {
        tableScale *= Float(gesture.magnification)
        tableScale = min(max(tableScale, 0.5), 2.0)
    }
    
    func handleRotationGesture(_ gesture: RotateGesture.Value) {
        let rotation = Float(gesture.rotation.radians)
        cameraAngle.y += rotation
    }
    
    func handleTapGesture(at location: CGPoint, in view: ARView) {
        guard let result = view.raycast(from: location, allowing: .estimatedPlane, alignment: .any).first else {
            return
        }
        
        if let tappedEntity = result.entity as? ModelEntity,
           let playerId = tappedEntity.name,
           let player = findPlayer(with: playerId) {
            selectedPlayer = player
        }
    }
    
    // MARK: - Voice Commands
    
    func startVoiceRecognition() {
        guard let recognizer = speechRecognizer else { return }
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let result = result else { return }
            
            let command = result.bestTranscription.formattedString.lowercased()
            self?.handleVoiceCommand(command)
        }
    }
    
    private func handleVoiceCommand(_ command: String) {
        switch command {
        case "show stats":
            // Show stats for currently focused player
            if let focusedPlayer = findPlayerInFocus() {
                selectedPlayer = focusedPlayer
            }
            
        case "switch camera":
            // Cycle through preset camera angles
            cycleCameraAngle()
            
        case let cmd where cmd.starts(with: "track player"):
            // Extract player number and focus on that player
            if let number = cmd.components(separatedBy: " ").last,
               let playerNumber = Int(number),
               let player = findPlayer(with: String(playerNumber)) {
                selectedPlayer = player
                focusOnPlayer(player)
            }
            
        case "show replay":
            // Trigger replay of recent action
            triggerReplay()
            
        default:
            break
        }
    }
    
    // MARK: - Eye Tracking
    
    func updateGaze(_ point: CGPoint, in view: ARView) {
        let currentTime = CACurrentMediaTime()
        guard currentTime - lastGazeTimestamp > 0.1 else { return }
        
        lastGazeTimestamp = currentTime
        
        if let result = view.raycast(from: point, allowing: .estimatedPlane, alignment: .any).first,
           let gazedEntity = result.entity as? ModelEntity {
            
            // Highlight gazed entity
            if gazedEntity != focusEntity {
                focusEntity?.removeHighlight()
                gazedEntity.addHighlight()
                focusEntity = gazedEntity
            }
            
            // Show quick stats if gaze persists
            if currentTime - lastGazeTimestamp > 1.0 {
                if let playerId = gazedEntity.name,
                   let player = findPlayer(with: playerId) {
                    showQuickStats(for: player)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func findPlayer(with id: String) -> Player? {
        // Implementation would search through active players
        nil
    }
    
    private func findPlayerInFocus() -> Player? {
        guard let focusEntity = focusEntity,
              let playerId = focusEntity.name else {
            return nil
        }
        return findPlayer(with: playerId)
    }
    
    private func cycleCameraAngle() {
        let presetAngles: [SIMD3<Float>] = [
            .zero,
            SIMD3(x: 0, y: .pi/2, z: 0),
            SIMD3(x: .pi/4, y: 0, z: 0),
            SIMD3(x: .pi/4, y: .pi/2, z: 0)
        ]
        
        let currentIndex = presetAngles.firstIndex { abs($0.y - cameraAngle.y) < 0.1 } ?? 0
        let nextIndex = (currentIndex + 1) % presetAngles.count
        cameraAngle = presetAngles[nextIndex]
    }
    
    private func focusOnPlayer(_ player: Player) {
        // Implementation would move camera to follow player
    }
    
    private func triggerReplay() {
        // Implementation would show replay of recent action
    }
    
    private func showQuickStats(for player: Player) {
        // Implementation would show floating stats near player
    }
}

// MARK: - Entity Extensions

extension ModelEntity {
    func addHighlight() {
        // Add glow effect or outline
        if let model = try? ModelEntity.load(named: "highlight") {
            model.scale = self.scale * 1.05
            self.addChild(model)
        }
    }
    
    func removeHighlight() {
        // Remove highlight effect
        self.children.forEach { child in
            if child.name == "highlight" {
                child.removeFromParent()
            }
        }
    }
} 