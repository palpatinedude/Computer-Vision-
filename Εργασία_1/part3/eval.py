'''
# -------------------------
# PSPNet Evaluation Script with excel export
# -------------------------
# This script evaluates a pre-trained PSPNet model on the Cityscapes validation set.
# It computes IoU metrics per class, per image, and overall, saves results to excel,
# and visualizes predictions.
# -------------------------

import os
import sys
import torch
import numpy as np
import pandas as pd
from torch.utils.data import DataLoader
import matplotlib.pyplot as plt
from collections import defaultdict
from google.colab import drive

# Settings
drive.mount('/content/drive')
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
torch.backends.cudnn.benchmark = True

# Base
computer_vision_root = '/content/drive/MyDrive/Computer_Vision/'
codes_and_models_path = computer_vision_root + 'codes_and_models'

# Dataset
dataset_root = computer_vision_root + 'cityscapes_dataset'
val_list = dataset_root + '/list/cityscapes/fine_val.txt'

# Model and supporting files
model_path = codes_and_models_path + '/train_epoch_200_CPU.pth'
colors_path = codes_and_models_path + '/cityscapes_colors.txt'
names_path = codes_and_models_path + '/cityscapes_names.txt'

# Excel output file
excel_path = computer_vision_root + 'pspnet_eval_results.xlsx'


sys.path.append(computer_vision_root)
from codes_and_models.cityscapes_dataset import Cityscapes
from codes_and_models.pspnet import PSPNet


# Function to load PSPNet model
def load_model(model_path, device, num_classes=35):
    # Initialize PSPNet with desired parameters
    model = PSPNet(
        layers=50,           # Number of layers (ResNet50 backbone)
        bins=(2, 3, 6, 8),   # Pyramid Pooling Module bins
        dropout=0.1,         # Dropout rate
        classes=num_classes, # Number of segmentation classes
        zoom_factor=8,       # Zoom factor for output
        use_ppm=True         # Use Pyramid Pooling Module
    )
    # Load pre trained weights
    model.load_state_dict(torch.load(model_path, map_location=device))
    model.to(device)  # Move model to the specified device
    model.eval()      # Set model to evaluation mode (disables dropout, batch norm updates)
    return model


# Function to load class colors and class names from files
def load_colors_and_names(colors_file, names_file):
    colors = {}
    names = {}
    # Load RGB colors for each class
    with open(colors_file, 'r') as f:
        for idx, line in enumerate(f):
            rgb = list(map(int, line.strip().split()))  # split by whitespace
            colors[idx] = rgb
    # Load class names
    with open(names_file, 'r') as f:
        for idx, line in enumerate(f):
            names[idx] = line.strip()
    return colors, names


# Compute IoU for each class in a single prediction
def iou_per_class(pred, target, valid_classes):
    ious = {}
    pred = pred.view(-1)    # Flatten prediction
    target = target.view(-1) # Flatten ground truth
    for cls in valid_classes:
        pred_inds = (pred == cls)   # Pixels predicted as class cls
        target_inds = (target == cls) # Pixels labeled as class cls
        intersection = (pred_inds & target_inds).sum().item()
        union = (pred_inds | target_inds).sum().item()
        ious[cls] = intersection / union if union != 0 else float('nan')
    return ious


# Evaluate the model on the validation dataset and compute IoU per class and mean IoU per image
def evaluate_model(model, dataloader, valid_classes):
    all_ious_per_class = defaultdict(list)
    all_ious_per_image = []

    # Disable gradient computation for evaluation
    with torch.no_grad():
        for imgs, masks in dataloader:
            imgs = imgs.to(device)
            masks = masks.to(device)

            # Forward pass
            outputs = model(imgs)
            preds = torch.argmax(outputs, dim=1)  # Convert logits to class predictions

            # Evaluate each image in the batch
            for b in range(preds.size(0)):
                pred_b = preds[b]
                mask_b = masks[b]

                # Compute IoU per class
                ious_cls = iou_per_class(pred_b, mask_b, valid_classes)
                for cls, iou_val in ious_cls.items():
                    if not np.isnan(iou_val):
                        all_ious_per_class[cls].append(iou_val)

                # Compute mean IoU for this image
                ious_vals = [v for v in ious_cls.values() if not np.isnan(v)]
                if ious_vals:
                    all_ious_per_image.append(np.mean(ious_vals))

    return all_ious_per_class, all_ious_per_image


# Convert segmentation mask (class IDs) to RGB image for visualization
def decode_segmap(mask, colors):
    h, w = mask.shape
    rgb = np.zeros((h, w, 3), dtype=np.uint8)
    for cls_id, color in colors.items():
        rgb[mask == cls_id] = color
    return rgb

# Display example predictions alongside ground truth images
def visualize_predictions(dataset, model, colors, device, n=5):
    model.eval()
    for i in range(n):
        img, mask = dataset[i]
        img_tensor = img.unsqueeze(0).to(device)
        with torch.no_grad():
            pred = torch.argmax(model(img_tensor)[0], dim=0).cpu().numpy()

        # Plot original image, ground truth, and prediction
        plt.figure(figsize=(15, 5))
        plt.subplot(1, 3, 1)
        plt.title("Image")
        plt.imshow(img.permute(1, 2, 0))
        plt.subplot(1, 3, 2)
        plt.title("Ground Truth")
        plt.imshow(decode_segmap(mask.numpy(), colors))
        plt.subplot(1, 3, 3)
        plt.title("Prediction")
        plt.imshow(decode_segmap(pred, colors))
        plt.show()

# -------------------------
# Main execution
# -------------------------
if __name__ == "__main__":
    print("Loading model...")
    model = load_model(model_path, device)

    # Create dataset object
    val_dataset = Cityscapes(
        split='val',         # Validation split
        data_root=dataset_root,
        data_list=val_list
    )

    # Create DataLoader for batching
    val_loader = DataLoader(
        val_dataset,
        batch_size=1,       # Number of images per batch
        shuffle=False,      # Do not shuffle validation set
        num_workers=1,      # Parallel data loading workers
        pin_memory=True     # Speed up GPU transfers
    )

    # Load class colors and class names
    colors, class_names = load_colors_and_names(colors_path, names_path)

    # Determine all valid classes present in the dataset
    valid_classes = sorted(list(set(torch.unique(torch.cat([mask for _, mask in val_dataset])))))

    print("Evaluating on validation set...")
    all_ious_per_class, all_ious_per_image = evaluate_model(model, val_loader, valid_classes)


    # Export results to excel

    # Prepare per class statistics
    class_data = []
    for cls in valid_classes:
        values = all_ious_per_class[cls]
        mean_iou = np.mean(values) if values else float('nan')
        var_iou = np.var(values) if values else float('nan')
        class_data.append({
            'Class ID': cls,
            'Class Name': class_names.get(cls, 'Unknown'),
            'Mean IoU': mean_iou,
            'Variance IoU': var_iou,
            'Num Images': len(values)
        })
    df_class = pd.DataFrame(class_data)

    # Prepare per image statistics
    image_data = [{'Image Index': idx, 'Mean IoU': miou} for idx, miou in enumerate(all_ious_per_image)]
    df_image = pd.DataFrame(image_data)
    df_image['Variance IoU'] = np.var(all_ious_per_image)

    # Overall statistics
    all_values = [v for values in all_ious_per_class.values() for v in values]
    df_overall = pd.DataFrame([{
        'Overall Mean IoU': np.mean(all_values),
        'Overall Variance IoU': np.var(all_values)
    }])

    # Write results to excel
    with pd.ExcelWriter(excel_path) as writer:
        df_class.to_excel(writer, sheet_name='Per_Class', index=False)
        df_image.to_excel(writer, sheet_name='Per_Image', index=False)
        df_overall.to_excel(writer, sheet_name='Overall', index=False)

    print(f"\nResults saved to {excel_path}")
    print(f"Overall Mean IoU: {np.mean(all_values):.4f} | Overall Variance: {np.var(all_values):.4f}")

    print("\nVisualizing example predictions...")
    visualize_predictions(val_dataset, model, colors, device, n=5)
'''

