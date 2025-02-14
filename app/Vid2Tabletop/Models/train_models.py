from ultralytics import YOLO
import torch
import os
import yaml

def train_basketball_models():
    """Train YOLO models for basketball detection and player tracking."""
    
    # Configuration
    config = {
        'epochs': 100,
        'batch_size': 16,
        'img_size': 640,
        'data': {
            'path': 'datasets/basketball',
            'train': 'train/images',
            'val': 'val/images',
            'test': 'test/images',
            'nc': 3,  # number of classes
            'names': ['player', 'ball', 'court']
        }
    }
    
    # Save configuration
    with open('basketball.yaml', 'w') as f:
        yaml.dump(config, f)
    
    # Initialize models
    player_model = YOLO('yolov8n-pose.pt')
    ball_model = YOLO('yolov8n.pt')
    
    # Train player detection and pose estimation
    print("Training player detection model...")
    player_model.train(
        data='basketball.yaml',
        epochs=config['epochs'],
        batch=config['batch_size'],
        imgsz=config['img_size'],
        patience=20,
        device=0 if torch.cuda.is_available() else 'cpu'
    )
    
    # Train ball detection
    print("Training ball detection model...")
    ball_model.train(
        data='basketball.yaml',
        epochs=config['epochs'],
        batch=config['batch_size'],
        imgsz=config['img_size'],
        patience=20,
        device=0 if torch.cuda.is_available() else 'cpu'
    )
    
    # Evaluate models
    print("Evaluating models...")
    player_metrics = player_model.val()
    ball_metrics = ball_model.val()
    
    print("\nPlayer Detection Metrics:")
    print(f"mAP@0.5: {player_metrics.box.map50:.3f}")
    print(f"mAP@0.5:0.95: {player_metrics.box.map:.3f}")
    
    print("\nBall Detection Metrics:")
    print(f"mAP@0.5: {ball_metrics.box.map50:.3f}")
    print(f"mAP@0.5:0.95: {ball_metrics.box.map:.3f}")
    
    # Export models
    print("\nExporting models...")
    player_model.export(format='coreml', imgsz=config['img_size'])
    ball_model.export(format='coreml', imgsz=config['img_size'])
    
    return {
        'player_model': player_metrics,
        'ball_model': ball_metrics
    }

if __name__ == '__main__':
    # Create models directory if it doesn't exist
    os.makedirs('models', exist_ok=True)
    
    # Train and evaluate models
    metrics = train_basketball_models()
    
    # Save metrics
    with open('models/training_metrics.yaml', 'w') as f:
        yaml.dump(metrics, f) 