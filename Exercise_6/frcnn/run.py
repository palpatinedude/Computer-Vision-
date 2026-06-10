import os
import sys

import torch
from torchvision.models.detection import (
    FasterRCNN_ResNet50_FPN_Weights,
    fasterrcnn_resnet50_fpn,
)

sys.path.append("..")

from core.loader import COCODetectionDataset
from core.evaluation import evaluate_model, evaluate_thresholds, compute_map
from core.plot import save_pr_curve


IMAGES_DIR = "../val2017"
ANNOTATION_PATH = "../annotations_trainval2017/annotations/instances_val2017.json"

RESULTS_DIR = "results"
FIGURES_DIR = "figures"

MAX_IMAGES = 100
IOU_THRESHOLD = 0.5
MAIN_SCORE_THRESHOLD = 0.5

PR_THRESHOLDS = [
    0.05, 0.10, 0.15, 0.20, 0.25,
    0.30, 0.35, 0.40, 0.45, 0.50,
    0.55, 0.60, 0.65, 0.70, 0.75,
    0.80, 0.85, 0.90, 0.95,
]


# saves main evaluation results
def save_main_results(metrics, map_results, dataset_size):
    path = os.path.join(RESULTS_DIR, "frcnn_results.txt")

    with open(path, "w") as f:
        f.write("Faster R-CNN Results\n")
        f.write("====================\n\n")
        f.write(f"Images: {dataset_size}\n")
        f.write(f"IoU threshold: {IOU_THRESHOLD}\n")
        f.write(f"Score threshold: {MAIN_SCORE_THRESHOLD}\n\n")

        f.write(f"TP: {metrics['tp']}\n")
        f.write(f"FP: {metrics['fp']}\n")
        f.write(f"FN: {metrics['fn']}\n\n")

        f.write(f"Precision: {metrics['precision']:.6f}\n")
        f.write(f"Recall: {metrics['recall']:.6f}\n")
        f.write(f"F1: {metrics['f1']:.6f}\n")
        f.write(f"mAP: {map_results['map']:.6f}\n")
        f.write(f"mAP50: {map_results['map_50']:.6f}\n")
        f.write(f"mAP75: {map_results['map_75']:.6f}\n")
        f.write(f"Average inference time: {metrics['avg_time']:.6f} sec/image\n")


# saves precision-recall values for different score thresholds
def save_pr_results(pr_results):
    path = os.path.join(RESULTS_DIR, "frcnn_pr_results.txt")

    with open(path, "w") as f:
        f.write("threshold,precision,recall,f1\n")

        for item in pr_results:
            f.write(
                f"{item['threshold']:.2f},"
                f"{item['precision']:.6f},"
                f"{item['recall']:.6f},"
                f"{item['f1']:.6f}\n"
            )


# saves COCO-style mAP results
def save_map_results(map_results):
    path = os.path.join(RESULTS_DIR, "frcnn_map_results.txt")

    with open(path, "w") as f:
        f.write("Faster R-CNN mAP Results\n")
        f.write("========================\n\n")
        f.write(f"mAP: {map_results['map']:.6f}\n")
        f.write(f"mAP50: {map_results['map_50']:.6f}\n")
        f.write(f"mAP75: {map_results['map_75']:.6f}\n")


# runs Faster R-CNN evaluation
def main():
    # creates output directories
    os.makedirs(RESULTS_DIR, exist_ok=True)
    os.makedirs(FIGURES_DIR, exist_ok=True)

    # selects CPU or GPU
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print("Device:", device)

    # loads COCO validation dataset
    dataset = COCODetectionDataset(
        images_dir=IMAGES_DIR,
        annotation_path=ANNOTATION_PATH,
        max_images=MAX_IMAGES,
    )

    print("Loaded images:", len(dataset))

    # loads pretrained Faster R-CNN model
    weights = FasterRCNN_ResNet50_FPN_Weights.DEFAULT
    model = fasterrcnn_resnet50_fpn(weights=weights)

    model.to(device)
    model.eval()

    print("\nMain Faster R-CNN evaluation")

    # computes precision, recall, F1, TP, FP, FN and inference time
    metrics = evaluate_model(
        model=model,
        dataset=dataset,
        device=device,
        score_threshold=MAIN_SCORE_THRESHOLD,
        iou_threshold=IOU_THRESHOLD,
        verbose=True,
    )

    print("\nComputing Precision-Recall curve")

    # evaluates different score thresholds for PR curve
    pr_results = evaluate_thresholds(
        model=model,
        dataset=dataset,
        device=device,
        thresholds=PR_THRESHOLDS,
        iou_threshold=IOU_THRESHOLD,
    )

    # saves PR results
    save_pr_results(pr_results)

    # saves PR curve
    save_pr_curve(
        pr_results=pr_results,
        title="Faster R-CNN Precision-Recall Curve",
        save_path=os.path.join(FIGURES_DIR, "frcnn_pr_curve.png"),
    )

    print("\nComputing COCO-style mAP")

    # computes COCO-style mAP metrics
    map_results = compute_map(
        model=model,
        dataset=dataset,
        device=device,
    )

    print("\nFaster R-CNN Results")
    print(f"TP: {metrics['tp']}")
    print(f"FP: {metrics['fp']}")
    print(f"FN: {metrics['fn']}")
    print(f"Precision: {metrics['precision']:.6f}")
    print(f"Recall: {metrics['recall']:.6f}")
    print(f"F1: {metrics['f1']:.6f}")
    print(f"mAP: {map_results['map']:.6f}")
    print(f"mAP50: {map_results['map_50']:.6f}")
    print(f"mAP75: {map_results['map_75']:.6f}")
    print(f"Average inference time: {metrics['avg_time']:.6f} sec/image")

    # saves final result files
    save_main_results(metrics, map_results, len(dataset))
    save_map_results(map_results)

    print("\nSaved:")
    print(os.path.join(RESULTS_DIR, "frcnn_results.txt"))
    print(os.path.join(RESULTS_DIR, "frcnn_pr_results.txt"))
    print(os.path.join(RESULTS_DIR, "frcnn_map_results.txt"))
    print(os.path.join(FIGURES_DIR, "frcnn_pr_curve.png"))


if __name__ == "__main__":
    main()