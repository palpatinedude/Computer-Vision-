#  Exercise 1 Computer Vision
#  author : Marianthi Thodi 1084576
#  Concept : Image Blending, Pyramids, Image Reconstruction


#  FIRST STEP :
    # Import images and preprocess them in order to be ready for blending

#  SECOND STEP :
    # Create gaussian kernel(matrix  which smooths the image by averaging pixel values with a weighted sum that gives more importance to the central pixel) that is used for the convolution of the images.

#  THIRD STEP :
    # Create gaussian and laplacian pyramids for each image.


#   FIFTH STEP : 
     # Create binary mask  in order to define which parts of each image should dominate in the final blend



import torch
import matplotlib.pyplot as plt
from PIL import Image
import torchvision.transforms as transforms
import torch.nn.functional as F
import numpy as np

# %%%%%%%%%%%%%%%%%%% FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%

# normalize the image cause the pixel values should be in the range [0, 1] because the convolution operation is sensitive to 
# #the input values cause it multiplies the pixel values with the kernel weights and sums them up in order to get the output pixel value
def normalize_image(image):
    return (image - image.min()) / (image.max() - image.min())

# upsample the image by a factor of 2
def upsample(image):
    upsampled_image = F.interpolate(image.unsqueeze(0), scale_factor=2, mode='bilinear', align_corners=False).squeeze(0)
    print(f"Upsampled image shape: {upsampled_image.shape}")
    return upsampled_image


