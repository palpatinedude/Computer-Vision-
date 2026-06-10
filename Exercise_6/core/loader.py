import json
import os
from collections import defaultdict
import torch
from PIL import Image
from torchvision.transforms import functional as F


class COCODetectionDataset:

    def __init__(
        self,
        images_dir,
        annotation_path,
        max_images=None
    ):
        self.images_dir = images_dir

        # loads COCO annotation file
        with open(annotation_path, "r") as f:
            self.coco = json.load(f)

        self.images = self.coco["images"]

        # optionally limits the number of images
        if max_images is not None:
            self.images = self.images[:max_images]

        # keeps only image ids used in this dataset split
        valid_image_ids = {
            image["id"]
            for image in self.images
        }

        # groups annotations by image id
        self.annotations_by_image = defaultdict(list)

        for ann in self.coco["annotations"]:
            # ignores crowd annotations
            if (
                ann["image_id"] in valid_image_ids
                and ann.get("iscrowd", 0) == 0
            ):
                self.annotations_by_image[
                    ann["image_id"]
                ].append(ann)

    def __len__(self):
        return len(self.images)

    def __getitem__(self, idx):
        # gets image metadata
        image_info = self.images[idx]

        image_id = image_info["id"]
        file_name = image_info["file_name"]

        image_path = os.path.join(
            self.images_dir,
            file_name
        )

        # loads image and converts it to tensor
        image = Image.open(
            image_path
        ).convert("RGB")

        image_tensor = F.to_tensor(image)

        boxes = []
        labels = []

        # extracts bounding boxes and labels
        for ann in self.annotations_by_image[image_id]:
            x, y, w, h = ann["bbox"]

            # skips invalid bounding boxes
            if w <= 0 or h <= 0:
                continue

            boxes.append(
                [x, y, x + w, y + h]
            )

            labels.append(
                ann["category_id"]
            )

        # creates target dictionary
        target = {
            "image_id": image_id,
            "boxes": torch.tensor(
                boxes,
                dtype=torch.float32
            ),
            "labels": torch.tensor(
                labels,
                dtype=torch.int64
            ),
        }

        return (image_tensor,target,file_name)