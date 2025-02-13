# Vid2Tabletop

Vid2Tabletop is a Vision Pro app that allows users to input a YouTube URL of an NBA game. It processes the video to extract game data and converts it into a 3D tabletop representation using RealityKit.

## Current Project Status

### Completed Features ✅

- **Core UI and MVP Features** implemented with SwiftUI and RealityKit
- **YOLO Integration** for robust player and ball tracking
- **Real-time Processing Pipeline** with progress reporting
- **3D Court Visualization** with interactive controls
- **Player Detection and Tracking** using YOLOv8-pose
- **Ball Detection and Tracking** using YOLOv8
- **Team Differentiation** using color clustering
- **Basic Game Clock Extraction** using Vision OCR

### In Progress 🚧

- Advanced metadata extraction (player stats, detailed game events)
- Enhanced UI/UX features (advanced gesture controls, voice commands)
- Export functionality for processed data (CSV/JSON)
- Performance optimizations for longer videos

## Features

### Video Processing

- ✅ YouTube video integration
- ✅ YOLO-based player detection and tracking
- ✅ Ball tracking with high accuracy
- ✅ Real-time processing with progress feedback

### 3D Visualization

- ✅ Interactive basketball court model
- ✅ Player position visualization
- ✅ Ball trajectory tracking
- ✅ Team differentiation
- 🚧 Advanced camera controls

### Data Analysis

- ✅ Basic game clock synchronization
- 🚧 Player statistics extraction
- 🚧 Team score tracking
- 🚧 Data export functionality

## Dependencies

- [YouTube iOS Player Helper](https://github.com/youtube/youtube-ios-player-helper.git)
- [Swift Algorithms](https://github.com/apple/swift-algorithms)
- [Swift Collections](https://github.com/apple/swift-collections)
- [PythonKit](https://github.com/pvieito/PythonKit.git)
- [Ultralytics YOLO](https://github.com/ultralytics/ultralytics)

## How to Run

1. Install Python dependencies:

```bash
pip install ultralytics torch
```

2. Open the project in Xcode
3. Build and run on a visionOS compatible device or simulator
4. Input a valid YouTube NBA game URL and click "Convert to Tabletop"

## Implementation Details

For a detailed implementation plan and technical documentation, see [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md).

## License

MIT License (see LICENSE file).