# create Laplacian pyramid from gaussian pyramid
def laplacian_pyramid(gaussian_pyramid):
    laplacian_pyramid = []
    num_levels = len(gaussian_pyramid)
    
    for i in range(num_levels - 1):
        # Upsample the next level of the Gaussian pyramid
        upsampled_image = upsample(gaussian_pyramid[i + 1])
        
        # Ensure the sizes match before subtracting: crop the upsampled image if necessary
        diff_height = gaussian_pyramid[i].shape[1] - upsampled_image.shape[1]
        diff_width = gaussian_pyramid[i].shape[2] - upsampled_image.shape[2]
        
        # Pad the upsampled image with replicate mode to match the size
        upsampled_image_padded = F.pad(upsampled_image, 
                                       (diff_width // 2, (diff_width + 1) // 2, 
                                        diff_height // 2, (diff_height + 1) // 2), 
                                       mode='replicate')
        
        # Subtract the padded upsampled image from the current Gaussian pyramid level to get the Laplacian
        laplacian = gaussian_pyramid[i] - upsampled_image_padded
        laplacian_pyramid.append(laplacian)
    
    # Append the last level of the Gaussian pyramid to the Laplacian pyramid (no further processing needed)
    laplacian_pyramid.append(gaussian_pyramid[-1])
    
    return laplacian_pyramid

'''
# print each level of the gaussian pyramids for both images
def display_pyramid(pyramid, title):
 for level, img_tensor in enumerate(pyramid):
        img_array = img_tensor.permute(1, 2, 0).detach().numpy() #  tensor to numpy 
        
        img_pil = Image.fromarray((img_array * 255).astype('uint8'))  
        img_pil.show(title=f"Level {level} - Shape: {img_array.shape[1]}x{img_array.shape[0]}")
'''
'''
def display_pyramid(pyramid, title):
    num_levels = len(pyramid)
    
    # Dynamically adjust the height based on the number of levels
    fig, axs = plt.subplots(1, num_levels, figsize=(num_levels * 3, 5))  # Horizontal layout for easy comparison

    for level in range(num_levels):
        # Convert tensor to numpy array in (H, W, C) format for display
        image = pyramid[level].permute(1, 2, 0).detach().numpy()
        
        # Display each level in its subplot
        axs[level].imshow(image)
        axs[level].set_title(f"Level {level}\nShape: {image.shape[1]}x{image.shape[0]}")
        axs[level].axis('off')  # Hide axes for a cleaner look
        
        # Explicitly set aspect ratio based on image dimensions
        axs[level].set_aspect(aspect=image.shape[1] / image.shape[0])  

    fig.suptitle(title)
    plt.tight_layout()
    plt.show()
'''

# Function to display Gaussian or Laplacian pyramid
def display_pyramid(pyramid, title):
    num_levels = len(pyramid)
    
    # Dynamically adjust the size of the plot based on the number of levels
    fig, axs = plt.subplots(1, num_levels, figsize=(num_levels * 3, 5))  # Horizontal layout for easy comparison

    for level in range(num_levels):
        # Convert tensor to numpy array in (H, W, C) format for display
        image = pyramid[level].permute(1, 2, 0).detach().numpy()  # Convert to (height, width, channels)
        image = normalize_image(image)
        # Display each level in its subplot
        axs[level].imshow(image)
        axs[level].set_title(f"Level {level}\nShape: {image.shape[1]}x{image.shape[0]}")
        axs[level].axis('off')  # Hide axes for a cleaner look
        
        # Explicitly set aspect ratio based on image dimensions
        axs[level].set_aspect(aspect=image.shape[1] / image.shape[0])  # Make sure aspect ratio is correct

    fig.suptitle(title)
    plt.tight_layout()
    plt.show()


# create  gaussian pyramid for an image
def gaussian_pyramid(image, kernel, num_levels):
    pyramid = [image]  # original image 
    
    for level in range(1, num_levels):
        blurred_image = apply_gaussian(pyramid[level - 1], kernel)
        downsampled_image = downsample(blurred_image)
        downsampled_image = torch.clamp(downsampled_image, min=0, max=1) 
        pyramid.append(downsampled_image)
    

        print(f"Level {level} downsampled image shape: {downsampled_image.shape}")
    
    return pyramid


# downsample the image by a factor of 2
def downsample(image):
    downsampled_image = F.interpolate(image.unsqueeze(0), scale_factor=0.5, mode='bilinear', align_corners=False).squeeze(0)
    print(f"Downsampled image shape: {downsampled_image.shape}")  
    plt.imshow(downsampled_image.permute(1, 2, 0).detach().numpy())
    plt.show()  
    return downsampled_image


# apply gaussian filter to image using the gaussian kernel
def apply_gaussian(image, kernel):
    #  kernel ,image  should be 4D tensors
    image = image.unsqueeze(0)  # from 3D to 4D where 3D was (channels, height, width) then 4D is (batch, channels, height, width)
    blurred_image = F.conv2d(image, kernel, padding=kernel.size(2)//2, groups=image.size(1)) # 2D convolution need 4D input
    return blurred_image.squeeze(0)  # remove batch  cause we have only one image


def gaussian_kernel(size, sigma, channel):
    print("Kernel size:", size)
    print("Sigma:", sigma)
    print("Channel:", channel)

    # create a 2D gaussian kernel
    kernel = np.zeros((size, size), dtype=np.float32)
    center = size // 2

    for i in range(size):
        for j in range(size):
            x, y = i - center, j - center
            kernel[i, j] = np.exp(-(x**2 + y**2) / (2 * sigma**2))

    kernel /= kernel.sum()  # normalize the kernel so that the sum of weights equals 1

    # shape  kernel to a 4D tensor: (hannel, channel, height, width)
    kernel = torch.tensor(kernel, dtype=torch.float32)
    
    
    # The kernel should have the format (channel, hannel, height, width)
    kernel = kernel.unsqueeze(0).unsqueeze(0)  # (1, 1, size, size)
    kernel = kernel.expand(channel, 1, size, size)  #  increases the size of dimensions (without copying data)

      
 #   kernel = kernel.clone()

     # normalize the kernel again cause it was expanded that means the sum of the weights will be greater than 1 cause we have more weights
 #   kernel /= kernel.sum()  

   
 # Check the sum of the kernel across all channels (this will be > 1 initially)
    total_sum = kernel.sum().item()
    print(f"Kernel sum after expansion (across all channels): {total_sum}")
    print("Kernel Shape:", kernel.shape)
    
    # Normalize the kernel again after expansion to ensure the sum of all channels equals 1
    # kernel = kernel.clone()
    # kernel /= kernel.sum()  # Normalize across all channels to make sure the sum is 1

    # Check the normalized sum
    total_sum_normalized = kernel.sum().item()
    print(f"Kernel sum after final normalization: {total_sum_normalized}")
    print("Kernel Shape:", kernel.shape)


    return kernel




# create a mask with the same height and width as the input images
def create_mask(image_shape):
    mask = torch.zeros(image_shape)  
    mid_col = image_shape[-1] // 2  # middle column index
    mask[:, :, :mid_col] = 1   # set the left half to 1 
    print("Mask Shape:", mask.shape)
    return mask



# %%%%%%%%%%%%%%%%% MAIN %%%%%%%%%%%%%%%%%%%%%%%



#             Load and preprocess the images

#import the images as numpy arrays
img1 = Image.open('photos/apple.jpg')  
img2 = Image.open('photos/orange.jpg')  

# get the size (width, height)
width1, height1 = img1.size
width2, height2 = img2.size

# get number of channels (RGB or grayscale)
channel1 = len(img1.getbands())
channel2 = len(img2.getbands())   


print("Image 1 size: ", width1, height1)
print("Image 2 size: ", width2, height2)
print("Image 1 channels: ", channel1)
print("Image 2 channels: ", channel2)

# make sure images are  same size
if (width1, height1) != (width2, height2):
    img2 = img2.resize((width1, height1))  # if not resize the second image to the size of the first


# convert images to tensors
transform = transforms.ToTensor() # convert to numpy array and then to tensors
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


#             Define the gaussian kernel that will be used for convolution

kernel_size = 5  # 5X5 matrix
sigma = 1.0      # standard deviation 
kernel = gaussian_kernel(kernel_size, sigma,channel1)  # create the gaussian kernel


#             Define the gaussian and laplacian pyramid for each image


# create the gaussian pyramids
num_levels = 5  # Number of levels in the pyramid
gaussian_pyramid1 = gaussian_pyramid(img1_tensor, kernel, num_levels)
gaussian_pyramid2 = gaussian_pyramid(img2_tensor, kernel, num_levels)
laplacian_pyramid1 = laplacian_pyramid(gaussian_pyramid1)
laplacian_pyramid2 = laplacian_pyramid(gaussian_pyramid2)


# Display Gaussian pyramids for both images
display_pyramid(gaussian_pyramid1, "Gaussian Pyramid for Image 1 (Apple)")
display_pyramid(gaussian_pyramid2, "Gaussian Pyramid for Image 2 (Orange)")
display_pyramid(laplacian_pyramid1, "Laplacian Pyramid for Image 1 (Apple)")
display_pyramid(laplacian_pyramid2, "Laplacian Pyramid for Image 2 (Orange)")






#             Define the mask that will be used for blending

image_shape = img1_tensor.shape
print("Image Shape:", image_shape)
mask = create_mask(image_shape)

# display the mask
plt.figure(figsize=(5,5))
plt.imshow(mask[0].squeeze(), cmap='gray')
plt.title("Mask")
plt.show()
'''
plt.imshow(mask[0, :, :].squeeze(), cmap='gray')  # Display the mask's first channel
# Or if you want a combined mask visualization:
combined_mask = mask.sum(dim=0)  # Sum all channels, will show which pixels are selected in any channel
plt.imshow(combined_mask.squeeze(), cmap='gray')
plt.title("Combined Mask")
plt.show()
'''




