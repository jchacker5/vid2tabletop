# Vid2Tabletop Implementation Plan

## Introduction

Vid2Tabletop is a Vision Pro app that transforms YouTube NBA game videos into interactive 3D tabletop visualizations. While the MVP is functional, there are several missing parts and enhancements that will greatly improve the user experience and overall robustness of the application.

This document outlines a well-researched plan to implement the missing features and improvements.

## Missing/Planned Features Summary

- **YouTube Video Frame Extraction:**
  - Implement robust frame extraction using AVFoundation.
- **CoreML Based Ball Detection:**
  - Integrate a CoreML model for accurate basketball detection.
- **Enhanced Vision Processing:**
  - Improve player detection, introduce team differentiation, and handle occlusions.
- **Game Clock Synchronization and Metadata Extraction:**
  - Extract in-game timing and metadata using OCR/advanced image processing.
- **Export Functionality:**
  - Enable exporting processed data in CSV/JSON formats for further analysis.
- **UI/UX Enhancements:**
  - Improve loading states, gesture controls, settings customization, and error handling.

## Detailed Implementation Plan

### 1. YouTube Video Frame Extraction

**Objective:** Extract video frames robustly from YouTube videos to feed into the vision pipeline.

**Plan:**

- **Research AVFoundation:**
  - Use AVAsset and AVAssetReader to load the video stream from a cached URL.
  - Identify interval extraction (e.g., 30 fps or adaptive frame sampling based on video length).
- **Implementation Steps:**
  1. Download or stream the video via a secure method.
  2. Initialize an `AVAsset` with the video URL.
  3. Use `AVAssetReader` to extract CMSampleBuffers and convert them to CGImages.
  4. Implement caching to handle memory efficiently for longer videos.
- **Challenges:**
  - Handling large videos without memory bloat.
  - Ensuring consistent frame extraction rate across different video qualities.

### 2. CoreML Based Ball Detection

**Objective:** Achieve accurate basketball detection using a trained machine learning model.

**Plan:**

- **Model Selection and Training:**
  - Research available object detection models (e.g., YOLO, MobileNet) that can be adapted for detecting basketballs.
  - Use Create ML or convert a PyTorch/TensorFlow model to CoreML format.
- **Integration Steps:**
  1. Integrate the CoreML model into the Xcode project.
  2. Set up a `VNCoreMLRequest` and process video frames to detect the ball.
  3. Apply median filtering to smooth out detection noise.
- **Risks:**
  - Limited training data for basketballs in varying lighting and movements.
  - Performance overhead on real time processing.

### 3. Enhanced Vision Processing for Player Detection

**Objective:** Improve accuracy and reliability of player detection and introduce team differentiation.

**Plan:**

- **Techniques:**
  - Tune parameters for `VNDetectHumanBodyPoseRequest` to improve detection accuracy.
  - Research advanced techniques such as using additional CoreML models to identify jersey colors or numbers for team differentiation.
- **Implementation Steps:**
  1. Experiment with different Vision API configurations.
  2. Develop filtering algorithms to separate players by team using color clustering or histogram analysis.
  3. Incorporate temporal smoothing to reduce flickering detection between frames.

### 4. Game Clock Synchronization and Metadata Extraction

**Objective:** Synchronize game time and extract in-game metadata (e.g., scores, player stats) from video frames.

**Plan:**

- **Using OCR:**
  - Integrate Vision's text recognition or Tesseract OCR to extract overlay information like game clock.
- **Implementation Steps:**
  1. Identify regions of the video frame that contain the game clock and statistics.
  2. Apply OCR to extract text information.
  3. Synchronize extracted times with video frames to enable playback synchronization.
- **Challenges:**
  - Variability in in-game overlay designs.
  - Ensuring OCR accuracy in varying video qualities.

### 5. Export Functionality

**Objective:** Allow users to export extracted game data for further analysis or record-keeping.

**Plan:**

- **Data Formats:**
  - Support CSV and JSON formats for exporting player positions, ball trajectories, and game metadata.
- **Implementation Steps:**
  1. Design a data model to structure the extracted information.
  2. Implement export methods to generate CSV/JSON files from the processed data.
  3. Integrate a share sheet within the app for user export.

### 6. UI/UX Enhancements

**Objective:** Improve user experience and reliability with additional settings and feedback mechanisms.

**Plan:**

- **Features:**
  - Detailed progress indicators and error messages.
  - Enhanced settings view for adjusting visualization parameters (colors, scale, etc.).
  - Gesture controls for more intuitive 3D court interaction.
- **Implementation Steps:**
  1. Refine the settings panel with additional options.
  2. Implement gesture recognition improvements (e.g., rotation, drag, and pinch to zoom).
  3. Test usability with real users and collect feedback for further refinement.

## Timeline and Milestones

- **Phase 1 (1-2 weeks):**
  - Implement robust YouTube video frame extraction.
  - Integrate and test video frame extraction using AVFoundation.
- **Phase 2 (2-3 weeks):**
  - Develop and integrate CoreML model for ball detection.
  - Enhance Vision processing for player detection.
- **Phase 3 (1-2 weeks):**
  - Implement game clock synchronization and metadata extraction (OCR integration).
  - Develop export functionality for processed data.
- **Phase 4 (Ongoing):**
  - UI/UX improvements based on user feedback.
  - Performance optimizations and bug fixes.

## Risks and Mitigations

- **Performance Bottlenecks:**
  - Use batch processing, caching, and asynchronous processing to mitigate delays.
- **Detection Accuracy:**
  - Continuous tuning of vision parameters and model retraining as needed.
- **Resource Constraints:**
  - Optimize memory usage and processing pipelines for mobile hardware.

## Conclusion

This implementation plan lays out the roadmap for enhancing Vid2Tabletop into a robust, production-quality MVP. By addressing the current gaps in video processing, detection accuracy, and user experience, the next phases of development will greatly improve the value proposition and functionality of the app.
