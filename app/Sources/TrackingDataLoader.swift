import Foundation

struct TrackingData: Codable {
    let version: String
    let frames: [TrackingFrame]
}

struct TrackingFrame: Codable {
    let timestamp: TimeInterval
    let players: [PlayerData]
    let ballPosition: [Float]?
    
    enum CodingKeys: String, CodingKey {
        case timestamp
        case players
        case ballPosition = "ball_position"
    }
}

struct PlayerData: Codable {
    let id: String
    let position: [Float]
    let team: String
}

class TrackingDataLoader {
    static func load(from url: URL) async throws -> TrackingData {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(TrackingData.self, from: data)
    }
    
    static func convertToPlayerEntities(_ trackingData: TrackingData) -> [Player] {
        let latestFrame = trackingData.frames.last
        return latestFrame?.players.map { playerData in
            Player(
                id: playerData.id,
                position: SIMD2(x: playerData.position[0], y: playerData.position[1]),
                team: playerData.team == "home" ? .home : .away
            )
        } ?? []
    }
    
    static func convertToBallPosition(_ trackingData: TrackingData) -> SIMD2<Float>? {
        guard let latestFrame = trackingData.frames.last,
              let ballPosition = latestFrame.ballPosition,
              ballPosition.count >= 2 else {
            return nil
        }
        
        return SIMD2(x: ballPosition[0], y: ballPosition[1])
    }
} 