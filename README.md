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
- Use masking techniques for realistic image composition

---

## Exercise Structure

### Function Familiarization

The exercise begins with an introduction to fundamental image processing
functions used for reading images, applying geometric transformations,
controlling spatial references, and visualizing image sequences.

---

### Image Scaling Composition

Multiple scaled versions of the same image are generated using different scaling
factors. These scaled images are combined into a single composite image in order
to demonstrate the effect of scaling transformations.

---

### Periodic Shearing Transformation

A periodic image sequence is created by applying horizontal shearing
transformations. The shearing parameter varies smoothly over time, producing a
continuous animation effect.

---

### Fixed-Base Horizontal Shearing

Horizontal shearing is applied while ensuring that the base of the image remains
fixed. A periodic rule is used to control the variation of the shearing
parameter, resulting in stable and realistic motion.

---

### Image Animation with Masking

An animated sequence is produced using rotation, scaling, and translation
transformations. Masking techniques are applied to isolate specific regions of
the image, allowing for natural image composition.

---

### Interpolation Method Comparison

The same transformations are repeated using different interpolation methods,
such as nearest neighbor, linear, and cubic interpolation. The visual quality
and smoothness of each method are evaluated and compared.

---

### Object Motion and Depth Simulation

A final animation is created in which an object moves across a background
following a modified trajectory. Gradual scaling is applied to simulate depth,
giving the impression that the object moves toward the horizon and eventually
disappears.

---

## Conclusion

Exercise 2 provides a structured and practical introduction to geometric
transformations in image processing. Through the use of affine transformations,
interpolation techniques, and masking, dynamic and realistic animations are
created from static images.
