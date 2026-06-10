import time
import torch
from core.metrics import evaluate_image, precision_recall_f1
from torchmetrics.detection.mean_ap import MeanAveragePrecision


# evaluates model on the dataset
def evaluate_model(
    model,
    dataset,
    device,
    score_threshold=0.5,
    iou_threshold=0.5,
    verbose=True,
):
    total_tp = 0
    total_fp = 0
    total_fn = 0
    total_time = 0.0

    model.eval()

    with torch.no_grad():
        for idx in range(len(dataset)):
            image, target, file_name = dataset[idx]
            image = image.to(device)

            # measures inference time
            start = time.time()
            prediction = model([image])[0]

            # synchronizes CUDA before timing
            if device.type == "cuda":
                torch.cuda.synchronize()

            end = time.time()

            total_time += end - start

            # evaluates one image
            tp, fp, fn = evaluate_image(
                prediction=prediction,
                target=target,
                score_threshold=score_threshold,
                iou_threshold=iou_threshold,
            )

            total_tp += tp
            total_fp += fp
            total_fn += fn

            if verbose:
                print(
                    f"[{idx + 1}/{len(dataset)}] {file_name} "
                    f"TP={tp} FP={fp} FN={fn}"
                )

    # computes final precision, recall and F1 score
    precision, recall, f1 = precision_recall_f1(
        total_tp,
        total_fp,
        total_fn,
    )

    # computes average inference time
    avg_time = total_time / len(dataset)

    return {
        "tp": total_tp,
        "fp": total_fp,
        "fn": total_fn,
        "precision": precision,
        "recall": recall,
        "f1": f1,
        "avg_time": avg_time,
    }


# evaluates multiple score thresholds
def evaluate_thresholds(
    model,
    dataset,
    device,
    thresholds,
    iou_threshold=0.5,
):
    results = []

    for threshold in thresholds:
        print(f"\nEvaluating score threshold = {threshold:.2f}")

        # evaluates model for current threshold
        metrics = evaluate_model(
            model=model,
            dataset=dataset,
            device=device,
            score_threshold=threshold,
            iou_threshold=iou_threshold,
            verbose=False,
        )

        results.append(
            {
                "threshold": threshold,
                "precision": metrics["precision"],
                "recall": metrics["recall"],
                "f1": metrics["f1"],
            }
        )

        print(
            f"Precision={metrics['precision']:.4f}, "
            f"Recall={metrics['recall']:.4f}, "
            f"F1={metrics['f1']:.4f}"
        )

    return results


# computes COCO-style mAP metrics
def compute_map(
    model,
    dataset,
    device,
):
    metric = MeanAveragePrecision()

    model.eval()

    with torch.no_grad():
        for idx in range(len(dataset)):
            image, target, file_name = dataset[idx]
            image = image.to(device)

            # runs model inference
            prediction = model([image])[0]

            # moves prediction to CPU
            prediction_cpu = {
                "boxes": prediction["boxes"].detach().cpu(),
                "scores": prediction["scores"].detach().cpu(),
                "labels": prediction["labels"].detach().cpu(),
            }

            # moves target to CPU
            target_cpu = {
                "boxes": target["boxes"].detach().cpu(),
                "labels": target["labels"].detach().cpu(),
            }

            # updates mAP metric
            metric.update(
                [prediction_cpu],
                [target_cpu],
            )

            print(f"[mAP {idx + 1}/{len(dataset)}] {file_name}")

    return metric.compute()