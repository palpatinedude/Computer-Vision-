%% Windmill animation with mask (fixed base) with different interpolations
clear; close all; clc;

addpath('transformations');

% Load images
bg = imread('CV_2-TRANSFORMATIONS/windmill_back.jpeg');
blades = imread('CV_2-TRANSFORMATIONS/windmill.png');
mask = imread('CV_2-TRANSFORMATIONS/windmill_mask.png');  % black = blades

[H_bg, W_bg, ~] = size(bg);
[H_b, W_b, ~] = size(blades);

% Animation parameters
numFrames = 60;
rotationPerFrame = 360/numFrames;

% Fixed position
posX = round(W_bg/2 - W_b/2) + 17;
posY = round(H_bg/2 - H_b/2) - 27;

% Extract background patch
bgPatch = bg(posY+1:posY+H_b, posX+1:posX+W_b, :);

% Interpolation methods to test
interpMethods = {'nearest', 'bilinear', 'bicubic'};

for m = 1:length(interpMethods)
    method = interpMethods{m};
    videoFrames = zeros(H_bg, W_bg, 3, numFrames, 'uint8');

    fprintf('Processing interpolation: %s\n', method);
    tic;
    for k = 1:numFrames
        angle = rotationPerFrame * (k-1);

        % Rotate blades
        rotatedBlades = imrotate(blades, angle, method, 'crop');
        rotatedMask   = imrotate(mask, angle, 'nearest', 'crop');  % mask always nearest

        % Replace fully black pixels with background to remove black edges
        blackPixels = all(rotatedBlades == 0, 3);
        for c = 1:3
            rotatedBlades(:,:,c) = rotatedBlades(:,:,c) .* uint8(~blackPixels) + ...
                                   bgPatch(:,:,c) .* uint8(blackPixels);
        end

        % Compose frame 
        frame = bg;
        roiX = posX+1 : posX+W_b;
        roiY = posY+1 : posY+H_b;

        roiX = roiX(roiX <= W_bg);
        roiY = roiY(roiY <= H_bg);

        for c = 1:3
            tempBg = frame(roiY, roiX, c);
            tempMask = rotatedMask(1:length(roiY), 1:length(roiX)) == 0; % black = blades
            tempBladeSlice = rotatedBlades(1:length(roiY), 1:length(roiX), c);
            tempBg(tempMask) = tempBladeSlice(tempMask);
            frame(roiY, roiX, c) = tempBg;
        end

        videoFrames(:,:,:,k) = frame;
    end

    elapsedTime = toc; 
    fprintf('Time for %s interpolation: %.2f seconds\n', method, elapsedTime);
    implay(videoFrames);

    outFile = sprintf('transf_windmill_fixed_base_%s.avi', method);
    v = VideoWriter(outFile);
    open(v);
    writeVideo(v, videoFrames);
    close(v);
    fprintf('Saved %s\n', outFile);
end
