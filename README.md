– Exercise 2: Geometric Transformations
📖 Overview

Exercise 2 focuses on the use of geometric transformations in image processing and their application in creating animated image sequences. The exercise is implemented using MATLAB and aims to provide practical experience with image warping, affine transformations, masking, interpolation, and video generation.

🎯 Purpose of the Exercise

Understand and apply geometric transformations on digital images.

Use affine transformations such as scaling, rotation, translation, and shearing.

Create composite images and animated sequences.

Explore interpolation methods and their impact on image quality.

Gain hands-on experience with image composition using masks.

🧩 Exercise Components
1. Familiarization with MATLAB Functions

The exercise begins with an introduction to basic MATLAB image processing functions used for loading images, applying geometric transformations, defining spatial references, and visualizing image sequences.

2. Image Scaling Composition

Multiple scaled versions of the same image are generated using different scaling factors. These scaled images are then combined into a single composite image, demonstrating the effect of scaling transformations.

3. Periodic Shearing Transformation

A periodic image sequence is created by applying horizontal shearing transformations to an image. The shearing parameter varies over time, producing a smooth and continuous animation.

4. Fixed-Base Horizontal Shearing

Horizontal shearing is applied while keeping the base of the image fixed. A periodic rule is used to control the variation of the shearing value, ensuring realistic motion during the animation.

5. Image Animation with Masking

An animated sequence is produced using rotation, scaling, and translation transformations. Masking techniques are used to isolate specific image regions, allowing for natural image composition and realistic motion effects.

6. Interpolation Method Comparison

The same transformations are repeated using different interpolation methods, such as nearest neighbor, linear, and cubic interpolation. The visual quality and smoothness of each method are compared and evaluated.

7. Object Motion and Depth Simulation

A composite animation is created where an object moves across a background following a modified trajectory. The object gradually scales down to simulate depth, eventually disappearing toward the horizon.
