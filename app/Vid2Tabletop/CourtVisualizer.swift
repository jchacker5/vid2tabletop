import RealityKit
import SwiftUI

class CourtVisualizer {
    static let shared = CourtVisualizer()
    
    private var courtEntity: Entity?
    private var playerEntities: [Entity] = []
    private var ballEntity: Entity?
    
    private init() {}
    
    func setupCourt(in content: RealityViewContent) async throws {
        // Load the basketball court model
        guard let courtModel = try? await Entity(named: "BasketballCourt") else {
            throw VisualizationError.modelLoadingFailed
        }
        
        courtEntity = courtModel
        content.add(courtModel)
        
        // Set up initial court position and scale
        courtModel.transform.scale = [0.1, 0.1, 0.1]
        courtModel.position = [0, 0, 0]
    }
    
    func updatePlayerPositions(_ positions: [PlayerPosition]) {
        // Clear existing player entities
        playerEntities.forEach { $0.removeFromParent() }
        playerEntities.removeAll()
        
        // Create new player entities
        for position in positions {
            let playerEntity = createPlayerEntity(at: position)
            playerEntities.append(playerEntity)
            courtEntity?.addChild(playerEntity)
        }
    }
    
    func updateBallPosition(_ position: SIMD3<Float>) {
        if ballEntity == nil {
            ballEntity = createBallEntity()
            courtEntity?.addChild(ballEntity!)
        }
        
        ballEntity?.position = position
    }
    
    private func createPlayerEntity(at position: PlayerPosition) -> Entity {
        let mesh = MeshResource.generateSphere(radius: 0.02)
        let material = SimpleMaterial(color: .blue, roughness: 0.5, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position = position.position
        return entity
    }
    
    private func createBallEntity() -> Entity {
        let mesh = MeshResource.generateSphere(radius: 0.015)
        let material = SimpleMaterial(color: .orange, roughness: 0.3, isMetallic: false)
        return ModelEntity(mesh: mesh, materials: [material])
    }
    
    enum VisualizationError: Error {
        case modelLoadingFailed
    }
} 