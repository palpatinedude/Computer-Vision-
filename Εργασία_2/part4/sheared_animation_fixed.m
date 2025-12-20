%% Horizontal shearing with fixed base

clear; close all; clc;


addpath('../transformations');  

I = imread('../CV_2-TRANSFORMATIONS/pudding.png');
[H, W, C] = size(I);  % Get height, width, and number of channels

% Parameters for animation
numFrames = 20;       % Number of frames in the animation
shearMax = 0.3;       % Maximum horizontal shear
videoFrames = zeros(H, W, C, numFrames, 'like', I);  % Preallocate video frames

% Create animation with fixed base
for k = 1:numFrames
    % Compute horizontal shear for current frame 
    shearX = shearMax * sin(2*pi*k/numFrames);
    params.shearX = shearX;
    params.shearY = 0; % Only horizontal shear
    
    % Apply horizontal shear to the image
    shearedImage = shearImage(I, params);
    
    % Compute translation to keep the bottom row fixed
    params.translateX = -shearX * (H - 1); % Shift horizontally to fix the base
    params.translateY = 0;                  % No vertical translation
    
    % Apply translation to the sheared image
    fixedBaseImage = translateImage(shearedImage, params);
    
    % Crop or resize to original size
    R = imref2d([H W]);
    videoFrames(:, :, :, k) = imwarp(fixedBaseImage, affine2d(eye(3)), 'OutputView', R);
end


implay(videoFrames);

v = VideoWriter('sheared_pudding_fixed.avi');
open(v);
writeVideo(v, videoFrames);
close(v);