''' RUN
# ------------------------- 
# PSPNet Evaluation Script - LOCAL LINUX VERSION (Updated Paths)
# ------------------------- 

import os 
import sys 
import torch 
import numpy as np 
import pandas as pd 
from torch.utils.data import DataLoader 
import matplotlib.pyplot as plt 
from collections import defaultdict 
# --- PATH CONFIGURATION (Final Version) ---
base_path = os.path.dirname(os.path.abspath(__file__))
cityscapes_dir = os.path.join(base_path, 'Cityscapes')

# Προσθέτουμε ΤΟΝ ΦΑΚΕΛΟ Cityscapes στο sys.path
# Έτσι το 'from codes_and_models...' θα δουλέψει παντού
if cityscapes_dir not in sys.path:
    sys.path.insert(0, cityscapes_dir)

# Ορισμός διαδρομών για τα αρχεία
dataset_root = os.path.join(cityscapes_dir, 'cityscapes_dataset')
codes_and_models_path = os.path.join(cityscapes_dir, 'codes_and_models')

val_list = os.path.join(dataset_root, 'list', 'cityscapes', 'fine_val.txt')
model_path = os.path.join(codes_and_models_path, 'train_epoch_200_CPU.pth')
colors_path = os.path.join(codes_and_models_path, 'cityscapes_colors.txt')
names_path = os.path.join(codes_and_models_path, 'cityscapes_names.txt')
excel_path = os.path.join(base_path, 'pspnet_eval_results.xlsx')

device = torch.device("cpu")

# --- IMPORTS ---
try:
    # Τώρα τα καλούμε μέσω του codes_and_models για να συμβαδίζουν με τα εσωτερικά imports
    from codes_and_models.cityscapes_dataset import Cityscapes 
    from codes_and_models.pspnet import PSPNet 
    print("Successfully imported Cityscapes and PSPNet modules.")
except ImportError as e:
    print(f"Import Error: {e}")
    sys.exit(1)



def load_model(model_path, device, num_classes=35): 
    model = PSPNet(layers=50, bins=(2, 3, 6, 8), dropout=0.1, classes=num_classes, zoom_factor=8, use_ppm=True) 
    model.load_state_dict(torch.load(model_path, map_location=device)) 
    model.to(device) 
    model.eval() 
    return model 

def load_colors_and_names(colors_file, names_file): 
    colors = {}; names = {}
    with open(colors_file, 'r') as f: 
        for idx, line in enumerate(f): colors[idx] = list(map(int, line.strip().split())) 
    with open(names_file, 'r') as f: 
        for idx, line in enumerate(f): names[idx] = line.strip() 
    return colors, names 

def iou_per_class(pred, target, valid_classes): 
    ious = {} 
    pred, target = pred.view(-1), target.view(-1) 
    for cls in valid_classes: 
        pred_inds = (pred == cls) 
        target_inds = (target == cls) 
        intersection = (pred_inds & target_inds).sum().item() 
        union = (pred_inds | target_inds).sum().item() 
        ious[cls] = intersection / union if union != 0 else float('nan') 
    return ious 

def evaluate_model(model, dataloader, valid_classes): 
    all_ious_per_class = defaultdict(list) 
    all_ious_per_image = [] 
    with torch.no_grad(): 
        for i, (imgs, masks) in enumerate(dataloader): 
            if i % 5 == 0: print(f"Processing image {i}/{len(dataloader)}...")
            imgs, masks = imgs.to(device), masks.to(device) 
            outputs = model(imgs) 
            preds = torch.argmax(outputs, dim=1) 
            for b in range(preds.size(0)): 
                ious_cls = iou_per_class(preds[b], masks[b], valid_classes) 
                for cls, iou_val in ious_cls.items(): 
                    if not np.isnan(iou_val): all_ious_per_class[cls].append(iou_val) 
                ious_vals = [v for v in ious_cls.values() if not np.isnan(v)] 
                if ious_vals: all_ious_per_image.append(np.mean(ious_vals)) 
    return all_ious_per_class, all_ious_per_image 

def decode_segmap(mask, colors): 
    h, w = mask.shape 
    rgb = np.zeros((h, w, 3), dtype=np.uint8) 
    for cls_id, color in colors.items(): rgb[mask == cls_id] = color 
    return rgb 

def visualize_predictions(dataset, model, colors, device, n=2): 
    model.eval() 
    for i in range(min(n, len(dataset))): 
        img, mask = dataset[i] 
        img_tensor = img.unsqueeze(0).to(device) 
        with torch.no_grad(): 
            pred = torch.argmax(model(img_tensor)[0], dim=0).cpu().numpy() 
        plt.figure(figsize=(12, 4)) 
        plt.subplot(1, 3, 1); plt.title("Original"); plt.imshow(img.permute(1, 2, 0)) 
        plt.subplot(1, 3, 2); plt.title("GT"); plt.imshow(decode_segmap(mask.numpy(), colors)) 
        plt.subplot(1, 3, 3); plt.title("Prediction"); plt.imshow(decode_segmap(pred, colors)) 
        plt.show() 

# --- MAIN EXECUTION ---
if __name__ == "__main__": 
    # ΡΥΘΜΙΣΗ: Βάλε έναν αριθμό (π.χ. 10) για γρήγορο τεστ ή None για όλες τις εικόνες
    LIMIT_IMAGES = None

    print("Initializing Evaluation...") 
    model = load_model(model_path, device) 
    colors, class_names = load_colors_and_names(colors_path, names_path) 

    val_dataset = Cityscapes(split='val', data_root=dataset_root, data_list=val_list) 
    
    if LIMIT_IMAGES:
        print(f"!!! Testing mode active: Evaluating only first {LIMIT_IMAGES} images !!!")
        val_dataset = torch.utils.data.Subset(val_dataset, range(LIMIT_IMAGES))

    val_loader = DataLoader(val_dataset, batch_size=1, shuffle=False, num_workers=0) 

    valid_classes = sorted(list(class_names.keys()))

    print(f"Starting evaluation on {len(val_dataset)} images...") 
    all_ious_per_class, all_ious_per_image = evaluate_model(model, val_loader, valid_classes) 

    # Export to Excel
    class_data = [] 
    for cls in valid_classes: 
        values = all_ious_per_class[cls] 
        class_data.append({
            'Class ID': cls, 'Class Name': class_names.get(cls, 'Unknown'), 
            'Mean IoU': np.mean(values) if values else 0, 
            'Count': len(values)
        }) 
    
    df_class = pd.DataFrame(class_data)
    all_vals = [v for values in all_ious_per_class.values() for v in values]
    
    with pd.ExcelWriter(excel_path) as writer: 
        df_class.to_excel(writer, sheet_name='Per_Class', index=False) 
        pd.DataFrame([{'Mean IoU': np.mean(all_vals), 'Total Images': len(val_dataset)}]).to_excel(writer, sheet_name='Overall')

    print(f"\nSuccess! Results: {excel_path}") 
    print(f"Final mIoU: {np.mean(all_vals):.4f}") 
    
    visualize_predictions(val_dataset, model, colors, device, n=2)
'''

