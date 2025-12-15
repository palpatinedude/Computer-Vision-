%% IMAGE BLENDING: Apple + Orange using Laplacian Pyramids

close all; clear;

% Read images and convert to double
I1 = im2double(imread('CV_1-PYRAMIDS/photos/apple.jpg'));  
I2 = im2double(imread('CV_1-PYRAMIDS/photos/orange.jpg')); 

% Resize I2 to match I1
I2 = imresize(I2, [size(I1,1), size(I1,2)]);  

% Create blending mask (left half = 1, right half = 0)
[rows, cols, ~] = size(I1);
mask = zeros(rows, cols);
mask(:,1:floor(cols/2)) = 1;   % Left half from apple
mask = double(mask);  

% Feathering for smooth transition
blur_kernel = fspecial('gaussian', [30 30], 25); 
mask = imfilter(mask, blur_kernel, 'replicate');  

% Complement mask (right side from orange)
mask2 = 1 - mask;


figure; imshow(mask); title('Mask');

% Set pyramid levels
levels = 5; 

% Generate Gaussian pyramid for mask
Gm = genPyr(mask, 'gauss', levels);


figure;
for i = 1:levels
    subplot(1,levels,i);
    imshow(Gm{i}, []);
    title(['Gm level ', num2str(i)]);
end



% Generate Laplacian pyramids for images
LI1 = genPyr(I1, 'laplace', levels);
LI2 = genPyr(I2, 'laplace', levels);


figure;
for i = 1:levels
    subplot(1,levels,i);
    imshow(LI1{i} + 0.5); 
    title(['LI1 level ', num2str(i)]);
end

figure;
for i = 1:levels
    subplot(1,levels,i);
    imshow(LI2{i} + 0.5); 
    title(['LI2 level ', num2str(i)]);
end

% Blend pyramids using Gaussian mask
B = cell(1, levels);
for i = 1:levels
    % Resize gaussian mask to current laplacian level
    mask_resized = imresize(Gm{i}, [size(LI1{i},1), size(LI1{i},2)]);
    
    % Blend current level: bj(n) = g_j(n)*l1_j(n) + (1-g_j(n))*l2_j(n)
    B{i} = mask_resized .* LI1{i} + (1 - mask_resized) .* LI2{i};
end

figure;
for i = 1:levels
    subplot(1,levels,i);
    imshow(B{i} + 0.5); 
    title(['Blended Pyramid Level ', num2str(i)]);
end

% Reconstruct blended image
I_blend = pyrReconstruct(B);


% Final comparison figure 
figure;
subplot(1,3,1); imshow(I1); title('Apple');
subplot(1,3,2); imshow(I2); title('Orange');
subplot(1,3,3); imshow(I_blend); title('Blended Image');