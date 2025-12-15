%% IMAGE BLENDING: Woman + Hand using laplacian pyramids
close all; clear;


% Load images
I1 = im2double(imread('CV_1-PYRAMIDS/photos/woman.png'));
I2 = im2double(imread('CV_1-PYRAMIDS/photos/hand.png'));

% Resize I2 to match I1
I2 = imresize(I2, [size(I1,1), size(I1,2)]);


% Draw mask interactively

figure; imshow(I1); title('Draw mask for woman (freehand)');
h = drawfreehand('Color','r'); % region to keep from I1
mask = createMask(h);          % binary mask

% Smooth the mask for smooth blending
blur_kernel = fspecial('gaussian', [30 30], 25);
mask = imfilter(double(mask), blur_kernel, 'replicate');

% Complement mask for I2
mask2 = 1 - mask;

figure; imshow(mask); title('Gaussian blurred mask');

% Pyramid levels
levels = 5;


% Generate gaussian pyramid for mask

Gm = genPyr(mask, 'gauss', levels);

% -------------------------------
% 5. Generate Laplacian pyramids for images
% -------------------------------
LI1 = genPyr(I1, 'laplace', levels);
LI2 = genPyr(I2, 'laplace', levels);


% Blend pyramids
B = cell(1, levels);
for i = 1:levels
    % Resize Gaussian mask to match current laplacian level
    mask_resized = imresize(Gm{i}, [size(LI1{i},1), size(LI1{i},2)]);
    
    % Blend current level
    B{i} = mask_resized .* LI1{i} + (1 - mask_resized) .* LI2{i};
end

% Reconstruct blended image
I_blend = pyrReconstruct(B);



figure;
subplot(1,3,1); imshow(I1); title('Woman');
subplot(1,3,2); imshow(I2); title('Hand');
subplot(1,3,3); imshow(I_blend); title('Blended Image');

% Display each level of blended pyramid
figure;
for i = 1:levels
    subplot(1,levels,i);
    imshow(B{i}+0.5); 
    title(['Blended level ', num2str(i)]);
end
