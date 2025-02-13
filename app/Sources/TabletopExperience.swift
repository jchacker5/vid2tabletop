import SwiftUI
import RealityKit
import RealityKitContent

struct TabletopExperience: View {
    @StateObject private var viewModel = TabletopViewModel()
    
    var body: some View {
        RealityView { content in
            // Create the basketball court
            guard let courtEntity = try? await Entity(named: "BasketballCourt", in: realityKitContentBundle) else {
                return
            }
            
            // Position the court
            courtEntity.position = SIMD3(x: 0, y: 0, z: 0)
            courtEntity.scale = SIMD3(x: 0.1, y: 0.1, z: 0.1) // Adjust scale as needed
            
            content.add(courtEntity)
            
            // Add player entities
            for player in viewModel.players {
                let playerEntity = createPlayerEntity(for: player)
                content.add(playerEntity)
            }
            
            // Add ball entity if available
            if let ballEntity = viewModel.ballEntity {
                content.add(ballEntity)
            }
            
        } update: { content in
            // Update player positions
            viewModel.updatePlayerPositions(in: content)
            
            // Update ball position
            viewModel.updateBallPosition(in: content)
        }
    }
}

class TabletopViewModel: ObservableObject {
    @Published var players: [Player] = []
    @Published var ballEntity: Entity?
    
    private var trackingData: [TrackingFrame] = []
    
    func loadTrackingData(from url: URL) async {
        // Load and parse tracking data from YOLO output
        // This would be the output from your Python tracking pipeline
    }
    
    func updatePlayerPositions(in content: RealityViewContent) {
        // Update player positions based on tracking data
        for player in players {
            if let entity = content.entities.first(where: { $0.name == player.id }) {
                // Convert 2D coordinates to 3D space
                let position = convert2DTo3D(player.position)
                entity.position = position
            }
        }
    }
    
    func updateBallPosition(in content: RealityViewContent) {
        // Update ball position based on tracking data
        if let ballEntity = content.entities.first(where: { $0.name == "ball" }) {
            // Convert 2D coordinates to 3D space
            if let ballPosition = trackingData.last?.ballPosition {
                let position = convert2DTo3D(ballPosition)
                ballEntity.position = position
            }
        }
    }
    
    private func convert2DTo3D(_ position: SIMD2<Float>) -> SIMD3<Float> {
        // Convert 2D court coordinates to 3D space
        // This would use your calibration matrix and perspective transformation
        return SIMD3(x: position.x, y: 0.1, z: position.y)
    }
}

struct Player: Identifiable {
    let id: String
    var position: SIMD2<Float>
    var team: Team
}

enum Team {
    case home
    case away
}

struct TrackingFrame {
    let timestamp: TimeInterval
    let players: [Player]
    let ballPosition: SIMD2<Float>?
}

private func createPlayerEntity(for player: Player) -> Entity {
    let entity = Entity()
    
    // Create a simple cylinder for player representation
    var material = PhysicallyBasedMaterial()
    material.baseColor = PhysicallyBasedMaterial.BaseColor(
        tint: player.team == .home ? .blue : .red
    )
    
    let mesh = MeshResource.generateCylinder(height: 0.2, radius: 0.05)
    let modelComponent = ModelComponent(mesh: mesh, materials: [material])
    entity.components.set(modelComponent)
    
    entity.name = player.id
    entity.position = SIMD3(x: player.position.x, y: 0.1, z: player.position.y)
    
    return entity
} 