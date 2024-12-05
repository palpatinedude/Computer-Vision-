
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

% Scaling and translation parameters (applied once)
scaleFactor = 0.50;
parameters.scaleFactor = scaleFactor; % Store scaling factor in parameters structure
parameters.angle = 0; % Initialize the angle for rotation

% Scale windmill and mask once using transformImage
scaledWindmill = transformImage(windmill, 'scale', parameters, 0);
scaledMask = transformImage(maskBinary, 'scale', parameters, 0);
% Initial displacement (where the windmill is placed on the background)
displacement = [width * 0.475, height * 0.430]; 

% Rotation parameters
numFrames = 60; % Number of frames for the video
rotationStep = 360 / numFrames; % Degrees per frame

% Create frames for the video
for frame = 1:numFrames
    % Rotation angle for this frame
    parameters.angle = rotationStep * (frame - 1); % Update the rotation angle

    % Rotate windmill and mask using transformImage
    rotatedWindmill = transformImage(scaledWindmill, 'rotate', parameters, 0);
    rotatedMask = transformImage(scaledMask, 'rotate', parameters, 0);

    % Blend windmill with background using the rotated mask
    blendedImage = blendImages(windmillBack, rotatedWindmill, rotatedMask, displacement);
    
    % Write the frame to the video
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

function binImg3D = preprocessMask(mask)
    % Convert mask to binary and expand to 3 channels
    grayImg = rgb2gray(mask); % Automatically handles RGB or grayscale
    binImg = imbinarize(grayImg); % Convert to binary (logical: 0 or 1)
    binImg3D = repmat(binImg, [1, 1, 3]); % Expand binary mask to 3 channels
end

function combinedImg = blendImages(bg, blades, mask, displacement)
    % Get dimensions of inputs
    [rowsB, colsB, ~] = size(blades);  % Size of the blades image
    [rowsBG, colsBG, ~] = size(bg);    % Size of the background image
    
    % Compute start and end indices for placement based on displacement
    rowStart = round(displacement(2) - rowsB / 2);
    colStart = round(displacement(1) - colsB / 2);
    
    % Ensure indices are within the bounds of the background image
    rowEnd = min(rowsBG, rowStart + rowsB - 1);
    colEnd = min(colsBG, colStart + colsB - 1);
    
    % Adjust the row and column indices if they are out of bounds
    rowStart = max(1, rowStart);
    colStart = max(1, colStart);
    
    % Crop the mask and blades to fit within the region of the background
    maskCropped = mask(rowStart:rowEnd, colStart:colEnd, :);  % Crop mask to fit the background region
    bladesCropped = blades(rowStart:rowEnd, colStart:colEnd, :);  % Crop blades to fit the background region
  
       % Invert the mask to switch the background and blade regions
    maskInverted = ~maskCropped;  % Invert the mask
    
    % Now, blend the images using the inverted mask
    combinedImg = bg;  % Start with the background image
    
    % Apply the inverted mask:
    % Where the mask is black (inverted to white), place blades.
    % Where the mask is white (inverted to black), keep the background.
    combinedImg(rowStart:rowEnd, colStart:colEnd, :) = ...
        bg(rowStart:rowEnd, colStart:colEnd, :) .* uint8(maskInverted) + ...  % Place the blades where the mask is inverted to white
        bladesCropped .* uint8(~maskInverted);  % Place the background where the mask is inverted to black
    
end

%{
function combinedImg = blendImages(bg, blades, mask, displacement)
    % Get dimensions of inputs
    [rowsB, colsB, ~] = size(blades);  % Size of the blades image
    [rowsBG, colsBG, ~] = size(bg);    % Size of the background image
    
    % Compute start and end indices for placement based on displacement
    rowStart = round(displacement(2) - rowsB / 2);
    colStart = round(displacement(1) - colsB / 2);
    
    % Ensure indices are within the bounds of the background image
    rowEnd = min(rowsBG, rowStart + rowsB - 1);
    colEnd = min(colsBG, colStart + colsB - 1);
    
    % Adjust the row and column indices if they are out of bounds
    rowStart = max(1, rowStart);
    colStart = max(1, colStart);
    
    % Crop the mask and blades to fit within the region of the background
    maskCropped = mask(rowStart:rowEnd, colStart:colEnd, :);  % Crop mask to fit the background region
    bladesCropped = blades(rowStart:rowEnd, colStart:colEnd, :);  % Crop blades to fit the background region
  
    % Now, blend the images using the mask
    combinedImg = bg;  % Start with the background image
    combinedImg(rowStart:rowEnd, colStart:colEnd, :) = ...
        bg(rowStart:rowEnd, colStart:colEnd, :) .* uint8(maskCropped) + ...  % Place the background where the mask is black
        bladesCropped .* uint8(~maskCropped);  % Place the blades where the mask is white
end
%}