# computes intersection over union between two bounding boxes
def compute_iou(box1, box2):
    # computes intersection coordinates
    x1 = max(box1[0], box2[0])
    y1 = max(box1[1], box2[1])
    x2 = min(box1[2], box2[2])
    y2 = min(box1[3], box2[3])

    # computes intersection area
    inter_w = max(0.0, x2 - x1)
    inter_h = max(0.0, y2 - y1)
    intersection = inter_w * inter_h

    # computes box areas
    area1 = max(0.0, box1[2] - box1[0]) * max(0.0, box1[3] - box1[1])
    area2 = max(0.0, box2[2] - box2[0]) * max(0.0, box2[3] - box2[1])

    # computes union area
    union = area1 + area2 - intersection

    # handles invalid boxes
    if union <= 0:
        return 0.0

    return intersection / union


# evaluates predictions for one image
def evaluate_image(prediction, target, score_threshold=0.5, iou_threshold=0.5):
    # moves predictions to CPU
    pred_boxes = prediction["boxes"].detach().cpu()
    pred_labels = prediction["labels"].detach().cpu()
    pred_scores = prediction["scores"].detach().cpu()

    # moves ground truth targets to CPU
    gt_boxes = target["boxes"].detach().cpu()
    gt_labels = target["labels"].detach().cpu()

    # keeps predictions above score threshold
    keep = pred_scores >= score_threshold

    pred_boxes = pred_boxes[keep]
    pred_labels = pred_labels[keep]

    # stores matched ground truth boxes
    matched_gt = set()

    tp = 0
    fp = 0

    for pred_box, pred_label in zip(pred_boxes, pred_labels):
        best_iou = 0.0
        best_gt_idx = -1

        # finds best matching ground truth box
        for gt_idx, (gt_box, gt_label) in enumerate(zip(gt_boxes, gt_labels)):
            if gt_idx in matched_gt:
                continue

            if pred_label.item() != gt_label.item():
                continue

            iou = compute_iou(pred_box.tolist(), gt_box.tolist())

            if iou > best_iou:
                best_iou = iou
                best_gt_idx = gt_idx

        # counts prediction as true positive or false positive
        if best_iou >= iou_threshold:
            tp += 1
            matched_gt.add(best_gt_idx)
        else:
            fp += 1

    # counts unmatched ground truth boxes as false negatives
    fn = len(gt_boxes) - len(matched_gt)

    return tp, fp, fn


# computes precision, recall and F1 score
def precision_recall_f1(tp, fp, fn):
    # computes precision
    precision = tp / (tp + fp) if (tp + fp) > 0 else 0.0

    # computes recall
    recall = tp / (tp + fn) if (tp + fn) > 0 else 0.0

    # computes F1 score
    f1 = (
        2 * precision * recall / (precision + recall)
        if (precision + recall) > 0
        else 0.0
    )

    return precision, recall, f1