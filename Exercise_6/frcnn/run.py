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
from core.results import (
    save_main_results,
    save_pr_results,
    save_map_results,
)


MODEL_NAME = "Faster R-CNN"
FILE_PREFIX = "frcnn"

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


# runs Faster R-CNN evaluation pipeline
def main():
    # creates output directories
    os.makedirs(
        RESULTS_DIR,
        exist_ok=True
    )

    os.makedirs(
        FIGURES_DIR,
        exist_ok=True
    )

    # selects CPU or GPU
    device = torch.device(
        "cuda"
        if torch.cuda.is_available()
        else "cpu"
    )

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

    model = fasterrcnn_resnet50_fpn(
        weights=weights
    )

    model.to(device)
    model.eval()

    print("\nMain Faster R-CNN evaluation")

    # computes TP, FP, FN, precision, recall and F1
    metrics = evaluate_model(
        model=model,
        dataset=dataset,
        device=device,
        score_threshold=MAIN_SCORE_THRESHOLD,
        iou_threshold=IOU_THRESHOLD,
        verbose=True,
    )

    print("\nComputing Precision-Recall curve")

    # evaluates multiple score thresholds
    pr_results = evaluate_thresholds(
        model=model,
        dataset=dataset,
        device=device,
        thresholds=PR_THRESHOLDS,
        iou_threshold=IOU_THRESHOLD,
    )

    # saves precision-recall results
    pr_path = save_pr_results(
        results_dir=RESULTS_DIR,
        file_prefix=FILE_PREFIX,
        pr_results=pr_results,
    )

    # creates precision-recall curve path
    pr_curve_path = os.path.join(
        FIGURES_DIR,
        f"{FILE_PREFIX}_pr_curve.png",
    )

    # saves precision-recall curve
    save_pr_curve(
        pr_results=pr_results,
        title="Faster R-CNN Precision-Recall Curve",
        save_path=pr_curve_path,
    )

    print("\nComputing COCO-style mAP")

    # computes COCO-style mAP metrics
    map_results = compute_map(
        model=model,
        dataset=dataset,
        device=device,
    )

    # saves main evaluation results
    main_path = save_main_results(
        results_dir=RESULTS_DIR,
        model_name=MODEL_NAME,
        file_prefix=FILE_PREFIX,
        metrics=metrics,
        map_results=map_results,
        dataset_size=len(dataset),
        iou_threshold=IOU_THRESHOLD,
        score_threshold=MAIN_SCORE_THRESHOLD,
    )

    # saves mAP results
    map_path = save_map_results(
        results_dir=RESULTS_DIR,
        model_name=MODEL_NAME,
        file_prefix=FILE_PREFIX,
        map_results=map_results,
    )

    # prints final metrics
    print(f"\n{MODEL_NAME} Results")
    print(f"TP: {metrics['tp']}")
    print(f"FP: {metrics['fp']}")
    print(f"FN: {metrics['fn']}")
    print(f"Precision: {metrics['precision']:.6f}")
    print(f"Recall: {metrics['recall']:.6f}")
    print(f"F1: {metrics['f1']:.6f}")
    print(f"mAP: {map_results['map']:.6f}")
    print(f"mAP50: {map_results['map_50']:.6f}")
    print(f"mAP75: {map_results['map_75']:.6f}")

    print(
        f"Average inference time: "
        f"{metrics['avg_time']:.6f} sec/image"
    )

    # prints saved files
    print("\nSaved:")
    print(main_path)
    print(pr_path)
    print(map_path)
    print(pr_curve_path)


if __name__ == "__main__":
    main()