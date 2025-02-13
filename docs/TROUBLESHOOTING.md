# Troubleshooting Guide

## Common Issues and Solutions

### Video Processing Issues

#### YouTube Video Won't Load

**Symptoms:**

- Blank video player
- Error message about invalid URL
- Infinite loading spinner

**Solutions:**

1. Check URL format:

   ```swift
   // Correct format
   let url = "https://www.youtube.com/watch?v=VIDEO_ID"
   ```

2. Verify network connection:

   - Check device has internet access
   - Try loading video in Safari

3. Check video availability:
   - Ensure video is public
   - Try different video source

#### Poor Performance During Processing

**Symptoms:**

- App becomes unresponsive
- High CPU/GPU usage
- Frame drops

**Solutions:**

1. Reduce processing load:

   ```swift
   // Adjust frame processing interval
   let processingInterval = 0.5 // Process every 0.5 seconds
   ```

2. Monitor resource usage:
   - Use Instruments to profile
   - Check memory allocation
   - Verify background tasks

### ML Model Issues

#### Model Loading Fails

**Symptoms:**

- Error loading YOLO model
- Missing model files
- Incorrect model format

**Solutions:**

1. Verify model files:

   ```bash
   # Check model files exist
   ls app/Vid2Tabletop/Models/*.mlmodel
   ```

2. Run download script:

   ```bash
   ./download_models.sh
   ```

3. Check model compatibility:
   - Verify CoreML version
   - Check iOS version requirements

#### Poor Detection Accuracy

**Symptoms:**

- Missed player detections
- Incorrect ball tracking
- False positives

**Solutions:**

1. Adjust confidence threshold:

   ```swift
   // Increase confidence threshold
   let confidenceThreshold: Float = 0.6
   ```

2. Check input preprocessing:
   - Verify image size
   - Check color format
   - Validate normalization

### 3D Visualization Issues

#### Court Model Not Appearing

**Symptoms:**

- Blank 3D view
- Missing court model
- Loading errors

**Solutions:**

1. Check asset loading:

   ```swift
   // Verify court model path
   let courtURL = Bundle.main.url(forResource: "basketball_court", withExtension: "usdz")
   ```

2. Verify scene setup:
   - Check anchor position
   - Verify lighting setup
   - Validate camera position

#### Player Position Mapping Issues

**Symptoms:**

- Players in wrong positions
- Incorrect scaling
- Coordinate mismatches

**Solutions:**

1. Check coordinate transformation:

   ```swift
   // Verify coordinate mapping
   func convert2DTo3D(point: CGPoint) -> SIMD3<Float> {
       // Add logging
       print("2D point: \(point)")
       let result = // transformation logic
       print("3D point: \(result)")
       return result
   }
   ```

2. Validate court dimensions:
   - Check scale factors
   - Verify court measurements
   - Test with known positions

### Window Management Issues

#### Window Layout Problems

**Symptoms:**

- Windows not resizing properly
- Incorrect window positions
- Layout constraints issues

**Solutions:**

1. Check window configuration:

   ```swift
   // Verify window group setup
   WindowGroup {
       MainView()
           .windowStyle(.volumetric)
           .windowResizability(.contentSize)
   }
   ```

2. Debug layout constraints:
   - Print view hierarchy
   - Check auto-layout constraints
   - Verify window bounds

### Performance Optimization

#### Memory Leaks

**Symptoms:**

- Increasing memory usage
- App slowdown over time
- Crashes with memory warnings

**Solutions:**

1. Check resource cleanup:

   ```swift
   // Implement proper cleanup
   func cleanup() {
       videoPlayer?.pause()
       videoPlayer = nil
       // Release other resources
   }
   ```

2. Monitor allocations:
   - Use Memory Graph Debugger
   - Check for retain cycles
   - Profile with Instruments

#### Frame Rate Issues

**Symptoms:**

- Stuttering animations
- Slow UI response
- High GPU usage

**Solutions:**

1. Optimize rendering:

   ```swift
   // Reduce update frequency
   func updateVisualization() {
       guard shouldUpdate else { return }
       // Implement throttling
   }
   ```

2. Profile performance:
   - Use Metal System Trace
   - Check draw calls
   - Monitor CPU/GPU usage

## Debugging Tools

### Console Logging

Enable detailed logging:

```swift
// Add to your AppDelegate or early in app lifecycle
func enableDetailedLogging() {
    UserDefaults.standard.set(true, forKey: "DEBUG_LOGGING")
}
```

### Instruments Profiling

1. Time Profiler:

   - Launch Instruments
   - Select Time Profiler
   - Record during problematic operation

2. Memory Allocations:
   - Track object allocations
   - Find memory leaks
   - Monitor heap growth

### Metal Debugging

Enable Metal validation:

```swift
// Add to scheme arguments
-MTLDebugLayer 1
-MTLValidationBehavior 1
```

## Getting Help

1. Check documentation:

   - Review API documentation
   - Check DEVELOPMENT.md
   - Search known issues

2. File an issue:

   - Provide reproduction steps
   - Include error messages
   - Attach relevant logs

3. Contact support:
   - Email: support@vid2tabletop.com
   - GitHub Issues
   - Developer Forums