'''
# -------------------------
# PSPNet Evaluation Script with excel export
# -------------------------
# This script evaluates a pre-trained PSPNet model on the Cityscapes validation set.
# It computes IoU metrics per class, per image, and overall, saves results to excel,
# and visualizes predictions.
# -------------------------

import os            
import sys          
import torch         
import numpy as np   
import pandas as pd   
import time           
from torch.utils.data import DataLoader  
import matplotlib.pyplot as plt         


# Base folder
base_path = os.path.dirname(os.path.abspath(__file__))

# Cityscapes directory
cityscapes_dir = os.path.join(base_path, 'Cityscapes')

if cityscapes_dir not in sys.path:
    sys.path.insert(0, cityscapes_dir)

# Full paths 
dataset_root = os.path.join(cityscapes_dir, 'cityscapes_dataset')
codes_and_models_path = os.path.join(cityscapes_dir, 'codes_and_models')
val_list = os.path.join(dataset_root, 'list', 'cityscapes', 'fine_val.txt')
model_path = os.path.join(codes_and_models_path, 'train_epoch_200_CPU.pth')
colors_path = os.path.join(codes_and_models_path, 'cityscapes_colors.txt')
names_path = os.path.join(codes_and_models_path, 'cityscapes_names.txt')
excel_path = os.path.join(base_path, 'pspnet_eval_results.xlsx')

# Set device for inference (CPU in this case)
device = torch.device("cpu")


try:
    from codes_and_models.cityscapes_dataset import Cityscapes
    from codes_and_models.pspnet import PSPNet
    print("Modules loaded successfully")
except ImportError as e:
    print(f"Import Error: {e}")
    sys.exit(1)


#  Load color palette and class names from text files
def load_colors_and_names(colors_file, names_file):
    colors = {}
    names = {}
    
    # Load colors line by line
    with open(colors_file, 'r') as f:
        for idx, line in enumerate(f):
            # Convert string values to integers and store as a list
            colors[idx] = list(map(int, line.strip().split()))
    
    # Load class names line by line
    with open(names_file, 'r') as f:
        for idx, line in enumerate(f):
            names[idx] = line.strip()
    
    return colors, names

#  Calculate IoU for each class in single image
def iou_per_class(pred, target, valid_classes):
    ious = {}
    
    # Flatten masks
    pred = pred.view(-1)
    target = target.view(-1)
    
    # Loop over each class
    for cls in valid_classes:
        pred_inds = (pred == cls)       # Boolean mask for predicted pixels
        target_inds = (target == cls)   # Boolean mask for true pixels
        intersection = (pred_inds & target_inds).sum().item()
        union = (pred_inds | target_inds).sum().item()
        ious[cls] = intersection / union if union != 0 else float('nan')
    
    return ious

# Convert a mask of class indices into an RGB image
def decode_segmap(mask, colors):
    h, w = mask.shape
    rgb = np.zeros((h, w, 3), dtype=np.uint8)
    for cls_id, color in colors.items():
        rgb[mask == cls_id] = color
    return rgb



# Evaluate PSPNet on the dataset 
def evaluate_model_benchmark(model, dataloader, valid_classes):
    all_ious_per_class = defaultdict(list)  # Store IoU per class
    latencies = []                           # Store inference times
    
    # Prevents "cold start"
    print("Warming up CPU")
    warmup_batch = torch.randn(1, 3, 713, 713).to(device)
    for _ in range(5):
        with torch.no_grad():
            _ = model(warmup_batch)
    
    print(f"Benchmarking {len(dataloader.dataset)} images ")
    
    start_total_clock = time.perf_counter()  # Start overall timer
    
    # Loop through dataset 
    with torch.no_grad():
        for i, (imgs, masks) in enumerate(dataloader):
            imgs = imgs.to(device)
            
            # Measure batch inference time
            start_inf = time.perf_counter()
            outputs = model(imgs)  # Forward pass
            end_inf = time.perf_counter()
            
            # Store latency in milliseconds
            latencies.append((end_inf - start_inf) * 1000)
            
            # Convert predictions to class IDs
            preds = torch.argmax(outputs, dim=1).cpu()
            
            # Compute IoU for each image in the batch
            for b in range(preds.size(0)):
                ious_cls = iou_per_class(preds[b], masks[b], valid_classes)
                for cls, iou_val in ious_cls.items():
                    if not np.isnan(iou_val):
                        all_ious_per_class[cls].append(iou_val)
            
            # Print progress every 10 batches
            if i % 10 == 0:
                print(f"Batch {i}/{len(dataloader)} | Recent Latency: {latencies[-1]:.2f} ms")
    
    # Total clock time
    end_total_clock = time.perf_counter()
    total_time = end_total_clock - start_total_clock
    
    return all_ious_per_class, latencies, total_time


# Visualize sample predictions 
def visualize_post_eval(dataset, model, colors, device, n=2):
    print(f"\nVisualizing {n} sample results...")
    model.eval()  # Set model to evaluation mode
    
    for i in range(min(n, len(dataset))):
        img, mask = dataset[i]
        img_tensor = img.unsqueeze(0).to(device)  # Add batch dimension
        
        # Forward pass
        with torch.no_grad():
            pred = torch.argmax(model(img_tensor)[0], dim=0).cpu().numpy()
        
        # Plot original, ground truth, and prediction
        plt.figure(figsize=(15, 5))
        plt.subplot(1, 3, 1)
        plt.title("Original Image")
        plt.imshow(img.permute(1, 2, 0))  # Convert CHW -> HWC
        
        plt.subplot(1, 3, 2)
        plt.title("Ground Truth")
        plt.imshow(decode_segmap(mask.numpy(), colors))
        
        plt.subplot(1, 3, 3)
        plt.title("PSPNet Prediction")
        plt.imshow(decode_segmap(pred, colors))
        
        plt.show()


# MAIN SCRIPT
if __name__ == "__main__":
    LIMIT_IMAGES = None  # None = evaluate all images
    BATCH_SIZE = 2       # Small batch size for CPU
    NUM_WORKERS = 4      # Threads for data loading
    
    print("Initializing PSPNet evaluation...")
    
    # Load model 
    model = PSPNet(
        layers=50,
        bins=(2, 3, 6, 8),
        dropout=0.1,
        classes=35,
        zoom_factor=8,
        use_ppm=True
    )
    model.load_state_dict(torch.load(model_path, map_location=device))
    model.to(device)
    model.eval()
    
    # Load color palette and class names 
    colors, class_names = load_colors_and_names(colors_path, names_path)
    
    # Load validation dataset
    val_dataset = Cityscapes(
        split='val',
        data_root=dataset_root,
        data_list=val_list
    )
    
    if LIMIT_IMAGES:
        val_dataset = torch.utils.data.Subset(val_dataset, range(LIMIT_IMAGES))
    
    # Create dataLoader 
    val_loader = DataLoader(
        val_dataset,
        batch_size=BATCH_SIZE,
        shuffle=False,
        num_workers=NUM_WORKERS,
        pin_memory=True
    )
    
    # List of valid class IDs
    valid_classes = sorted(list(class_names.keys()))
    
    # Run evaluation 
    ious_data, latencies, total_runtime = evaluate_model_benchmark(
        model, val_loader, valid_classes
    )
    
    # Compute performance statistics 
    avg_batch_ms = np.mean(latencies)
    fps = (1000 * BATCH_SIZE) / avg_batch_ms  # Frames per second
    
    print("\n" + "═"*50)
    print("HARDWARE PERFORMANCE REPORT")
    print("═"*50)
    print(f"Device:           {device}")
    print(f"Average Latency:  {avg_batch_ms:.2f} ms per batch")
    print(f"Throughput:       {fps:.2f} FPS")
    print(f"Total Wall Time:  {total_runtime:.2f} seconds")
    
    # --- Compute final mean IoU ---
    all_vals = [v for values in ious_data.values() for v in values]
    final_miou = np.mean(all_vals)
    print(f"Final mIoU:       {final_miou:.4f}")
    print("═"*50)
    
    # Save per class IoU to excel
    class_df = pd.DataFrame([
        {
            'Class Name': class_names.get(c, 'NA'),
            'mIoU': np.mean(v) if v else 0
        }
        for c, v in ious_data.items()
    ])
    class_df.to_excel(excel_path, index=False)
    print(f"Results saved to: {excel_path}")
    
    # Visualize a few sample prediction
    visualize_post_eval(val_dataset, model, colors, device, n=2)
'''

