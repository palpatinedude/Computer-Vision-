
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
scaleFactor = 1.1;
parameters.scaleFactor = scaleFactor; % Store scaling factor in parameters structure
parameters.angle = 0; % Initialize the angle for rotation

% Scale windmill and mask once using transformImage
scaledWindmill = transformImage(windmill, 'scale', parameters, 0);
scaledMask = transformImage(maskBinary, 'scale', parameters, 0);

% Initial displacement (where the windmill is placed on the background)
displacement = [width * 0.55, height * 0.37]; 

% Rotation parameters
numFrames = 36; % Number of frames for the video
rotationStep = 360 / numFrames; % Degrees per frame

% Create frames for the video
for frame = 1:numFrames
    % Rotation angle for this frame
    parameters.angle = rotationStep * (frame - 1); % Update the rotation angle

    % Rotate windmill and mask using transformImage
    rotatedWindmill = transformImage(scaledWindmill, 'rotate', parameters, 0);
    rotatedWindmill = cropBlackBorders(rotatedWindmill);

    rotatedMask = transformImage(scaledMask, 'rotate', parameters, 0);
    rotatedMask = cropBlackBorders(rotatedMask);

    % Ensure mask matches blades in size
    [rowsB, colsB, ~] = size(rotatedWindmill);
    [rowsM, colsM, ~] = size(rotatedMask);
    if rowsB ~= rowsM || colsB ~= colsM
        rotatedMask = imresize(rotatedMask, [rowsB, colsB]);
    end

    % Blend windmill with background using the rotated mask
    blendedImage = blendImages(windmillBack, rotatedWindmill, rotatedMask, displacement);
    
    % Write the frame to the video
    writeVideo(videoWriter, blendedImage);
end

% Close video writer
close(videoWriter);
disp('Video of rotating windmill blades created successfully!');

% --- Helper Functions ---

function croppedImage = cropBlackBorders(image)
    % Find the bounding box of non-black regions
    mask = any(image, 3); % Binary mask of non-zero pixels
    bbox = regionprops(mask, 'BoundingBox');
    
    % If a bounding box is found, crop the image
    if ~isempty(bbox)
        bbox = round(bbox(1).BoundingBox); % Get the bounding box
        croppedImage = imcrop(image, bbox); % Crop the image to the bounding box
    else
        croppedImage = image; % Return the original if no bounding box is found
    end
end

function imgNoRed = removeRedBackground(img)
    % Remove red background from an image
    redMask = (img(:, :, 1) > 200 & img(:, :, 2) < 50 & img(:, :, 3) < 50);
    imgNoRed = img .* uint8(~repmat(redMask, [1, 1, 3])); % Black out red areas
end

function binImg3D = preprocessMask(mask)
    % Convert mask to binary and expand to 3 channels
    grayImg = rgb2gray(mask); % Automatically handles RGB or grayscale
    binImg = imbinarize(grayImg); % Convert to binary (logical: 0 or 1)
    
    % Expand binary mask to 3 channels
    binImg3D = repmat(binImg, [1, 1, 3]); % Expand binary mask to 3 channels
end

function combinedImg = blendImages(bg, blades, mask, displacement)
    % Get dimensions of inputs
    [rowsB, colsB, ~] = size(blades);
    [rowsBG, colsBG, ~] = size(bg);

    % Compute start and end indices for placement
    rowStart = round(displacement(2) - rowsB / 2);
    colStart = round(displacement(1) - colsB / 2);

    % Ensure indices are within bounds
    rowStart = max(1, rowStart);
    colStart = max(1, colStart);
    rowEnd = min(rowsBG, rowStart + rowsB - 1);
    colEnd = min(colsBG, colStart + colsB - 1);

    % Adjust dimensions to match valid placement area
    rowsValid = rowEnd - rowStart + 1;
    colsValid = colEnd - colStart + 1;
    bladeRegion = blades(1:rowsValid, 1:colsValid, :);
    maskRegion = mask(1:rowsValid, 1:colsValid);

    % Convert mask to logical for precision
    maskRegion = logical(maskRegion);

    % Initialize combined image as a copy of the background
    combinedImg = bg;

    % Perform pixel-wise blending
    for c = 1:3  % Loop over color channels
        combinedImg(rowStart:rowEnd, colStart:colEnd, c) = ...
            maskRegion .* bladeRegion(:, :, c) + ...
            ~maskRegion .* combinedImg(rowStart:rowEnd, colStart:colEnd, c);
    end
end
