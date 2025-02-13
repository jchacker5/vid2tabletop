# Vid2Tabletop

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Vid2Tabletop is an open-source MVP app that converts NBA game videos into an interactive 3D tabletop format for Apple Vision Pro, inspired by the official NBA app's Tabletop feature. The system uses YOLO-based computer vision and RealityKit to create a diorama-scale virtual representation of any basketball game, supporting both live and recorded content.

## Features

- **Dual-View Experience:**
  - Floating 2D video stream with DRM support
  - Synchronized diorama-scale 3D representation
  - Seamless switching between views
  - Multi-game viewing support

- **Video Processing & Preprocessing:**
  - YOLO-based player and ball detection
  - Multi-object tracking with BoT-SORT/ByteTrack
  - Court calibration and coordinate mapping
  - Real-time YouTube video processing

- **Interactive Controls:**
  - Eye tracking for view selection
  - Hand gesture controls for camera movement
  - Voice commands for game control
  - Natural spatial interactions

- **3D Visualization:**
  - RealityKit-powered 3D court representation
  - Real-time position updates
  - Dynamic player movement trails
  - Interactive statistics overlay

- **Training Pipeline:**
  - Custom YOLO model training for basketball detection
  - Google Colab GPU support
  - Data augmentation for various court angles
  - Real-time inference optimization

## Tech Stack

- **Computer Vision:**
  - Ultralytics YOLO for object detection/tracking
  - OpenCV for video processing
  - NumPy for coordinate transformations
  - YouTube-DL for video ingestion

- **Vision Pro Integration:**
  - SwiftUI and RealityKit
  - Volumetric window support
  - Spatial anchoring
  - ARKit for gesture recognition

- **Backend:**
  - Python processing pipeline
  - JSON-based data bridge
  - Real-time coordinate mapping
  - WebSocket for live updates

## Implementation Details

### 1. YOLO Training Pipeline (Python)

```python
from ultralytics import YOLO

# Train custom model on basketball dataset
model = YOLO('yolo11n.pt')
model.train(
    data='basketball.yaml',
    epochs=100,
    imgsz=640,
    batch=16,
    device='0'  # GPU device
)

# Run inference with tracking
results = model.track(
    source="game.mp4",
    tracker="botsort.yaml",  # or bytetrack.yaml
    conf=0.3,
    iou=0.5,
    show=True
)
```

### 2. Vision Pro Integration (Swift)

```swift
struct TabletopView: View {
    @StateObject private var viewModel = TabletopViewModel()
    @State private var showStats = false
    @State private var selectedPlayer: Player?
    
    var body: some View {
        HStack {
            // 2D Video Stream
            VideoPlayerView(url: viewModel.videoURL)
                .frame(width: 1280, height: 720)
                .windowStyle(.volumetric)
            
            // 3D Tabletop View
            RealityView { content in
                // Create 3D court
                let courtEntity = try? await Entity(named: "BasketballCourt")
                courtEntity?.position = SIMD3(x: 0, y: 0, z: 0)
                content.add(courtEntity)
                
                // Add player entities with trails
                for player in viewModel.players {
                    let playerEntity = createPlayerEntity(for: player)
                    content.add(playerEntity)
                    
                    // Add movement trail
                    if let trail = createTrail(for: player) {
                        content.add(trail)
                    }
                }
            }
            .gesture(
                SpatialTapGesture()
                    .targetedToEntity(selectedPlayer)
                    .onEnded { _ in
                        showStats.toggle()
                    }
            )
        }
        .ornament(
            visibility: showStats ? .visible : .hidden,
            attachmentAnchor: .scene
        ) {
            PlayerStatsView(player: selectedPlayer)
        }
    }
}
```

### 3. Multi-Game Support

```swift
struct MultiGameView: View {
    @StateObject private var gamesViewModel = GamesViewModel()
    
    var body: some View {
        VStack {
            // Game selector
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(gamesViewModel.availableGames) { game in
                        GameThumbnail(game: game)
                            .onTapGesture {
                                gamesViewModel.selectGame(game)
                            }
                    }
                }
            }
            
            // Active games grid
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 400))]) {
                ForEach(gamesViewModel.activeGames) { game in
                    TabletopView(game: game)
                }
            }
        }
    }
}
```

### 4. Coordinate Mapping

```python
class CourtCalibrator:
    def __init__(self):
        self.court_length = 94.0  # NBA court length in feet
        self.court_width = 50.0   # NBA court width in feet
        self.calibration_matrix = np.eye(3)

    def pixel_to_court(self, x, y):
        # Convert pixel coordinates to court coordinates
        court_coords = np.dot(self.calibration_matrix, [x, y, 1])
        return court_coords[:2] / court_coords[2]
```

## Getting Started

### Prerequisites

- Python 3.8+ with PyTorch
- Xcode 15+ with Vision Pro SDK
- Google Colab account (for GPU training)
- YouTube API Key (optional, for video ingestion)

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/jchacker5/vid2tabletop.git
   cd vid2tabletop
   ```

2. Install Python dependencies:

   ```bash
   pip install -r requirements.txt
   ```

3. Train the model (using Google Colab):

   ```bash
   # Upload training.ipynb to Colab
   # Follow the notebook instructions for model training
   ```

4. Install iOS dependencies:

   ```bash
   cd App
   xcodegen
   pod install
   ```

5. Open the Xcode project:
   ```bash
   open Vid2Tabletop.xcworkspace
   ```

### Training the Model

1. Prepare your dataset:

   - Collect NBA game footage
   - Label players, ball, and court markers
   - Create YOLO format annotations

2. Configure training:

   ```yaml
   # basketball.yaml
   path: ../datasets/basketball
   train: train/images
   val: valid/images
   test: test/images

   nc: 3 # Number of classes
   names: ["player", "ball", "court_marker"]
   ```

3. Start training:

   ```python
   from ultralytics import YOLO

   # Load a model
   model = YOLO('yolo11n.pt')

   # Train the model
   model.train(
       data='basketball.yaml',
       epochs=100,
       imgsz=640,
       batch=16
   )
   ```

### Running the Pipeline

1. Process a video:

   ```bash
   python pipeline/process_video.py --input game.mp4 --output tracking_data.json
   ```

2. Run the Vision Pro app:
   - Open in Xcode
   - Select Vision Pro Simulator
   - Build and Run

## Project Structure

```
vid2tabletop/
├── App/                      # Vision Pro application
│   ├── Sources/             # Swift source files
│   └── Resources/           # 3D models and assets
├── pipeline/                # Python processing pipeline
│   ├── process_video.py     # Video processing script
│   └── train.py            # Model training script
├── models/                  # Trained YOLO models
└── data/                    # Training data and annotations
```

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Ultralytics YOLO](https://docs.ultralytics.com/modes/track/) for object tracking
- Apple's RealityKit team for spatial computing tools
- The open-source computer vision community

---

For more information, visit our [GitHub repository](https://github.com/jchacker5/vid2tabletop) or check out the [documentation](docs/README.md).

## Vision Pro Features

### Gesture Controls
- Pinch and zoom to adjust tabletop size
- Two-finger rotation for view angle
- Air tap for player selection
- Swipe for timeline control

### Voice Commands
- "Show stats" - Display player statistics
- "Switch camera" - Change viewing angle
- "Track player [number]" - Focus on specific player
- "Show replay" - Review recent plays

### Eye Tracking
- Look at players to highlight their stats
- Gaze-based menu selection
- Focus-aware interface scaling
- Natural view transitions

### Multi-Game Experience
- Watch up to 4 games simultaneously
- Synchronized audio control
- Individual game controls
- Cross-game statistics comparison
