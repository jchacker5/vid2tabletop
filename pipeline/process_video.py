from pathlib import Path
import json
import numpy as np
from ultralytics import YOLO
import cv2

class VideoProcessor:
    def __init__(self, model_path="yolo11n.pt"):
        """Initialize the video processor with a YOLO model."""
        self.model = YOLO(model_path)
        self.court_calibrator = CourtCalibrator()
        
    def process_video(self, video_path, output_path):
        """Process a video file and output tracking data."""
        # Initialize video capture
        cap = cv2.VideoCapture(video_path)
        fps = cap.get(cv2.CAP_PROP_FPS)
        
        tracking_data = []
        frame_count = 0
        
        while cap.isOpened():
            success, frame = cap.read()
            if not success:
                break
                
            # Run YOLO tracking on the frame
            results = self.model.track(frame, persist=True)
            
            if results and len(results) > 0:
                # Get tracking results
                boxes = results[0].boxes.xywh.cpu().numpy()
                track_ids = results[0].boxes.id.cpu().numpy()
                classes = results[0].boxes.cls.cpu().numpy()
                
                # Process tracking results
                frame_data = self._process_frame_data(
                    boxes, track_ids, classes, 
                    frame_count, fps
                )
                tracking_data.append(frame_data)
            
            frame_count += 1
        
        cap.release()
        
        # Save tracking data
        self._save_tracking_data(tracking_data, output_path)
        
    def _process_frame_data(self, boxes, track_ids, classes, frame_count, fps):
        """Process frame data and convert to court coordinates."""
        players = []
        ball_position = None
        
        for box, track_id, cls in zip(boxes, track_ids, classes):
            x, y, w, h = box
            
            # Convert pixel coordinates to court coordinates
            court_position = self.court_calibrator.pixel_to_court(x, y)
            
            if cls == 0:  # Player class
                # Determine team based on position or appearance
                team = self._determine_team(x, y, frame_count)
                
                players.append({
                    "id": str(int(track_id)),
                    "position": court_position.tolist(),
                    "team": team
                })
            elif cls == 1:  # Ball class
                ball_position = court_position.tolist()
        
        return {
            "timestamp": frame_count / fps,
            "players": players,
            "ball_position": ball_position
        }
    
    def _determine_team(self, x, y, frame_count):
        """Determine which team a player belongs to."""
        # This is a simplified version - you would need more sophisticated
        # team assignment based on jersey color or position
        return "home" if x < 960 else "away"
    
    def _save_tracking_data(self, tracking_data, output_path):
        """Save tracking data to a JSON file."""
        output_path = Path(output_path)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(output_path, 'w') as f:
            json.dump({
                "version": "1.0",
                "frames": tracking_data
            }, f, indent=2)


class CourtCalibrator:
    def __init__(self):
        """Initialize court calibration parameters."""
        # Standard NBA court dimensions in feet
        self.court_length = 94.0
        self.court_width = 50.0
        
        # Initialize calibration matrix
        self.calibration_matrix = np.eye(3)
        
    def calibrate_from_frame(self, frame):
        """Calibrate using court markings in a frame."""
        # This would detect court markings and compute the homography matrix
        # For now, we'll use a simple scaling transformation
        frame_height, frame_width = frame.shape[:2]
        
        # Scale factors to convert from pixels to feet
        self.scale_x = self.court_length / frame_width
        self.scale_y = self.court_width / frame_height
        
    def pixel_to_court(self, x, y):
        """Convert pixel coordinates to court coordinates."""
        # This is a simplified conversion - you would use the actual
        # homography matrix in a real implementation
        court_x = x * self.scale_x
        court_y = y * self.scale_y
        
        return np.array([court_x, court_y])


def main():
    # Initialize the processor
    processor = VideoProcessor()
    
    # Process a video file
    video_path = "path/to/your/video.mp4"
    output_path = "tracking_data.json"
    
    processor.process_video(video_path, output_path)


if __name__ == "__main__":
    main() 