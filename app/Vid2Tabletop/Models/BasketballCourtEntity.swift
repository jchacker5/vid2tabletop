import RealityKit
import SwiftUI

class BasketballCourtEntity: Entity {
    required init() {
        super.init()
        
        // Create court floor
        let floorMesh = MeshResource.generatePlane(width: 0.5, depth: 0.94) // NBA court proportions
        let floorMaterial = SimpleMaterial(color: .init(white: 0.9), isMetallic: false)
        let floor = ModelEntity(mesh: floorMesh, materials: [floorMaterial])
        
        // Create court lines
        let lineMaterial = SimpleMaterial(color: .black, isMetallic: false)
        
        // Center line
        let centerLineMesh = MeshResource.generatePlane(width: 0.002, depth: 0.94)
        let centerLine = ModelEntity(mesh: centerLineMesh, materials: [lineMaterial])
        centerLine.position.y = 0.001 // Slightly above floor
        
        // Three-point lines
        let threePointRadius: Float = 0.23 // Scaled down from real dimensions
        let threePointArc1 = createThreePointArc(radius: threePointRadius, material: lineMaterial)
        let threePointArc2 = createThreePointArc(radius: threePointRadius, material: lineMaterial)
        threePointArc2.transform = .init(scale: [1, 1, -1]) // Mirror for other side
        
        // Add all components
        addChild(floor)
        addChild(centerLine)
        addChild(threePointArc1)
        addChild(threePointArc2)
        
        // Add hoops
        let hoop1 = createHoop()
        let hoop2 = createHoop()
        hoop1.position = [0, 0, 0.47]
        hoop2.position = [0, 0, -0.47]
        addChild(hoop1)
        addChild(hoop2)
    }
    
    private func createThreePointArc(radius: Float, material: Material) -> ModelEntity {
        let path = UIBezierPath()
        path.addArc(withCenter: .zero,
                   radius: CGFloat(radius),
                   startAngle: -.pi/2,
                   endAngle: .pi/2,
                   clockwise: true)
        
        let shape = ShapeResource.generatePath(path)
        return ModelEntity(mesh: .generatePlane(width: 0.002, depth: radius * 2),
                         materials: [material])
    }
    
    private func createHoop() -> Entity {
        let hoopEntity = Entity()
        
        // Create backboard
        let backboardMesh = MeshResource.generatePlane(width: 0.06, height: 0.04)
        let backboardMaterial = SimpleMaterial(color: .white, isMetallic: true)
        let backboard = ModelEntity(mesh: backboardMesh, materials: [backboardMaterial])
        
        // Create rim
        let rimRadius: Float = 0.015
        let rimMesh = MeshResource.generateTorus(ringRadius: rimRadius, pipeRadius: 0.002)
        let rimMaterial = SimpleMaterial(color: .orange, isMetallic: true)
        let rim = ModelEntity(mesh: rimMesh, materials: [rimMaterial])
        rim.position = [0, -0.02, 0.02]
        
        hoopEntity.addChild(backboard)
        hoopEntity.addChild(rim)
        
        return hoopEntity
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
} 