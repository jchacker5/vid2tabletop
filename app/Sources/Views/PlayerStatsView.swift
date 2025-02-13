import SwiftUI
import RealityKit

struct PlayerStatsView: View {
    let player: Player
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("\(player.number)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color(player.team.color))
                
                Text(player.name)
                    .font(.title)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            
            // Main Stats
            HStack(spacing: 30) {
                StatBox(title: "PTS", value: "\(player.stats.points)")
                StatBox(title: "AST", value: "\(player.stats.assists)")
                StatBox(title: "REB", value: "\(player.stats.rebounds)")
            }
            
            // Shooting Stats
            VStack(spacing: 15) {
                ShootingStatRow(
                    title: "Field Goals",
                    made: player.stats.fieldGoalsMade,
                    attempted: player.stats.fieldGoalsAttempted,
                    percentage: player.stats.fieldGoalPercentage
                )
                
                ShootingStatRow(
                    title: "3-Pointers",
                    made: player.stats.threePointersMade,
                    attempted: player.stats.threePointersAttempted,
                    percentage: player.stats.threePointPercentage
                )
                
                ShootingStatRow(
                    title: "Free Throws",
                    made: player.stats.freeThrowsMade,
                    attempted: player.stats.freeThrowsAttempted,
                    percentage: player.stats.freeThrowPercentage
                )
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            
            // Recent Events
            if !player.stats.recentEvents.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Events")
                        .font(.headline)
                    
                    ForEach(player.stats.recentEvents.filter(\.isRecent), id: \.timestamp) { event in
                        HStack {
                            Image(systemName: iconForEvent(event.type))
                                .foregroundColor(colorForEvent(event.type))
                            
                            Text(event.description)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text(formatTimestamp(event.timestamp))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
            }
        }
        .padding()
        .frame(width: 400)
        .background(.thinMaterial)
        .cornerRadius(20)
        .ornament(attachmentAnchor: .scene(.trailing)) {
            PlayerTrailView(positions: player.recentPositions)
        }
    }
    
    private func iconForEvent(_ type: PlayerEvent.EventType) -> String {
        switch type {
        case .score: return "basketball.fill"
        case .assist: return "hand.point.up.fill"
        case .rebound: return "arrow.down.circle.fill"
        case .steal: return "hand.raised.fill"
        case .block: return "hand.raised.slash.fill"
        case .foul: return "exclamationmark.circle.fill"
        }
    }
    
    private func colorForEvent(_ type: PlayerEvent.EventType) -> Color {
        switch type {
        case .score: return .green
        case .assist: return .blue
        case .rebound: return .orange
        case .steal: return .purple
        case .block: return .red
        case .foul: return .yellow
        }
    }
    
    private func formatTimestamp(_ timestamp: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: timestamp) ?? ""
    }
}

struct StatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 36, weight: .bold))
        }
        .frame(width: 100, height: 100)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
}

struct ShootingStatRow: View {
    let title: String
    let made: Int
    let attempted: Int
    let percentage: Double
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("\(made)/\(attempted)")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(String(format: "%.1f%%", percentage))
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(width: 60, alignment: .trailing)
        }
    }
}

struct PlayerTrailView: View {
    let positions: [SIMD3<Float>]
    
    var body: some View {
        TimelineView(.animation) { _ in
            RealityView { content in
                // Create trail mesh
                guard positions.count >= 2 else { return }
                
                let material = UnlitMaterial(color: .white.withAlphaComponent(0.3))
                let mesh = MeshResource.generateTrail(
                    from: positions,
                    radius: 0.05,
                    smoothness: 0.8
                )
                
                let trailEntity = ModelEntity(
                    mesh: mesh,
                    materials: [material]
                )
                
                content.add(trailEntity)
            }
        }
    }
}

#Preview {
    PlayerStatsView(player: Player(
        id: "1",
        number: 23,
        name: "Michael Jordan",
        team: .home,
        position: .zero,
        rotation: simd_quatf(),
        stats: PlayerStats(
            points: 32,
            assists: 8,
            rebounds: 6,
            fieldGoalsMade: 12,
            fieldGoalsAttempted: 20,
            threePointersMade: 2,
            threePointersAttempted: 5,
            freeThrowsMade: 6,
            freeThrowsAttempted: 7
        )
    ))
} 
