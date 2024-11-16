# file contains functions for blending images using Laplacian pyramids and mask

import torch
import torch.nn.functional as F
from utils import normalize_image

# apply mask to the laplacian pyramids
def blend_images(laplacian_pyramid1, laplacian_pyramid2, mask_pyramid):
    blended_pyramid = []
    for lap1, lap2, mask in zip(laplacian_pyramid1, laplacian_pyramid2, mask_pyramid):
        blended_level = lap1 * mask + lap2 * (1 - mask)
        blended_pyramid.append(blended_level)
    return blended_pyramid

# reconstruct the image from the masked laplacian pyramids
'''
def reconstruct_image(blended_pyramid):
    reconstructed_image = blended_pyramid[-1]
    for lap in reversed(blended_pyramid[:-1]):
        upsampled_image = F.interpolate(reconstructed_image.unsqueeze(0), scale_factor=2, mode='bilinear', align_corners=False).squeeze(0)
        
        diff_height = lap.shape[1] - upsampled_image.shape[1]
        diff_width = lap.shape[2] - upsampled_image.shape[2]
        
        if diff_height > 0 or diff_width > 0:
            upsampled_image = F.pad(upsampled_image, 
                                    (diff_width // 2, (diff_width + 1) // 2, 
                                     diff_height // 2, (diff_height + 1) // 2), 
                                    mode='replicate')
        reconstructed_image = upsampled_image + lap
    return torch.clamp(reconstructed_image, 0, 1)
'''
def reconstruct_image(pyramid):
    image = pyramid[-1]
    for lap in reversed(pyramid[:-1]):
        upsampled = F.interpolate(image.unsqueeze(0), scale_factor=2, mode='bilinear', align_corners=False).squeeze(0)# upsample the image

        #  upsampled image and laplacian have the same shape  using padding
        if upsampled.shape != lap.shape:
            #  smaller tensor to match the size of the larger 
            pad_height = lap.shape[1] - upsampled.shape[1]
            pad_width = lap.shape[2] - upsampled.shape[2]
            upsampled = F.pad(upsampled, (0, pad_width, 0, pad_height))

       # add the upsampled image and the laplacian
        image = lap + upsampled
    
    return torch.clamp(image, 0, 1)


# create mask with the same height and width as the input images
def create_mask(image_shape):
    mask = torch.zeros(image_shape)  
    mid_col = image_shape[-1] // 2
    mask[:, :, :mid_col] = 1
    return mask