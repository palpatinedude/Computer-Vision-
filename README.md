# Computer Vision Laboratory Exercises

This repository contains a collection of laboratory exercises developed for the Computer Vision course. The projects focus on image processing, geometric vision, feature extraction, image alignment, and image mosaicing using MATLAB and Simulink.

---

# Repository Structure

```text
Exercise_1/   → Multi-Scale Image Decomposition
Exercise_2/   → Geometric Transformations
Exercise_3/   → Scale Invariant Feature Transform (SIFT)
Exercise_4/   → Image Alignment & Image Mosaicing
Exercise_5/   → Autoencodrs & Variatonal AE
Exercise_6/   → CNN-Based Object Detectio
```

---

# Multi-Scale Image Decomposition — Exercise 1

---

## Overview

Exercise 1 focuses on the development of **multi-scale image decomposition** using filters such as Gaussian and Laplacian pyramids. The goal is to apply these techniques for:

- Denoising images  
- Extracting features and structures for efficient coding, compression, and enhancement  
- Image blending and mosaicking with natural seamless results  

The exercise emphasizes using Laplacian pyramids to combine multiple images into a composite where the transitions are smooth and visually almost invisible.

---

## Objectives

- Understand Gaussian and Laplacian pyramids for multi-scale representation  
- Implement image blending using masks and pyramid decomposition  
- Analyze and reconstruct images from pyramid representations  
- Explore the application of pyramids in deep learning through Spatial Pyramid Pooling (SPP)  

---

# Geometric Transformations — Exercise 2

---

## Overview

This project corresponds to Exercise 2 and focuses on the application of
geometric transformations in digital image processing. The exercise explores
how affine transformations can be used to manipulate images and create animated
image sequences using MATLAB.

---

## Objectives

The main objectives of Exercise 2 are:

- Understand the basic principles of geometric transformations
- Apply affine transformations such as scaling, rotation, translation, and shearing
- Create composite images and animated sequences
- Compare different interpolation methods

# Scale Invariant Feature Transform (SIFT) — Exercise 3

---

## Overview

Exercise 3 focuses on the analysis and implementation of the
Scale Invariant Feature Transform (SIFT) algorithm. SIFT is a widely
used and robust computer vision technique for extracting distinctive
features that are invariant to scale, rotation, and illumination changes.

---

## Objectives

The main objectives of this laboratory exercise are:

- Understand the principles of scale-space representation
- Detect stable and repeatable keypoints across different image scales
- Construct distinctive feature descriptors for image matching
- Filter out unstable or noisy keypoints
- Apply geometric verification using robust estimation techniques

---
- Use masking techniques for realistic image composition

---


# Image Alignment & Image Mosaicing — Exercise 4

---

## Overview

Exercise 4 focuses on image registration and panoramic image mosaicing.
The exercise is divided into two main parts. The first part examines
gradient-based image alignment algorithms using MATLAB, while the second
part involves the implementation of a complete image stitching pipeline
using Simulink.

---

## Objectives

The main objectives of this laboratory exercise are:

- Analyze gradient-based alignment algorithms such as ECC and Lucas-Kanade
- Evaluate image registration performance under geometric and photometric distortions
- Understand two-dimensional geometric transformations
- Implement affine and projective motion models
- Develop an end-to-end image mosaicing system
- Apply robust estimation techniques to eliminate incorrect matches

---

# Image Alignment & Image Mosaicing — Exercise 4

---

## Overview

Exercise 4 focuses on image registration, geometric alignment, and panoramic image mosaicing using MATLAB and Simulink.

The exercise is divided into two main parts:

- Part A — Gradient-based Image Alignment
- Part B — Geometric Vision & Image Stitching

The first part investigates iterative image alignment algorithms such as Enhanced Correlation Coefficient (ECC) and Lucas-Kanade (LK).

The second part focuses on affine/projective geometric transformations and the implementation of a complete image stitching pipeline in Simulink.

Additionally, the project includes migration and debugging of legacy Simulink Computer Vision Toolbox models to MATLAB R2024b.

---

## Part A — Image Alignment

---

### Overview

