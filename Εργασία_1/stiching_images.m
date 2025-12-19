% IMAGE BLENDING: Woman + Hand using Laplacian Pyramids
close all; clear;

% Load images
I1 = im2double(imread('CV_1-PYRAMIDS/photos/woman.png'));
I2 = im2double(imread('CV_1-PYRAMIDS/photos/hand.png'));

% Resize I2 to match I1
I2 = imresize(I2, [size(I1,1), size(I1,2)]);

% Draw mask interactively 
figure; imshow(I1); title('Draw mask for the eye');
h = drawfreehand('Color','r');  % region to keep from I1
mask = createMask(h);            % binary mask

% Strict binary mask 
mask = double(mask);

% Pyramid levels
levels = 5;

% Generate gaussian pyramid for mask
Gm = genPyr(mask, 'gauss', levels);

% Generate laplacian pyramids for images
LI1 = genPyr(I1, 'laplace', levels);
LI2 = genPyr(I2, 'laplace', levels);

% Blend pyramids normally
B = cell(1, levels);
for i = 1:levels
    % Resize mask to current level using nearest neighbor to avoid smoothing
    mask_resized = imresize(Gm{i}, [size(LI1{i},1), size(LI1{i},2)]);
    
    % Normal pyramid blending
    B{i} = mask_resized .* LI1{i} + (1 - mask_resized) .* LI2{i};
end

% Reconstruct blended image
I_blend = pyrReconstruct(B);


% Resize I_blend to exactly match I1 
I_blend = imresize(I_blend, [size(I1,1), size(I1,2)]);

% Slight gaussian blur on mask to feather edges
blur_kernel = fspecial('gaussian', [10 10], 10);  
mask_smooth = imfilter(mask, blur_kernel, 'replicate');

% Resize mask to match image dimensions
mask_smooth = imresize(mask_smooth, [size(I1,1), size(I1,2)], 'nearest');

% Repeat mask for 3 color channels
mask_smooth_3c = repmat(mask_smooth, [1 1 size(I1,3)]);

% Blend eye region smoothly
I_blend = mask_smooth_3c .* I1 + (1 - mask_smooth_3c) .* I_blend;


figure;
subplot(1,3,1); imshow(I1); title('Woman');
subplot(1,3,2); imshow(I2); title('Hand');
subplot(1,3,3); imshow(I_blend); title('Blended Image');


figure;
for i = 1:levels
    subplot(1,levels,i);
    imshow(B{i} + 0.5); 
    title(['Blended level ', num2str(i)]);
end
