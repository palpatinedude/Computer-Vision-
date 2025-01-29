originalVideoPath = 'CV_2-TRANSFORMATIONS/photos/pudding.avi';
createdVideoPath = 'CV_2-TRANSFORMATIONS/photos/sheared_pudding.avi';

comparePuddingRegions(originalVideoPath, createdVideoPath);

function comparePuddingRegions(originalVideoPath, createdVideoPath)
    % Read the first frame of the original video
    originalVideo = VideoReader(originalVideoPath);
    originalFrame = read(originalVideo, 1);  % Read the first frame

    % Read the first frame of the created video (sheared)
    createdVideo = VideoReader(createdVideoPath);
    createdFrame = read(createdVideo, 1);   % Read the first frame
    
    % Identify pudding region in the original frame
    [boundingBoxOriginal, croppedPuddingOriginal, puddingMaskOriginal] = identifyPuddingRegion(originalFrame);
    
    % Identify pudding region in the created (sheared) frame
    [boundingBoxCreated, croppedPuddingCreated, puddingMaskCreated] = identifyPuddingRegion(createdFrame);

    % Display the sizes before and after scaling
    fprintf('Size of cropped pudding region in original video: [%d, %d]\n', size(croppedPuddingOriginal, 1), size(croppedPuddingOriginal, 2));
    fprintf('Size of cropped pudding region in created (sheared) video: [%d, %d]\n', size(croppedPuddingCreated, 1), size(croppedPuddingCreated, 2));

    % Scale the cropped pudding region from the created frame to match the size of the original pudding region
    scaledPuddingCreated = scalePuddingRegion(croppedPuddingCreated, boundingBoxOriginal);

    % Display the size after scaling
    fprintf('Size of scaled pudding region after resizing: [%d, %d]\n', size(scaledPuddingCreated, 1), size(scaledPuddingCreated, 2));

    % Insert the scaled pudding region back into the created frame (without replacing other parts)
    processedFrame = overlayScaledPuddingInFrame(createdFrame, scaledPuddingCreated, boundingBoxOriginal);

    % Display the frames
    figure;
    imshow(originalFrame);
    title('Original Frame');

    figure;
    imshow(createdFrame);
    title('Created Frame');

    % Display the full processed frame with the scaled pudding region
    figure;
    imshow(processedFrame);
    title('Processed Frame - Scaled Pudding Region');
end

function scaledPudding = scalePuddingRegion(croppedPuddingCreated, boundingBoxOriginal)
    % Directly use the size of the original cropped pudding to resize
    targetHeight = round(boundingBoxOriginal(4));
    targetWidth = round(boundingBoxOriginal(3));
    
    % Resize the cropped pudding region from the created frame to exactly match the size of the original
    scaledPudding = imresize(croppedPuddingCreated, [targetHeight+1, targetWidth+1]);
end

% Function to identify pudding region in a frame
function [boundingBox, croppedPudding, puddingMask] = identifyPuddingRegion(image)
    % Convert the image to grayscale
    grayImage = rgb2gray(image);

    % Create a binary mask where the pudding is non-white (dark) and background is white
    binaryMask = grayImage < 240;  % Threshold to find darker regions (non-white areas)

    % Clean up the binary mask
    binaryMask = imfill(binaryMask, 'holes'); % Fill holes in the mask
    binaryMask = bwareafilt(binaryMask, 1);  % Keep the largest connected component (the pudding)

    % Get the bounding box of the pudding region
    props = regionprops(binaryMask, 'BoundingBox');
    boundingBox = props.BoundingBox;

    % Crop the pudding region using the bounding box
    x = floor(boundingBox(1));
    y = floor(boundingBox(2));
    w = floor(boundingBox(3));
    h = floor(boundingBox(4));

    % Ensure that the bounding box stays within the image bounds
    [imgHeight, imgWidth, ~] = size(image);
    
    % Clamp x, y to be at least 1
    x = max(x, 1);
    y = max(y, 1);
    
    % Ensure the bounding box doesn't exceed the image dimensions
    w = min(w, imgWidth - x + 1);
    h = min(h, imgHeight - y + 1);

    % Crop the pudding region from the image
    croppedPudding = imcrop(image, [x, y, w, h]);

    % Create a mask for the pudding region inside the bounding box
    puddingMask = binaryMask(y:y+h-1, x:x+w-1);  % Extract the mask for the region of interest
end

function processedFrame = overlayScaledPuddingInFrame(frame, scaledPudding, boundingBoxOriginal)
    % Extract the position and size from the bounding box (original frame)
    x = floor(boundingBoxOriginal(1));
    y = floor(boundingBoxOriginal(2));
    w = floor(boundingBoxOriginal(3));
    h = floor(boundingBoxOriginal(4));
    
    % Ensure the region fits within the bounds of the frame
    [frameHeight, frameWidth, ~] = size(frame);
    x_end = min(x + w - 1, frameWidth);
    y_end = min(y + h - 1, frameHeight);

    % Copy the frame to process
    processedFrame = frame;  % Make a copy of the frame

    
    % Ensure scaled pudding region has 3 channels
    if size(scaledPudding, 3) == 1
        scaledPudding = repmat(scaledPudding, [1, 1, 3]);  % Convert grayscale to RGB
    end
    
    % Clear the region where the original pudding was located (this ensures the unscaled pudding is removed)
    processedFrame(y:y_end, x:x_end, :) = 255;  % Set to white (RGB = [255, 255, 255])


   [scaledHeight, scaledWidth, ~] = size(scaledPudding);
    % Directly overlay the scaled pudding region onto the original region in the frame
    processedFrame(y:y+scaledHeight-1, x:x+scaledWidth-1, :) = scaledPudding(1:scaledHeight, 1:scaledWidth, :);
end