# -------------------------
# PSPNet Evaluation Script with excel export
# -------------------------
# This script evaluates a pre-trained PSPNet model on the Cityscapes validation set.
# It computes IoU metrics per class, per image, and overall, saves results to excel,
# and visualizes predictions.
# -------------------------

import os            
import sys          
import torch         
import numpy as np   
import pandas as pd   
import time           
from torch.utils.data import DataLoader  
import matplotlib.pyplot as plt         
from collections import defaultdict

# Base folder
base_path = os.path.dirname(os.path.abspath(__file__))

# Cityscapes directory
cityscapes_dir = os.path.join(base_path, 'Cityscapes')

if cityscapes_dir not in sys.path:
    sys.path.insert(0, cityscapes_dir)

# Full paths 
dataset_root = os.path.join(cityscapes_dir, 'cityscapes_dataset')
codes_and_models_path = os.path.join(cityscapes_dir, 'codes_and_models')
val_list = os.path.join(dataset_root, 'list', 'cityscapes', 'fine_val.txt')
model_path = os.path.join(codes_and_models_path, 'train_epoch_200_CPU.pth')
colors_path = os.path.join(codes_and_models_path, 'cityscapes_colors.txt')
names_path = os.path.join(codes_and_models_path, 'cityscapes_names.txt')
excel_path = os.path.join(base_path, 'pspnet_eval_results.xlsx')

