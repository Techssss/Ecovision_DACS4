# AI Models

This directory contains trained AI models for the EcoVision application.

## YOLOv8 Model

- **File**: `yolov8_best.pt`
- **Purpose**: Object detection for pollution reports
- **Classes**: Air pollution, water pollution, trash, industrial pollution, etc.
- **Training**: Trained on custom dataset with 6 pollution categories

## Usage

The YOLOv8 model is automatically loaded when the reports module is initialized. Place your trained model file here.

## Model Training

To train a new model:

1. Prepare dataset in YOLO format
2. Train using Ultralytics:
```bash
yolo train data=dataset/data.yaml model=yolov8n.pt epochs=100
```

3. Copy best model to this directory:
```bash
cp runs/detect/train/weights/best.pt models/yolov8_best.pt
```

