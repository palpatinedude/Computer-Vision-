#  Exercise 1 Computer Vision
#  author : Marianthi Thodi 1084576
#  Concept : Image Blending, Pyramids, Image Reconstruction, Filtering

#  FIRST STEP :
    # Import images and preprocess them in order to be ready for blending

#  SECOND STEP :
    # Create gaussian kernel(matrix  which smooths the image by averaging pixel values with a weighted sum that gives more importance to the central pixel) that is used for the convolution of the images.

#  THIRD STEP :
    # Create gaussian and laplacian pyramids for each image.

#  FOURTH STEP :
    # Blend the two images using the mask in order to create the final image.

#   FIFTH STEP : 
     # Create binary mask  in order to define which parts of each image should dominate in the final blend

import torch
import matplotlib.pyplot as plt
from PIL import Image
import torchvision.transforms as transforms
from pyramids import gaussian_pyramid, laplacian_pyramid
from blending import blend_images, reconstruct_image, create_mask
from utils import gaussian_kernel, normalize_image, display_pyramid, visualize_frequency

# first step: load and preprocess the images
img1 = Image.open('photos/apple.jpg')  
img2 = Image.open('photos/orange.jpg')  

# resize images to match sizes if they don't match
if img1.size != img2.size:
    img2 = img2.resize(img1.size)

# convert images to tensors
transform = transforms.ToTensor()
img1_tensor = transform(img1)
img2_tensor = transform(img2)

# display original images
plt.figure(figsize=(10,5))
plt.subplot(1, 2, 1)
plt.imshow(img1)
plt.title("Image 1")
plt.subplot(1, 2, 2)
plt.imshow(img2)
plt.title("Image 2")
plt.show()

# second step: define gaussian kernel for convolution
kernel_size = 5
sigma = 1.0
kernel = gaussian_kernel(kernel_size, sigma, img1_tensor.shape[0])

# third step: define gaussian and laplacian pyramids for each image
num_levels = 5
gaussian_pyramid1 = gaussian_pyramid(img1_tensor, kernel, num_levels)
gaussian_pyramid2 = gaussian_pyramid(img2_tensor, kernel, num_levels)
laplacian_pyramid1 = laplacian_pyramid(gaussian_pyramid1)
laplacian_pyramid2 = laplacian_pyramid(gaussian_pyramid2)

# display gaussian and laplacian pyramids
display_pyramid(gaussian_pyramid1, "Gaussian Pyramid for Image 1 (Apple)")
display_pyramid(gaussian_pyramid2, "Gaussian Pyramid for Image 2 (Orange)")
display_pyramid(laplacian_pyramid1, "Laplacian Pyramid for Image 1 (Apple)")
display_pyramid(laplacian_pyramid2, "Laplacian Pyramid for Image 2 (Orange)")

# fourth step: define the mask and its pyramid
mask = create_mask(img1_tensor.shape)
mask_pyramid = gaussian_pyramid(mask, kernel, num_levels)

# display the mask
plt.figure(figsize=(5,5))
plt.imshow(mask[0].squeeze(), cmap='gray')
plt.title("Mask")
plt.show()

# fifth step: blend the two images using the mask to create the final image
blended_pyramid = blend_images(laplacian_pyramid1, laplacian_pyramid2, mask_pyramid)
final_image = reconstruct_image(blended_pyramid)

# display the final blended image
plt.imshow(final_image.permute(1, 2, 0).detach().numpy())
plt.title("Blended Image")
plt.show()

visualize_frequency(laplacian_pyramid1)