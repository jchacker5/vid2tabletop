import Foundation
import RealityKit

struct Player: Identifiable, Codable {
    let id: String
    let number: Int
    let name: String
    let team: Team
    var position: SIMD3<Float>
    var rotation: simd_quatf
    var stats: PlayerStats
    var isSelected: Bool = false
    
    // Movement trail for visualization
    var recentPositions: [SIMD3<Float>] = []
    static let maxTrailLength = 60 // 2 seconds at 30fps
    
    mutating func updatePosition(_ newPosition: SIMD3<Float>) {
        // Add current position to trail
        recentPositions.append(position)
        if recentPositions.count > Self.maxTrailLength {
            recentPositions.removeFirst()
        }
        
        // Update current position
        position = newPosition
    }
}

enum Team: String, Codable {
    case home
    case away
    
    var color: UIColor {
        switch self {
        case .home:
            return .systemBlue
        case .away:
            return .systemRed
        }
    }
}

struct PlayerStats: Codable {
    var points: Int = 0
    var assists: Int = 0
    var rebounds: Int = 0
    var steals: Int = 0
    var blocks: Int = 0
    var fouls: Int = 0
    var minutesPlayed: TimeInterval = 0
    
    // Shooting stats
    var fieldGoalsMade: Int = 0
    var fieldGoalsAttempted: Int = 0
    var threePointersMade: Int = 0
    var threePointersAttempted: Int = 0
    var freeThrowsMade: Int = 0
    var freeThrowsAttempted: Int = 0
    
    // Computed properties
    var fieldGoalPercentage: Double {
        guard fieldGoalsAttempted > 0 else { return 0 }
        return Double(fieldGoalsMade) / Double(fieldGoalsAttempted) * 100
    }
    
    var threePointPercentage: Double {
        guard threePointersAttempted > 0 else { return 0 }
        return Double(threePointersMade) / Double(threePointersAttempted) * 100
    }
    
    var freeThrowPercentage: Double {
        guard freeThrowsAttempted > 0 else { return 0 }
        return Double(freeThrowsMade) / Double(freeThrowsAttempted) * 100
    }
    
    // Recent events for highlighting
    var recentEvents: [PlayerEvent] = []
}

struct PlayerEvent: Codable {
    enum EventType: String, Codable {
        case score
        case assist
        case rebound
        case steal
        case block
        case foul
    }
    
    let type: EventType
    let timestamp: TimeInterval
    let description: String
    
    var isRecent: Bool {
        // Consider events in the last 10 seconds as recent
        CACurrentMediaTime() - timestamp < 10
    }
} 