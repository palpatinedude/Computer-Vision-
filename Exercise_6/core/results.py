import os

# saves main evaluation results
def save_main_results(
    results_dir,
    model_name,
    file_prefix,
    metrics,
    map_results,
    dataset_size,
    iou_threshold,
    score_threshold,
):
    path = os.path.join(
        results_dir,
        f"{file_prefix}_results.txt"
    )

    with open(path, "w") as f:
        f.write(f"{model_name} Results\n")
        f.write("=" * (len(model_name) + 8))
        f.write("\n\n")

        f.write(f"Images: {dataset_size}\n")
        f.write(f"IoU threshold: {iou_threshold}\n")
        f.write(f"Score threshold: {score_threshold}\n\n")

        f.write(f"TP: {metrics['tp']}\n")
        f.write(f"FP: {metrics['fp']}\n")
        f.write(f"FN: {metrics['fn']}\n\n")

        f.write(f"Precision: {metrics['precision']:.6f}\n")
        f.write(f"Recall: {metrics['recall']:.6f}\n")
        f.write(f"F1: {metrics['f1']:.6f}\n")
        f.write(f"mAP: {map_results['map']:.6f}\n")
        f.write(f"mAP50: {map_results['map_50']:.6f}\n")
        f.write(f"mAP75: {map_results['map_75']:.6f}\n")

        f.write(
            f"Average inference time: "
            f"{metrics['avg_time']:.6f} sec/image\n"
        )

    return path


# saves precision-recall results
def save_pr_results(
    results_dir,
    file_prefix,
    pr_results
):
    path = os.path.join(
        results_dir,
        f"{file_prefix}_pr_results.txt"
    )

    with open(path, "w") as f:
        f.write("threshold,precision,recall,f1\n")

        for item in pr_results:
            f.write(
                f"{item['threshold']:.2f},"
                f"{item['precision']:.6f},"
                f"{item['recall']:.6f},"
                f"{item['f1']:.6f}\n"
            )

    return path


# saves COCO-style mAP results
def save_map_results(
    results_dir,
    model_name,
    file_prefix,
    map_results
):
    path = os.path.join(
        results_dir,
        f"{file_prefix}_map_results.txt"
    )

    with open(path, "w") as f:
        f.write(f"{model_name} mAP Results\n")
        f.write("=" * (len(model_name) + 12))
        f.write("\n\n")

        f.write(f"mAP: {map_results['map']:.6f}\n")
        f.write(f"mAP50: {map_results['map_50']:.6f}\n")
        f.write(f"mAP75: {map_results['map_75']:.6f}\n")

    return path