# Set device for inference (CPU in this case)
device = torch.device("cpu")


try:
    from codes_and_models.cityscapes_dataset import Cityscapes
    from codes_and_models.pspnet import PSPNet
    print("Modules loaded successfully")
except ImportError as e:
    print(f"Import Error: {e}")
    sys.exit(1)


#  Load color palette and class names from text files
def load_colors_and_names(colors_file, names_file):
    colors = {}
    names = {}
    
    # Load colors line by line
    with open(colors_file, 'r') as f:
        for idx, line in enumerate(f):
            # Convert string values to integers and store as a list
            colors[idx] = list(map(int, line.strip().split()))
    
    # Load class names line by line
    with open(names_file, 'r') as f:
        for idx, line in enumerate(f):
            names[idx] = line.strip()
    
    return colors, names

#  Calculate IoU for each class in single image
def iou_per_class(pred, target, valid_classes):
    ious = {}
    
    # Flatten masks
    pred = pred.view(-1)
    target = target.view(-1)
    
    # Loop over each class
    for cls in valid_classes:
        pred_inds = (pred == cls)       # Boolean mask for predicted pixels
        target_inds = (target == cls)   # Boolean mask for true pixels
        intersection = (pred_inds & target_inds).sum().item()
        union = (pred_inds | target_inds).sum().item()
        ious[cls] = intersection / union if union != 0 else float('nan')
    
    return ious

