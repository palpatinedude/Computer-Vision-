# file for creating gaussian and laplacian pyramids

import torch
import torch.nn.functional as F
from utils import downsample, upsample, apply_gaussian

# create gaussian pyramid for an image
def gaussian_pyramid(image, kernel, num_levels):
    pyramid = [image]
    for level in range(1, num_levels):
        blurred_image = apply_gaussian(pyramid[level - 1], kernel)
        downsampled_image = downsample(blurred_image)
        downsampled_image = torch.clamp(downsampled_image, min=0, max=1) 
        pyramid.append(downsampled_image)
    return pyramid

# create laplacian pyramid from gaussian pyramid
def laplacian_pyramid(gaussian_pyramid):
    laplacian_pyramid = []
    num_levels = len(gaussian_pyramid)
    
    for i in range(num_levels - 1):
        upsampled_image = upsample(gaussian_pyramid[i + 1])
        diff_height = gaussian_pyramid[i].shape[1] - upsampled_image.shape[1]
        diff_width = gaussian_pyramid[i].shape[2] - upsampled_image.shape[2]
        
        upsampled_image_padded = F.pad(upsampled_image, 
                                       (diff_width // 2, (diff_width + 1) // 2, 
                                        diff_height // 2, (diff_height + 1) // 2), 
                                       mode='replicate')
        laplacian = gaussian_pyramid[i] - upsampled_image_padded
        laplacian_pyramid.append(laplacian)
    
    laplacian_pyramid.append(gaussian_pyramid[-1])
    return laplacian_pyramid
