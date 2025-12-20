%% Image composition using scaling transformations

addpath('../transformations');
addpath('../uitilities/');

clear;
close all;

% Read input image
I = imread("../CV_2-TRANSFORMATIONS/ball.jpg");

% Define scaling factors
scaleFactors = [0.5, 0.75, 1.0, 1.25];

% Preallocate cell array for scaled images
scaledImages = cell(1, length(scaleFactors));

% Apply scaling using the scaleImage function
for i = 1:length(scaleFactors)
    params.scaleFactor = scaleFactors(i);
    scaledImages{i} = scaleImage(I, params);
end

% Create final composite canvas (2x2 layout)
[H, W, C] = size(I);
finalImage = zeros(2*H, 2*W, C, 'like', I);

% Place scaled images into the composite image
finalImage(1:H, 1:W, :) = scaledImages{1};          % top-left
finalImage(1:H, W+1:2*W, :) = scaledImages{2};      % top-right
finalImage(H+1:2*H, 1:W, :) = scaledImages{3};      % bottom-left
finalImage(H+1:2*H, W+1:2*W, :) = scaledImages{4};  % bottom-right

figure;
imshow(finalImage);
title('Composite Image with Multiple Scaled Versions');