# Convert a mask of class indices into an RGB image
def decode_segmap(mask, colors):
    h, w = mask.shape
    rgb = np.zeros((h, w, 3), dtype=np.uint8)
    for cls_id, color in colors.items():
        rgb[mask == cls_id] = color
    return rgb



# Evaluate PSPNet on the dataset 
def evaluate_model_benchmark(model, dataloader, valid_classes):
    all_ious_per_class = defaultdict(list)  # Store IoU per class
    per_image_mious = []                    # Store mean IoU for each individual image
    latencies = []                           # Store inference times
    
    # Prevents "cold start"
    print("Warming up CPU")
    warmup_batch = torch.randn(1, 3, 713, 713).to(device)
    for _ in range(5):
        with torch.no_grad():
            _ = model(warmup_batch)
    
    print(f"Benchmarking {len(dataloader.dataset)} images ")
    
    start_total_clock = time.perf_counter()  # Start overall timer
    
    # Loop through dataset 
    with torch.no_grad():
        for i, (imgs, masks) in enumerate(dataloader):
            imgs = imgs.to(device)
            
            # Measure batch inference time
            start_inf = time.perf_counter()
            outputs = model(imgs)  # Forward pass
            end_inf = time.perf_counter()
            
            # Store latency in milliseconds
            latencies.append((end_inf - start_inf) * 1000)
            
            # Convert predictions to class IDs
            preds = torch.argmax(outputs, dim=1).cpu()
            
            # Compute IoU for each image in the batch
            for b in range(preds.size(0)):
                ious_cls = iou_per_class(preds[b], masks[b], valid_classes)
                
                # Requirements 5.2: Per-image mIoU logic
                current_image_ious = []
                for cls, iou_val in ious_cls.items():
                    if not np.isnan(iou_val):
                        all_ious_per_class[cls].append(iou_val)
                        current_image_ious.append(iou_val)
                
                if current_image_ious:
                    per_image_mious.append(np.mean(current_image_ious))
            
            # Print progress every 10 batches
            if i % 10 == 0:
                print(f"Batch {i}/{len(dataloader)} | Recent Latency: {latencies[-1]:.2f} ms")
    
    # Total clock time
    end_total_clock = time.perf_counter()
    total_time = end_total_clock - start_total_clock
    
    return all_ious_per_class, per_image_mious, latencies, total_time


