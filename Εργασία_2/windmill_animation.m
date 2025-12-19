%% Windmill animation with mask with fixed base 
clear; close all;

addpath('transformations'); 

% Load images
bg = imread('CV_2-TRANSFORMATIONS/windmill_back.jpeg');   % background
blades = imread('CV_2-TRANSFORMATIONS/windmill.png');     % windmill blades
mask = imread('CV_2-TRANSFORMATIONS/windmill_mask.png');  % mask of blades (black = blades, white = background)

[H_bg, W_bg, ~] = size(bg);
[H_b, W_b, ~] = size(blades);

% Parameters
numFrames = 60;    % total number of frames in animation               
rotationPerFrame = 360/numFrames;  % degrees to rotate per frame
videoFrames = zeros(H_bg, W_bg, 3, numFrames, 'uint8'); % initialize video array

% Position to place windmill (bottom center fixed)
posX = round(W_bg/2 - W_b/2) + 17;
posY = round(H_bg/2 - H_b/2) - 27; 

% Extract background patch where blades will be placed
bgPatch = bg(posY+1 : posY+H_b, posX+1 : posX+W_b, :);

% Create animation
for k = 1:numFrames
    angle = rotationPerFrame * (k-1);

    % Rotate blades and mask
    % 'nearest' interpolation: takes nearest pixel value, avoids dark edges from averaging
    % 'crop': keeps the rotated image the same size as original blades
    rotatedBlades = imrotate(blades, angle, 'nearest', 'crop');
    rotatedMask = imrotate(mask, angle, 'nearest', 'crop');

    % Replace black pixels in rotated blades with background to remove black edges
    blackPixels = all(rotatedBlades == 0, 3);  % pixels that are completely black
    for c = 1:3
        rotatedBlades(:,:,c) = rotatedBlades(:,:,c) .* uint8(~blackPixels) + ...
                               bgPatch(:,:,c) .* uint8(blackPixels);
    end

    % Frame copy of background
    frame = bg;

    % Make sure ROI fits in background
    roiX = posX+1 : posX+W_b;
    roiY = posY+1 : posY+H_b;
    
    % Ensure ROI fits in background
    roiX = roiX(roiX <= W_bg);
    roiY = roiY(roiY <= H_bg);

    % Apply mask: only replace pixels where mask == 0 (blades)
    for c = 1:3
    tempBg = frame(roiY, roiX, c); % background patch in ROI
    tempMask = rotatedMask(1:length(roiY), 1:length(roiX)) == 0;  % black pixels = blades
    tempBladeSlice = rotatedBlades(1:length(roiY), 1:length(roiX), c); % blade patch
    tempBg(tempMask) = tempBladeSlice(tempMask);                      % insert blades
    frame(roiY, roiX, c) = tempBg;
    end

    % Save frame
    videoFrames(:,:,:,k) = frame;
end


implay(videoFrames);

v = VideoWriter('transf_windmill_fixed_base.avi');
open(v);
writeVideo(v, videoFrames);
close(v);