Part A investigates gradient-based image registration algorithms for aligning image sequences under:
- geometric distortions,
- photometric variations,
- and additive noise.

The following algorithms are studied:

- Enhanced Correlation Coefficient (ECC)
- Lucas-Kanade (LK)

---

### Experiments

The following experiments were implemented:

- Large geometric deformation analysis
- Sequential frame alignment
- PSNR evaluation across sequences
- Photometric distortion experiments
- Monte Carlo noise robustness experiments

Noise experiments included:
- Gaussian noise
- Uniform noise

Monte Carlo simulations were performed using 100 runs for each noise configuration.

---

### Implemented MATLAB Modules

Core modules:

```text
ecc_lk_alignment.m
spatial_interp.m
image_jacobian.m
warp_jacobian.m
param_update.m
```

Analysis scripts:

```text
large_deformations.m
psnr_sequence.m
photometric.m
noise_montecarlo.m
```

---

### Topics Covered

- Image Registration
- Lucas-Kanade Alignment
- Enhanced Correlation Coefficient (ECC)
- Gradient-Based Optimization
- Image Jacobians
- Warp Jacobians
- Photometric Robustness
- Monte Carlo Evaluation
- PSNR Analysis

---

## Part B — Geometric Vision & Image Mosaicing

---

### Overview

Part B focuses on geometric computer vision and panoramic image stitching using Simulink.

The exercise explores:
- affine transformations,
- projective transformations,
- corner detection,
- feature matching,
- robust geometric estimation,
- image warping,
- and image stitching.

A complete mosaic generation pipeline was implemented in Simulink.

---

### Geometric Transformations

The following affine transformation experiments were implemented:

- Scaling
- Rotation
- Translation
- Shear deformation

Additionally, projective geometric transformations were analyzed and compared with affine transformations.

---

### Corner Detection

Corner detection experiments were implemented using:

- Harris & Stephens detector
- Shi-Tomasi detector

Detected feature points were visualized using marker overlays.

---

### Mosaic / Stitching Pipeline

The implemented image mosaicing pipeline follows:

```text
Video
→ Corner Detection
→ Corner Matching
→ Estimate Geometric Transformation
→ Warp
→ Image Stitching
→ Video Viewer
```

The system performs:
- feature detection,
- feature matching,
- geometric transformation estimation,
- affine image warping,
- and image stitching.

---

### Robust Estimation

The project investigates robust geometric estimation techniques including:

- RANSAC (Random Sample Consensus)
- Least Median of Squares (LMedS)

These methods were used to eliminate incorrect feature correspondences and improve affine transformation stability.

---

### Legacy Simulink Migration

The original Simulink models relied on deprecated VIP Toolbox libraries:

```text
vipanalysis
vipgeotforms
viptextngfix
```

which are no longer supported in MATLAB R2024b.

The project therefore included:
- migration of legacy Simulink models,
- replacement of deprecated blocks,
- debugging dimensional mismatches,
- resolving variable-size signal issues,
- and reconstruction of the mosaic pipeline using modern Computer Vision Toolbox blocks.

---

### Numerical Stability Challenges

Several compatibility and numerical stability issues were encountered during implementation, including:

- singular affine transformation matrices,
- unstable feature correspondences,
- black warped outputs,
- transpose mismatches between:
  - \(2 \times M\)
  - and \(M \times 2\) feature representations,
- variable-size signal incompatibilities,
- and deprecated ROI processing.

Controlled affine transformation experiments were used to validate the Warp and Image Stitching subsystems.

---

### Topics Covered

- Affine Transformations
- Projective Geometry
- Corner Detection
- Feature Matching
- Image Warping
- Image Stitching
- Panoramic Mosaicing
- Robust Estimation
- RANSAC
- Geometric Computer Vision
- Numerical Optimization

---

## Technologies Used

- MATLAB
- Simulink
- Computer Vision Toolbox
- Image Processing Toolbox
- DSP System Toolbox

---

# Autoencoders & Variational Autoencoders — Exercise 5

---

## Overview

Exercise 5 focuses on dimensionality reduction, representation learning, and generative modeling using both classical machine learning and deep learning techniques.

