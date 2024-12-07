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
% Scaling and translation parameters (applied once)
parameters.scaleFactor = 0.65; % Store scaling factor in parameters structure
parameters.angle = 0; % Initialize the angle for rotation

% Scale windmill and mask once using transformImage
scaledWindmill = transformImage(windmill, 'scale', parameters, 0);

% Initial displacement (where the windmill is placed on the background)
displacement = [width * 0.50, height * 0.39]; 

% Rotation parameters
numFrames = 80; % Number of frames for the video
rotationStep = 360 / numFrames; % Degrees per frame

for frame = 1:numFrames
    % Rotation angle for this frame
    parameters.angle = rotationStep * (frame - 1); % Update the rotation angle

    % rotatedWindmill = transformImage(scaledWindmill, 'rotate', parameters, 0);
    padding = 100;  % Amount of padding around the image
    paddedWindmill = padarray(scaledWindmill, [padding, padding], 'both', 'post');  % Add padding to windmill image
 
    % Rotate the padded windmill image
     rotatedWindmill = imrotate(paddedWindmill, parameters.angle, 'bilinear', 'crop');
    rotatedMask = transformImage(maskBinary, 'rotate', parameters, 0);

    % Ensure the rotated mask matches the size of the rotated windmill
    [windmillHeight, windmillWidth, ~] = size(rotatedWindmill);
    [maskHeight, maskWidth, ~] = size(rotatedMask);

    if windmillHeight ~= maskHeight || windmillWidth ~= maskWidth
        rotatedMask = imresize(rotatedMask, [windmillHeight, windmillWidth]);
    end

     % Expand the background canvas to fit the rotated windmill
    % Get the dimensions of the rotated windmill
    [rotatedHeight, rotatedWidth, ~] = size(rotatedWindmill);
    
    % Define the padding needed to fit the rotated windmill
    paddingHeight = max(0, rotatedHeight - height);
    paddingWidth = max(0, rotatedWidth - width);


    % Expand the background canvas if necessary
    if paddingHeight > 0 || paddingWidth > 0
      windmillBack = padarray(windmillBack, [paddingHeight, paddingWidth], 255, 'both');
    end

    % Create alpha channel for transparency
    alphaChannel = any(rotatedWindmill > 0, 3); % Non-black pixels are opaque
    alphaChannel = im2double(alphaChannel);    % Convert to double for blending

    % Blend windmill with background using the alpha channel
  %  blendedImage = blendWithTransparency(windmillBack, rotatedWindmill, alphaChannel, displacement);
 blendedImage = blendWithTransparency(windmillBack, rotatedWindmill, alphaChannel, displacement);

    % Write the frame to the video
    writeVideo(videoWriter, blendedImage);
end


% Close video writer
close(videoWriter);
disp('Video of rotating windmill blades created successfully!');

% --- Helper Functions ---
%{
function croppedImage = cropBlackBorders(image)
    % Convert to grayscale if the image is RGB
    if size(image, 3) == 3
        grayImage = rgb2gray(image);
    else
        grayImage = image;
    end

    % Create a binary mask of non-black pixels
    mask = grayImage > 0;

    % Find the coordinates of non-black pixels
    [rows, cols] = find(mask);

    % If non-black pixels are found, crop the image
    if ~isempty(rows)
        rowMin = min(rows);
        rowMax = max(rows);
        colMin = min(cols);
        colMax = max(cols);

        % Crop the image
        croppedImage = image(rowMin:rowMax, colMin:colMax, :);
    else
        % Return the original image if no non-black pixels are found
        croppedImage = image;
    end
end
%}
%{
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
%}
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

