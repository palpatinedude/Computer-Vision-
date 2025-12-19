%% Horizontal Shearing Animation of pudding.png
clear; close all; 

addpath('transformations');  

I = imread('CV_2-TRANSFORMATIONS/pudding.png');

% Parameters
numFrames = 20;        % number of frames in the animation
shearMax = 0.3;        % maximum horizontal shear
[H, W, C] = size(I);

% Preallocate video frames array
videoFrames = zeros(H, W, C, numFrames, 'like', I);

% Create shearing animation sequence
for k = 1:numFrames
    % Compute periodic horizontal shear 
    shearX = shearMax * sin(2*pi*k/numFrames);
    params.shearX = shearX;
    params.shearY = 0;  % horizontal only

    % Apply shear
    videoFrames(:, :, :, k) = shearImage(I, params);
end

implay(videoFrames);

% Save video to file
v = VideoWriter('sheared_pudding.avi');
open(v);
writeVideo(v, videoFrames);
close(v);


