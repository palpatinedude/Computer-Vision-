% Add paths for images and transformations
addpath('CV_2-TRANSFORMATIONS/photos/');
addpath('transformations/');

% Read images
windmillBack = imread('windmill_back.jpeg');
windmill = imread('windmill.png');
mask = imread('windmill_mask.png');

% Prepare video writer
outputPath = 'rotating_windmill.avi';
videoWriter = VideoWriter(outputPath, 'Motion JPEG AVI');
open(videoWriter);

% Preprocess images
windmill = removeRedBackground(windmill);
maskBinary = preprocessMask(mask);

% Get image dimensions
[height, width, ~] = size(windmillBack);

% Define video parameters
numFrames = 60; % Number of frames for the video
rotationStep = 360 / numFrames; % Degrees per frame
parameters.scaleFactor = 0.85;

% Scale the windmill
scaledWindmill = transformImage(windmill, 'scale', parameters, 0);
scaledMask = transformImage(maskBinary, 'scale', parameters, 0);

% Define initial displacement
displacement = [width * 0.515, height * 0.425];

% Adjust displacement to ensure blades fit within background
[maxBladeHeight, maxBladeWidth, ~] = size(scaledWindmill);
displacementX = max(maxBladeWidth / 2, min(displacement(1), width - maxBladeWidth / 2));
displacementY = max(maxBladeHeight / 2, min(displacement(2), height - maxBladeHeight / 2));
displacement = [displacementX, displacementY];

% Debug adjusted displacement
disp('--- Adjusted Displacement ---');
fprintf('Displacement X: %.2f, Displacement Y: %.2f\n', displacementX, displacementY);

% Main loop to create video frames
for frame = 1:numFrames
    % Compute rotation angle
    parameters.angle = rotationStep * (frame - 1);

    % Rotate windmill blades and mask
    rotatedBlades = transformImage(scaledWindmill, 'rotate', parameters, 0);
    rotatedMask = transformImage(scaledMask, 'rotate', parameters, 0);

    % Debug rotation parameters
    disp(['--- Frame ', num2str(frame), ' ---']);
    fprintf('Rotation Angle: %.2f degrees\n', parameters.angle);
    fprintf('Blade Dimensions After Rotation: %d x %d\n', size(rotatedBlades, 1), size(rotatedBlades, 2));
    fprintf('Mask Dimensions After Rotation: %d x %d\n', size(rotatedMask, 1), size(rotatedMask, 2));

    % Place the rotated blades on the background
    combinedImage = placeBladesOnBackground(rotatedBlades, windmillBack, displacement);

    % Blend the image using the transformed mask
    blendedImage = blendImagesLocal(windmillBack, combinedImage, rotatedMask, displacement);

    % Write frame to video
    writeVideo(videoWriter, blendedImage);
end

% Close video writer
close(videoWriter);

disp('Video of rotating windmill blades created successfully!');

% --- Helper Functions ---

function imgNoRed = removeRedBackground(img)
    % Remove red background from an image
    redMask = (img(:, :, 1) > 200 & img(:, :, 2) < 50 & img(:, :, 3) < 50);
    imgNoRed = img .* uint8(~repmat(redMask, [1, 1, 3])); % Black out red areas
end

function combinedImg = blendImagesLocal(bg, blades, mask, displacement)
    % Blend the transformed blades with the background using the mask

    % Get dimensions of inputs
    [rowsB, colsB, ~] = size(blades);
    [rowsM, colsM, ~] = size(mask); % Mask dimensions
    [rowsBG, colsBG, ~] = size(bg); % Background dimensions
    
    % Compute start and end indices for placement
    rowStart = round(displacement(2) - rowsB / 2);
    colStart = round(displacement(1) - colsB / 2);
    rowEnd = rowStart + rowsB - 1;
    colEnd = colStart + colsB - 1;

    % Debugging initial indices
    disp('--- Debugging Initial Indices ---');
    fprintf('rowStart: %d, rowEnd: %d\n', rowStart, rowEnd);
    fprintf('colStart: %d, colEnd: %d\n', colStart, colEnd);

    % Clip indices to the mask dimensions
    maskRowStart = max(1, rowStart);
    maskColStart = max(1, colStart);
    maskRowEnd = min(rowsM, rowEnd);
    maskColEnd = min(colsM, colEnd);

    % Adjust blade indices to match clipped mask region
    bladeRowStart = max(1, 1 - rowStart + 1);
    bladeColStart = max(1, 1 - colStart + 1);
    bladeRowEnd = bladeRowStart + (maskRowEnd - maskRowStart);
    bladeColEnd = bladeColStart + (maskColEnd - maskColStart);

    % Debugging clipped indices
    disp('--- Debugging Clipped Indices ---');
    fprintf('maskRowStart: %d, maskRowEnd: %d\n', maskRowStart, maskRowEnd);
    fprintf('maskColStart: %d, maskColEnd: %d\n', maskColStart, maskColEnd);
    fprintf('bladeRowStart: %d, bladeRowEnd: %d\n', bladeRowStart, bladeRowEnd);
    fprintf('bladeColStart: %d, bladeColEnd: %d\n', bladeColStart, bladeColEnd);

    % Crop blades and mask to fit within bounds
    bladesCropped = blades(bladeRowStart:bladeRowEnd, bladeColStart:bladeColEnd, :);
    maskCropped = mask(maskRowStart:maskRowEnd, maskColStart:maskColEnd, :);

    % Blend locally using the mask
    blendedImg = bg;
    blendedImg(maskRowStart:maskRowEnd, maskColStart:maskColEnd, :) = ...
        bg(maskRowStart:maskRowEnd, maskColStart:maskColEnd, :) .* uint8(~maskCropped) + ...
        bladesCropped .* uint8(maskCropped);

    disp('--- Debugging Blending Completed ---');
end

function [binImg3D] = preprocessMask(mask)
    % Convert mask to binary and expand to 3 channels
    grayImg = rgb2gray(mask); % Automatically handles RGB or grayscale
    binImg = imbinarize(grayImg); % Convert to binary (logical: 0 or 1)
    binImg3D = repmat(binImg, [1, 1, 3]); % Expand binary mask to 3 channels
end

function combinedImage = placeBladesOnBackground(blades, background, displacement)
    % Place blades onto the background with alignment
    [rowsB, colsB, ~] = size(background);
    [rowsT, colsT, ~] = size(blades);

    % Determine placement region
    rowStart = max(1, round(displacement(2) - rowsT / 2));
    colStart = max(1, round(displacement(1) - colsT / 2));
    rowEnd = min(rowsB, rowStart + rowsT - 1);
    colEnd = min(colsB, colStart + colsT - 1);

    combinedImage = background;
    combinedImage(rowStart:rowEnd, colStart:colEnd, :) = ...
        max(background(rowStart:rowEnd, colStart:colEnd, :), ...
            blades(1:(rowEnd-rowStart+1), 1:(colEnd-colStart+1), :));
end
