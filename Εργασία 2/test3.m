% Optimized MATLAB Code for Rotating Windmill Video
addpath('CV_2-TRANSFORMATIONS/photos/');
addpath('transformations/');

% Read images
windmillBack = imread('windmill_back.jpeg');
windmill = imread('windmill.png');

mask = imread('windmill_mask.png');

% Prepare video writer
windmill = removeRedBackground(windmill);

% Preprocess mask
maskBinary = preprocessMask(mask);

% Check if the image has 4 channels (RGBA)
[~, ~, numChannels] = size(mask);

% Define video parameters
outputPath = 'rotating_windmill.avi';
videoWriter = VideoWriter(outputPath, 'Motion JPEG AVI');
open(videoWriter);

% Get image dimensions
[height, width, ~] = size(windmillBack);

% Define video parameters
outputPath = 'rotating_windmill.avi';
numFrames = 60; % Number of frames for the video
rotationStep = 360 / numFrames; % Degrees per frame
parameters.scaleFactor = 0.85;

% Define parameters for scaling the windmill
scaledWindmill = transformImage(windmill, 'scale', parameters, 0); 

displacement = [width * 0.515, height * 0.425]; 

% Loop to create video frames
for frame = 1:numFrames
    % Compute rotation angle
    parameters.angle = rotationStep * (frame - 1);
    
    % Rotate the windmill blades
    rotatedBlades = transformImage(scaledWindmill, 'rotate', parameters, 0);
    combinedImage = placeBladesOnBackground(rotatedBlades, windmillBack, displacement);
    blendedImage = blendImages(windmillBack, combinedImage, maskBinary);
 
    % Write frame to video
    writeVideo(videoWriter, blendedImage);
end 


%{
% Compute initial translation offsets
bladeCenterX = width * 0.5;
bladeCenterY = height * 0.5;

offsetX = 1.5;
offsetY = 0.0;
for frame = 1:numFrames
    % Compute rotation angle
    parameters.angle = rotationStep * (frame - 1);
    
    % Rotate windmill blades
    rotatedBlades = transformImage(scaledWindmill, 'rotate', parameters, 0);

    % Translate blades for centering
    parameters.translateX = bladeCenterX - size(rotatedBlades, 2) * 0.5 + offsetX;
    parameters.translateY = bladeCenterY - size(rotatedBlades, 1) * 0.5 + offsetY;
    translatedBlades = transformImage(rotatedBlades, 'translate', parameters, 0);

    % Translate the pre-scaled binary mask
 %   translatedMask = transformImage(scaledMask, 'translate', parameters, 0);

     % Place blades on the background using the displacement
    displacement = [bladeCenterX, bladeCenterY]; % Center position
    combinedImage = placeBladesOnBackground(translatedBlades, windmillBack, displacement);
    blendedImage = blendImages(combinedImage, translatedBlades, maskBinary);

    % Write frame to video
    writeVideo(videoWriter, blendedImage);

end
%}
% Close video writer
close(videoWriter);

disp('Video of rotating windmill blades created successfully!');


% --- Helper Functions ---

function imgNoRed = removeRedBackground(img)
    % Remove red background from an image
    redMask = (img(:, :, 1) > 200 & img(:, :, 2) < 50 & img(:, :, 3) < 50);
    imgNoRed = img .* uint8(~repmat(redMask, [1, 1, 3])); % Black out red areas
end


function combinedImg = blendImages(bg, blades, binMask3D)
    % Ensure all inputs have matching sizes
    if ~isequal(size(bg), size(blades))
        blades = imresize(blades, [size(bg, 1), size(bg, 2)]);
    end
    
    if ~isequal(size(bg), size(binMask3D))
        binMask3D = imresize(binMask3D, [size(bg, 1), size(bg, 2)]);
    end

    % Blend the images based on the mask
    combinedImg = bg .* uint8(~binMask3D) + blades .* uint8(binMask3D);
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


    rowStart = max(1, rowStart);
    colStart = max(1, colStart);

    combinedImage = background;
    combinedImage(rowStart:rowEnd, colStart:colEnd, :) = ...
        max(background(rowStart:rowEnd, colStart:colEnd, :), ...
            blades(1:(rowEnd-rowStart+1), 1:(colEnd-colStart+1), :));
end
