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

% Preprocess images (remove red background and convert mask to binary)
windmill = removeRedBackground(windmill);  % Remove red background
maskBinary = preprocessMask(mask);         % Convert mask to binary

% Get image dimensions
[height, width, ~] = size(windmillBack);

parameters = struct();
parameters.scaleFactor = 0.65; % Store scaling factor in parameters structure
parameters.angle = 0; % Initialize the angle for rotation

% Scale windmill once using transformImage
scaledWindmill = transformImage(windmill, 'scale', parameters, 0);

% Initial displacement (where the windmill is placed on the background)
displacement = [width * 0.5135, height * 0.41];

% Rotation parameters
numFrames = 80; % Number of frames for the video
rotationStep = 360 / numFrames; % Degrees per frame

for frame = 1:numFrames
    % Rotation angle for this frame
    parameters.angle = rotationStep * (frame - 1); % Update the rotation angle
    
    % Scale the windmill and rotate it around its center
    [windmillHeight, windmillWidth, ~] = size(scaledWindmill);
    centerX = windmillWidth / 2;
    centerY = windmillHeight / 2;


    % Create a translation matrix to move the center of the windmill to the origin, apply the rotation, and then translate it back
    tform1 = affine2d([1 0 0; 0 1 0; -centerX -centerY 1]);  % Translate to origin
    tform2 = affine2d([1 0 0; 0 1 0; centerX centerY 1]);     % Translate back after rotation

    % Apply the transformations
    rotatedWindmill = imwarp(scaledWindmill, tform1);           % Move center to origin
    rotatedWindmill = imrotate(rotatedWindmill, parameters.angle, 'bilinear', 'crop'); % Rotate the image
    rotatedWindmill = imwarp(rotatedWindmill, tform2);          % Move it back to the original position

    % Create mask with the same transformations
    rotatedMask = transformImage(maskBinary, 'rotate', parameters, 0);

    % Ensure the mask and windmill are the same size
    [rotatedWindmillHeight, rotatedWindmillWidth, ~] = size(rotatedWindmill);
    [maskHeight, maskWidth, ~] = size(rotatedMask);
    
    if rotatedWindmillHeight ~= maskHeight || rotatedWindmillWidth ~= maskWidth
        rotatedMask = imresize(rotatedMask, [rotatedWindmillHeight, rotatedWindmillWidth]);
    end

    % Blend the rotated windmill with the background
    alphaChannel = any(rotatedWindmill > 0, 3); % Non-black pixels are opaque
    alphaChannel = im2double(alphaChannel);    % Convert to double for blending

    % Create the blended image
    blendedImage = blendWithTransparency(windmillBack, rotatedWindmill, alphaChannel, displacement);

    % Write the frame to the video
    writeVideo(videoWriter, blendedImage);
end

% Close video writer
close(videoWriter);
disp('Video of rotating windmill blades created successfully!');

% --- Helper Functions ---
function imgNoRed = removeRedBackground(img)
    % Ensure the image is in double precision for smooth operations
    img = im2double(img);  % Convert to double for consistency
    
    % Create a red mask where red color is dominant (in the RGB space)
    redMask = (img(:, :, 1) > 0.8 & img(:, :, 2) < 0.2 & img(:, :, 3) < 0.2);  % Threshold for red color

    % Convert the redMask to double (logical to double) for multiplication
    redMask = double(redMask);  

    % Apply the mask to black out the red regions
    imgNoRed = img .* repmat(1 - redMask, [1, 1, 3]);  % Multiply with inverted redMask
    
    % Convert back to uint8 for display or saving
    imgNoRed = im2uint8(imgNoRed); 
end

function binImg3D = preprocessMask(mask)
    % Convert mask to binary and expand to 3 channels
    grayImg = rgb2gray(mask); % Automatically handles RGB or grayscale
    binImg = imbinarize(grayImg); % Convert to binary (logical: 0 or 1)
    
    % Expand binary mask to 3 channels
    binImg3D = repmat(binImg, [1, 1, 3]); % Expand binary mask to 3 channels
end

function combinedImg = blendWithTransparency(bg, fg, alpha, displacement)
    % Apply Gaussian smoothing to alpha for smoother blending
    alpha = imgaussfilt(alpha, 5); 

    [fgHeight, fgWidth, ~] = size(fg);
    [bgHeight, bgWidth, ~] = size(bg);

    % Compute placement on the background
    rowStart = round(displacement(2) - fgHeight / 2);
    colStart = round(displacement(1) - fgWidth / 2);

    % Ensure the region stays within background bounds
    rowStart = max(rowStart, 1);
    colStart = max(colStart, 1);
    rowEnd = min(rowStart + fgHeight - 1, bgHeight);
    colEnd = min(colStart + fgWidth - 1, bgWidth);

    % Extract regions for blending
    bgRegion = bg(rowStart:rowEnd, colStart:colEnd, :);
    fgRegion = fg(1:(rowEnd-rowStart+1), 1:(colEnd-colStart+1), :);
    alphaRegion = alpha(1:(rowEnd-rowStart+1), 1:(colEnd-colStart+1));

    alphaRegion = uint8(alphaRegion);

    % Perform alpha blending
    combinedImg = bg; % Initialize combined image
    for c = 1:3
        combinedImg(rowStart:rowEnd, colStart:colEnd, c) = ...
            (1 - alphaRegion) .* bgRegion(:, :, c) + ...
            alphaRegion .* fgRegion(:, :, c);
    end
end