# Visualize sample predictions 
def visualize_post_eval(dataset, model, colors, device, n=2):
    print(f"\nVisualizing {n} sample results...")
    model.eval()  # Set model to evaluation mode
    
    for i in range(min(n, len(dataset))):
        img, mask = dataset[i]
        img_tensor = img.unsqueeze(0).to(device)  # Add batch dimension
        
        # Forward pass
        with torch.no_grad():
            pred = torch.argmax(model(img_tensor)[0], dim=0).cpu().numpy()
        
        # Plot original, ground truth, and prediction
        plt.figure(figsize=(15, 5))
        plt.subplot(1, 3, 1)
        plt.title("Original Image")
        plt.imshow(img.permute(1, 2, 0))  # Convert CHW -> HWC
        
        plt.subplot(1, 3, 2)
        plt.title("Ground Truth")
        plt.imshow(decode_segmap(mask.numpy(), colors))
        
        plt.subplot(1, 3, 3)
        plt.title("PSPNet Prediction")
        plt.imshow(decode_segmap(pred, colors))
        
        plt.show()

# Function to plot per-class performance
def plot_class_performance(class_results):
    names = [res['Class Name'] for res in class_results]
    ious = [res['Mean IoU'] for res in class_results]
    
    plt.figure(figsize=(12, 8))
    plt.barh(names, ious, color='skyblue')
    plt.xlabel('Mean IoU')
    plt.title('PSPNet Performance per Class (Cityscapes)')
    plt.grid(axis='x', linestyle='--', alpha=0.7)
    plt.tight_layout()
    plt.show()


