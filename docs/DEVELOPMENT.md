# Development Guide

## Environment Setup

### Prerequisites

- Xcode 15.0 or later
- visionOS SDK
- Python 3.8+ with pip
- Git

### Initial Setup

1. Clone the repository:

```bash
git clone https://github.com/yourusername/vid2tabletop.git
cd vid2tabletop
```

2. Install Python dependencies:

```bash
cd app/Vid2Tabletop/Models
chmod +x download_models.sh
./download_models.sh
```

3. Open the project in Xcode:

```bash
open Vid2Tabletop.xcodeproj
```

## Project Structure

```
Vid2Tabletop/
├── Sources/
│   ├── Services/           # Core services
│   ├── Views/             # SwiftUI views
│   ├── Models/            # Data models
│   └── Utils/             # Utility functions
├── Resources/
│   ├── Assets.xcassets/   # Image assets
│   └── Models/            # YOLO models
├── Tests/                 # Unit and UI tests
└── docs/                 # Documentation
```

## Development Workflow

### 1. Building and Running

- Select the visionOS Simulator as your target device
- Build (⌘B) and Run (⌘R) the project
- Use the Vision Pro simulator controls for testing

### 2. Testing

Run the test suite:

```bash
xcodebuild test -scheme Vid2Tabletop -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

### 3. Code Style

Follow these guidelines:

- Use SwiftLint for code style enforcement
- Follow Apple's [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use meaningful variable and function names
- Document public APIs using Swift-style documentation comments

### 4. Vision Pro Best Practices

#### Window Management

- Use `WindowGroup` for main content
- Support multiple window configurations
- Implement proper window sharing

#### Gestures

- Support standard Vision Pro gestures
- Use `SpatialTapGesture` for interactions
- Implement proper depth handling

#### Performance

- Use async/await for concurrent operations
- Implement proper memory management
- Profile regularly using Instruments

### 5. ML Model Development

#### Training YOLO Models

1. Prepare dataset:

   - Collect basketball game footage
   - Label players and ball positions
   - Split into train/val sets

2. Train models:

```bash
python train_models.py --data config/data.yaml --epochs 100
```

3. Export to CoreML:

```bash
python export.py --format coreml
```

#### Model Evaluation

- Use validation dataset
- Check inference speed
- Verify accuracy metrics

### 6. Debugging

#### Common Issues

1. Video Processing

   - Check video format compatibility
   - Verify YouTube URL validity
   - Monitor memory usage

2. ML Processing

   - Verify model paths
   - Check input image formatting
   - Monitor inference time

3. 3D Visualization
   - Verify court model loading
   - Check coordinate transformations
   - Monitor frame rate

#### Tools

- Use Console.app for logging
- Enable Metal Frame Capture
- Use Instruments for profiling

### 7. Release Process

1. Version Update

   - Update version in project settings
   - Update changelog
   - Tag release in git

2. Testing

   - Run full test suite
   - Perform manual testing
   - Check performance metrics

3. Documentation

   - Update API documentation
   - Update user guide
   - Review release notes

4. Submission
   - Archive build
   - Run App Store validation
   - Submit for review

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

### Pull Request Guidelines

- Include test coverage
- Update documentation
- Follow code style guidelines
- Add meaningful commit messages

## Resources

- [Apple Vision Pro Development](https://developer.apple.com/visionos/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)
- [YOLO Documentation](https://docs.ultralytics.com/)
