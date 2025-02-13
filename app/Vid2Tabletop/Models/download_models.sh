#!/bin/bash

# Create models directory if it doesn't exist
mkdir -p models

# Download YOLOv8 models
echo "Downloading YOLOv8 models..."

# Player detection and pose estimation
wget https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8n-pose.pt -O models/yolov8n-pose.pt

# Ball detection
wget https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8n.pt -O models/yolov8n.pt

echo "Models downloaded successfully!" 