# MAIN SCRIPT
if __name__ == "__main__":
    LIMIT_IMAGES = None  # None = evaluate all images
    BATCH_SIZE = 2       # Small batch size for CPU
    NUM_WORKERS = 4      # Threads for data loading
    
    print("Initializing PSPNet evaluation...")
    
    # Load model 
    model = PSPNet(
        layers=50,
        bins=(2, 3, 6, 8),
        dropout=0.1,
        classes=35,
        zoom_factor=8,
        use_ppm=True
    )
    model.load_state_dict(torch.load(model_path, map_location=device))
    model.to(device)
    model.eval()
    
    # Load color palette and class names 
    colors, class_names = load_colors_and_names(colors_path, names_path)
    
    # Load validation dataset
    val_dataset = Cityscapes(
        split='val',
        data_root=dataset_root,
        data_list=val_list
    )
    
    if LIMIT_IMAGES:
        val_dataset = torch.utils.data.Subset(val_dataset, range(LIMIT_IMAGES))
    
    # Create dataLoader 
    val_loader = DataLoader(
        val_dataset,
        batch_size=BATCH_SIZE,
        shuffle=False,
        num_workers=NUM_WORKERS,
        pin_memory=True
    )
    
    # List of valid class IDs
    valid_classes = sorted(list(class_names.keys()))
    
    # Run evaluation 
    ious_data, img_mious, latencies, total_runtime = evaluate_model_benchmark(
        model, val_loader, valid_classes
    )
    
    # Compute performance statistics 
    avg_batch_ms = np.mean(latencies)
    fps = (1000 * BATCH_SIZE) / avg_batch_ms  # Frames per second
    
    # Statistics per image
    mean_img_perf = np.mean(img_mious)
    var_img_perf = np.var(img_mious)
    std_img_perf = np.std(img_mious)

    print("\n" + "═"*50)
    print("HARDWARE PERFORMANCE REPORT")
    print("═"*50)
    print(f"Device:           {device}")
    print(f"Average Latency:  {avg_batch_ms:.2f} ms per batch")
    print(f"Throughput:       {fps:.2f} FPS")
    print(f"Total Wall Time:  {total_runtime:.2f} seconds")
    
    print("\n" + "═"*50)
    print("PER-IMAGE STATISTICS")
    print("═"*50)
    print(f"Mean Performance (mIoU): {mean_img_perf:.4f}")
    print(f"Variance (per image):    {var_img_perf:.4f}")
    print(f"Standard Deviation:      {std_img_perf:.4f}")
    print("═"*50)
    
    # Statistics per class
    class_results = []
    for c in valid_classes:
        v = ious_data[c]
        if v:
            class_results.append({
                'Class Name': class_names.get(c, 'Unknown'),
                'Mean IoU': np.mean(v),
                'Variance': np.var(v),
                'Std Dev': np.std(v),
                'Image Count': len(v)
            })
        else:
            class_results.append({
                'Class Name': class_names.get(c, 'Unknown'),
                'Mean IoU': 0, 'Variance': 0, 'Std Dev': 0, 'Image Count': 0
            })

    # Save detailed stats to excel
    class_df = pd.DataFrame(class_results)
    class_df.to_excel(excel_path, index=False)
    print(f"Full Statistical Results saved to: {excel_path}")
    
    # Plot performance bar chart
    plot_class_performance(class_results)
    
    # Visualize a few sample prediction
    visualize_post_eval(val_dataset, model, colors, device, n=2)