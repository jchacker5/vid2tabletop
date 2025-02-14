# Vid2Tabletop

A Vision Pro app that transforms NBA game videos into interactive 3D tabletop experiences. Watch basketball games come to life in your space with real-time player tracking and immersive visualization.

## Features

### Video Processing ✅

- Real-time YouTube video integration with synchronized playback
- YOLO-based player detection and tracking using YOLOv8-pose
- Ball tracking with high accuracy using YOLOv8
- Progress reporting and error handling
- Frame-by-frame processing with AVFoundation

### 3D Visualization ✅

- Interactive basketball court model with RealityKit
- Real-time player position visualization
- Ball trajectory tracking
- Team differentiation using color clustering
- Gesture controls for court manipulation
- Multiple view layouts (side-by-side, stacked, tabletop only)

### Game Analysis ✅

- Basic game clock synchronization
- Score tracking
- Quarter tracking
- Player position heatmaps

### Vision Pro Integration ✅

- Native visionOS window management
- Hand gesture support
- Environment understanding
- Multiple window layouts
- Floating game metadata
- Proper permissions handling

## Requirements

- Xcode 15.2 or later
- visionOS 1.0 or later
- Python 3.8 or later (for YOLO model training)
- Vision Pro device or simulator

## Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/vid2tabletop.git
cd vid2tabletop
```

2. Install Python dependencies:

```bash
pip install ultralytics torch pyyaml
```

3. Download and train YOLO models:

```bash
cd app/Vid2Tabletop/Models
chmod +x download_models.sh
./download_models.sh
python train_models.py
```

4. Open the project in Xcode:

```bash
cd ../..
open Vid2Tabletop.xcodeproj
```

## Usage

1. Launch the app on Vision Pro
2. Input a YouTube URL of an NBA game
3. Use hand gestures to control the view:
   - Pinch and drag to move the court
   - Pinch to zoom
   - Two-finger rotation
4. Toggle between view layouts using the toolbar
5. Use the settings panel to customize visualization

## Architecture

### Core Services

- `VideoProcessingService`: Handles video processing and synchronization
- `YOLOProcessingService`: Manages ML-based detection and tracking
- `CourtVisualizer`: Manages 3D visualization and updates

### Views

- `MainView`: Primary app interface with window management
- `TabletopView`: 3D court visualization
- `VideoPlayerView`: 2D video playback
- `GameMetadataView`: Game statistics and information

### ML Models

- Player detection: YOLOv8-pose for pose estimation
- Ball tracking: YOLOv8 for object detection
- Custom trained models for basketball-specific detection

## Development Status

### Completed Features ✅

- Core video processing pipeline
- YOLO integration and model training
- 3D visualization with RealityKit
- Window management and layouts
- Basic game analysis
- Hand gesture controls

### In Progress 🚧

- Advanced player statistics
- Team identification
- Multi-game analysis
- Export functionality
- Performance optimizations

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Documentation

- [Implementation Plan](IMPLEMENTATION_PLAN.md): Detailed technical documentation
- [API Reference](docs/API.md): Service and component documentation
- [Model Training](docs/TRAINING.md): ML model training guide

## License

MIT License - see [LICENSE](LICENSE) file

## Acknowledgments

- [Ultralytics YOLO](https://github.com/ultralytics/ultralytics) for object detection
- [RealityKit](https://developer.apple.com/documentation/realitykit/) for 3D visualization
- [Vision](https://developer.apple.com/documentation/vision) for image processing