%{
function combinedImg = blendWithTransparency(bg, fg, alpha, displacement)
    % Extract dimensions of the foreground and background
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

    % Perform alpha blending
    combinedImg = bg;
    for c = 1:3
        combinedImg(rowStart:rowEnd, colStart:colEnd, c) = ...
            (1 - alphaRegion) .* bgRegion(:, :, c) + ...
            alphaRegion .* fgRegion(:, :, c);
    end
    combinedImg = uint8(combinedImg); % Convert back to uint8
end

%}
function combinedImg = blendWithTransparency(bg, fg, alpha, displacement)
    % Extract dimensions of the foreground and background

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
%{
    % --- Debugging messages ---
    disp('--- Debugging blendWithTransparency ---');
    disp(['Foreground size: ', num2str(fgHeight), 'x', num2str(fgWidth), ', Class: ', class(fg)]);
    disp(['Background size: ', num2str(bgHeight), 'x', num2str(bgWidth), ', Class: ', class(bg)]);
    disp(['Blending region size: ', num2str(size(bgRegion, 1)), 'x', num2str(size(bgRegion, 2)), ', Class: ', class(bgRegion)]);
    disp(['Alpha region size: ', num2str(size(alphaRegion, 1)), 'x', num2str(size(alphaRegion, 2)), ', Class: ', class(alphaRegion)]);
%}
%{
    % Display the regions for debugging
    figure; imshow(bgRegion); title('Background Region');
    figure; imshow(fgRegion); title('Foreground Region');
    figure; imshow(alphaRegion); title('Alpha Region');
%}
    alphaRegion = uint8(alphaRegion);
    % Perform alpha blending
    combinedImg = bg; % Initialize combined image
    for c = 1:3
        combinedImg(rowStart:rowEnd, colStart:colEnd, c) = ...
            (1 - alphaRegion) .* bgRegion(:, :, c) + ...
            alphaRegion .* fgRegion(:, :, c);
    end

    % Display the combined image region for debugging
  %  figure; imshow(combinedImg(rowStart:rowEnd, colStart:colEnd, :));
   % title('Blended Region');

    %disp(['Combined image size: ', num2str(size(combinedImg, 1)), 'x', num2str(size(combinedImg, 2)), ', Class: ', class(combinedImg)]);

    %combinedImg = uint8(combinedImg); % Convert back to uint8
end


%{
function combinedImg = blendImages(bg, blades, mask, displacement)
    [rowsB, colsB, ~] = size(blades);
    [rowsBG, colsBG, ~] = size(bg);
    
    % Compute placement on the background
    rowStart = round(displacement(2) - rowsB / 2);
    colStart = round(displacement(1) - colsB / 2);
    
    % Ensure the region stays within background bounds
    rowStart = max(rowStart, 1);
    colStart = max(colStart, 1);
    rowEnd = min(rowStart + rowsB - 1, rowsBG);
    colEnd = min(colStart + colsB - 1, colsBG);

    % Extract regions for blending
    bgRegion = bg(rowStart:rowEnd, colStart:colEnd, :);
    bladeRegion = blades(1:(rowEnd-rowStart+1), 1:(colEnd-colStart+1), :);
    maskRegion = mask(1:(rowEnd-rowStart+1), 1:(colEnd-colStart+1), :);

   % Convert the maskRegion to double for arithmetic operations
    maskRegion = double(maskRegion);  % Convert logical to double

    % Ensure the bladeRegion and bgRegion are of type double for blending
    bladeRegion = double(bladeRegion);
    bgRegion = double(bgRegion);
%{    
   figure;
   imshow(bladeRegion);
   title('blade region');
   figure;
   imshow(bgRegion);
   title(' background region');
   figure;
   imshow(maskRegion(:,:,1));
   title(' mask region');

   disp(size(bladeRegion));
   disp(size(bgRegion));
   disp(size(maskRegion));
   disp(class(bgRegion));
   disp(class(bladeRegion));
   disp(class(maskRegion));
%}
    % Blend the images
    combinedImg = bg;
    for c = 1:3
        combinedImg(rowStart:rowEnd, colStart:colEnd, c) = ...
           ( 1 - maskRegion(:, :, c)) .* bladeRegion(:, :, c) + ...
            (maskRegion(:, :, c)) .* bgRegion(:, :, c);
    end
    combinedImg = uint8(combinedImg);  % Convert back to uint8
end
%}