The exercise explores linear and nonlinear latent-space representations of handwritten digit images from the MNIST dataset. Principal Component Analysis (PCA) and Kernel Principal Component Analysis (KPCA) are investigated as classical dimensionality reduction methods, while several Autoencoder architectures are implemented and compared in terms of reconstruction performance and latent-space representations.

The final part of the exercise introduces Variational Autoencoders (VAEs), which extend traditional Autoencoders by learning probabilistic latent representations that can be used for data generation and interpolation.

---

## Objectives

The main objectives of this laboratory exercise are:

- Understand dimensionality reduction using Principal Component Analysis (PCA)
- Explore nonlinear dimensionality reduction through Kernel PCA (KPCA)
- Implement image reconstruction using low-dimensional latent representations
- Study the relationship between PCA and Linear Autoencoders
- Implement and compare multiple Autoencoder architectures
- Analyze latent-space representations of handwritten digits
- Evaluate reconstruction quality using quantitative metrics
- Investigate weight-sharing and pseudo-inverse decoding techniques
- Understand probabilistic latent-variable models
- Implement Variational Autoencoders using the reparameterization trick
- Generate and interpolate handwritten digits in latent space
- Explore modern deep learning approaches for unsupervised representation learning

---

## Implemented Methods

The following methods were implemented and evaluated:

- Principal Component Analysis (PCA)
- Kernel Principal Component Analysis (KPCA)
- Linear Autoencoder
- Nonlinear Autoencoder
- Tied Weights Autoencoder
- Pseudo-Inverse Autoencoder
- Variational Autoencoder (VAE)

---

## Topics Covered

- Principal Component Analysis (PCA)
- Kernel PCA (KPCA)
- Dimensionality Reduction
- Autoencoders
- Linear Autoencoders
- Nonlinear Autoencoders
- Latent Space Learning
- Representation Learning
- Unsupervised Learning

---

## Technologies Used

- Python
- NumPy
- Pandas
- Matplotlib
- Scikit-Learn
- PyTorch
- MNIST Dataset

---

# Convolutional Neural Networks & Object Detection — Exercise 6

---

## Overview

Exercise 6 focuses on object detection using modern Convolutional Neural Networks (CNNs).

The exercise investigates state-of-the-art object detection architectures and their ability to simultaneously perform object classification and object localization. Pretrained object detectors from the PyTorch torchvision library are evaluated on the COCO2017 dataset and compared in terms of detection accuracy and computational performance.

The project explores region-based detection methods, object localization through bounding boxes, and the evaluation metrics commonly used in object detection systems.

---

## Objectives

The main objectives of this laboratory exercise are:

- Understand the fundamentals of object detection and object localization
- Study region-based object detection architectures
- Explore the evolution of R-CNN, Fast R-CNN, and Faster R-CNN detectors
- Understand the role of Region Proposal Networks (RPNs)
- Understand anchor boxes and object proposals
- Evaluate pretrained object detectors on the COCO2017 dataset
- Compute Precision, Recall, and F1-score metrics
- Compute Mean Average Precision (mAP)
- Generate Precision-Recall curves
- Measure inference time and detection efficiency
- Compare different object detection architectures

---

## Implemented Methods

The following object detection models were implemented and evaluated:

- Faster R-CNN
- Single Shot Detector (SSD)

Performance evaluation included:

- Precision
- Recall
- F1-score
- Mean Average Precision (mAP)
- Precision-Recall Curves
- Inference Time Analysis

---

## Topics Covered

- Convolutional Neural Networks (CNNs)
- Object Detection
- Object Localization
- Bounding Boxes
- Intersection over Union (IoU)
- Region Proposal Networks (RPN)
- Anchor Boxes
- Faster R-CNN
- SSD (Single Shot Detector)
- Precision
- Recall
- F1-score
- Mean Average Precision (mAP)
- Precision-Recall Curves
- Non-Maximum Suppression (NMS)
- COCO Dataset
- Deep Learning
- Computer Vision

---

## Technologies Used

- Python
- PyTorch
- Torchvision
- NumPy
- Matplotlib
- COCO2017 Dataset

---


