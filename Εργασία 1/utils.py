#  file contains utility functions like Gaussian kernel creation, upsampling, downsampling, and displaying pyramids.

import torch
import torch.nn.functional as F
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image

# normalize the image to keep pixel values in the range [0, 1]
def normalize_image(image):
    return (image - image.min()) / (image.max() - image.min())

'''
def gaussian_kernel(size, sigma, channels):
    # Create the 2D Gaussian kernel
    kernel = np.zeros((size, size), dtype=np.float32)
    center = size // 2
    
    # Fill the kernel with Gaussian values
    for i in range(size):
        for j in range(size):
            x, y = i - center, j - center
            kernel[i, j] = np.exp(-(x**2 + y**2) / (2 * sigma**2))
    
    # Normalize the kernel so that the sum is 1
    kernel /= kernel.sum()
    
    # Convert the kernel to a torch tensor and add batch and channel dimensions
    kernel_2d = torch.tensor(kernel, dtype=torch.float32).unsqueeze(0).unsqueeze(0)
    

    

    # Expand the kernel to match the number of channels
    kernel_2d = kernel_2d.expand(channels, 1, size, size)
    
    # Print the kernel sum and shape after expansion
    total_sum = kernel_2d.sum().item()
    print(f"Kernel sum after expansion (across all channels): {total_sum}")
    print("Kernel Shape:", kernel_2d.shape)
    
    kernel_2d = kernel_2d.clone()
    # Normalize across all channels (in case the sum of expanded kernel is > 1)
    kernel_2d /= kernel_2d.sum()  # Ensure the sum of all kernel values across all channels is 1
    
    # Print the kernel sum and shape after normalization
    total_sum_normalized = kernel_2d.sum().item()
    print(f"Kernel sum after final normalization: {total_sum_normalized}")
    print("Kernel Shape:", kernel_2d.shape)
    
    return kernel_2d
'''

# create gaussian kernel for image convolution
def gaussian_kernel(size, sigma, channel):
    kernel = np.zeros((size, size), dtype=np.float32)
    center = size // 2

    for i in range(size):
        for j in range(size):
            x, y = i - center, j - center
            kernel[i, j] = np.exp(-(x**2 + y**2) / (2 * sigma**2))

    kernel /= kernel.sum()
    kernel = torch.tensor(kernel, dtype=torch.float32).unsqueeze(0).unsqueeze(0)
    print(f"Kernel sum after expansion (across all channels): {kernel.sum().item()}")
    print("Kernel Shape:", kernel.shape)
    return kernel.expand(channel, 1, size, size)

'''
# create separable gaussian kernel
def gaussian_kernel(size, sigma, channels):
    # Generate the 1D Gaussian kernel
    grid = torch.arange(-(size // 2), size // 2 + 1, dtype=torch.float32)
    kernel_1d = torch.exp(-0.5 * (grid / sigma) ** 2)
    kernel_1d = kernel_1d / kernel_1d.sum()  # Normalize the 1D kernel to ensure sum is 1
    
    # Create 2D kernel by multiplying 1D kernel with its transpose
    kernel_2d = kernel_1d.unsqueeze(1) * kernel_1d.unsqueeze(0)
    
    # Expand the 2D kernel across the number of channels
    kernel_2d = kernel_2d.expand(channels, 1, size, size)
    
    # Check the sum of the kernel before final normalization
    total_sum = kernel_2d.sum().item()
    print(f"Kernel sum after expansion (across all channels): {total_sum}")
    print("Kernel Shape:", kernel_2d.shape)
    
    # Normalize the kernel again across all channels to ensure total sum is 1
    kernel_2d = kernel_2d / kernel_2d.sum()  # Normalize after expansion to make sure the sum is 1
    
    # Check the sum of the kernel after final normalization
    total_sum_normalized = kernel_2d.sum().item()
    print(f"Kernel sum after final normalization: {total_sum_normalized}")
    print("Kernel Shape:", kernel_2d.shape)
    
    return kernel_2d
'''
# upsample the image by a factor of 2
def upsample(image):
    return F.interpolate(image.unsqueeze(0), scale_factor=2, mode='bilinear', align_corners=False).squeeze(0)

# downsample the image by a factor of 2
def downsample(image):
    return F.interpolate(image.unsqueeze(0), scale_factor=0.5, mode='bilinear', align_corners=False).squeeze(0)

# apply gaussian filter to an image using a given kernel
def apply_gaussian(image, kernel):
    image = image.unsqueeze(0)
    blurred_image = F.conv2d(image, kernel, padding=kernel.size(2) // 2, groups=image.size(1))
    return blurred_image.squeeze(0)

# function to display gaussian or laplacian pyramid
def display_pyramid(pyramid, title):
    num_levels = len(pyramid)
    fig, axs = plt.subplots(1, num_levels, figsize=(num_levels * 3, 5))
    for level in range(num_levels):
        image = pyramid[level].permute(1, 2, 0).detach().numpy()
        image = normalize_image(image)
        axs[level].imshow(image)
        axs[level].set_title(f"Level {level}\nShape: {image.shape[1]}x{image.shape[0]}")
        axs[level].axis('off')
        axs[level].set_aspect(aspect=image.shape[1] / image.shape[0])  
    fig.suptitle(title)
    plt.show()

def visualize_frequency(pyramid):
    # check if the pyramid is a list of images
    if isinstance(pyramid, list):
        for idx, image in enumerate(pyramid):
            # convert tensor to numpy if needed
            if isinstance(image, torch.Tensor):
                image = image.numpy()
            elif isinstance(image, list):
                image = np.array(image)


            fig, axes = plt.subplots(1, 3, figsize=(15, 5))

            for i in range(3):
                    fft_result = np.fft.fftshift(np.fft.fft2(image[i]))  # apply FFT
                    magnitude_spectrum = np.abs(fft_result)  # get magnitude
                    log_magnitude = np.log(1 + magnitude_spectrum)  # log scale to avoid 0

                    # show the frequency components
                    axes[i].imshow(log_magnitude, cmap='gray')
                    axes[i].set_title(f'Channel {i+1}')
                    axes[i].axis('off')

            plt.tight_layout()
            plt.suptitle(f'Frequency Domain - Pyramid Level {idx}')
            plt.show()

    else:
        raise TypeError(f"Expected a list of images, but got: {type(pyramid)}")