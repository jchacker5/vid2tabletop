import SwiftUI
import RealityKit
import RealityKitContent

@main
struct Vid2TabletopApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 25, height: 25, depth: 25, unit: .centimeters)

        ImmersiveSpace(id: "TabletopSpace") {
            TabletopExperience()
        }
    }
}

struct ContentView: View {
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    var body: some View {
        VStack {
            Text("Vid2Tabletop")
                .font(.largeTitle)
            
            Toggle("Show Tabletop", isOn: $showImmersiveSpace)
                .toggleStyle(.button)
                .padding()
        }
        .onChange(of: showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: "TabletopSpace") {
                    case .success:
                        immersiveSpaceIsShown = true
                    case .failure:
                        showImmersiveSpace = false
                    }
                } else {
                    await dismissImmersiveSpace()
                    immersiveSpaceIsShown = false
                }
            }
        }
    }
} 