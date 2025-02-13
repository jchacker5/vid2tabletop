# Vid2Tabletop

Transform basketball game videos into immersive 3D tabletop experiences on Apple Vision Pro.

## Overview

Vid2Tabletop is an innovative visionOS application that converts basketball game footage into interactive 3D visualizations. Watch your favorite basketball games come to life as a tabletop experience, with real-time player tracking and immersive statistics.

## Features

- 🏀 3D Basketball Court Visualization
- 👥 Real-time Player Tracking
- 🎮 Gesture-based Controls
- 🗣️ Voice Command Support
- 📊 Interactive Statistics
- 🎥 Video Integration
- 👁️ Eye Tracking Support
- 🤝 Multi-user Experience (coming soon)

## Requirements

- Xcode 15.2 or later
- visionOS 1.0 or later
- Apple Vision Pro device or simulator
- Swift 5.9 or later

## Installation

1. Clone the repository:

```bash
git clone https://github.com/jchacker5/vid2tabletop.git
```

2. Open the project in Xcode:

```bash
cd vid2tabletop/app
open Vid2Tabletop.xcodeproj
```

3. Select the Vision Pro simulator or device
4. Build and run the project (⌘R)

## Project Structure

```
vid2tabletop/
├── app/                    # Vision Pro Application
│   ├── Vid2Tabletop/      # Main App Source
│   ├── Packages/          # Swift Packages
│   └── Resources/         # Assets and Resources
└── pipeline/              # Python YOLO Processing
```

## Usage

1. Launch the app on your Vision Pro
2. Upload a basketball game video or connect to a live stream
3. Use hand gestures to control the view:
   - Pinch to select and interact
   - Rotate for camera control
   - Spread for zoom
4. Use voice commands for quick actions:
   - "Show stats" - Display player statistics
   - "Switch camera" - Change viewing angle
   - "Track player" - Focus on specific player

## Development

See [PROJECT_STATUS.md](PROJECT_STATUS.md) for current development status and roadmap.

### Building from Source

1. Install dependencies:

```bash
# Install XcodeGen if not already installed
brew install xcodegen

# Generate Xcode project
xcodegen generate
```

2. Open the project:

```bash
open Vid2Tabletop.xcodeproj
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- YOLO for computer vision processing
- RealityKit for 3D rendering
- The basketball analytics community

## Contact

Project Link: [https://github.com/jchacker5/vid2tabletop](https://github.com/jchacker5/vid2tabletop)
