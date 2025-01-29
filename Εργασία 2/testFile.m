% Call the main function with the video paths
originalVideoPath = 'CV_2-TRANSFORMATIONS/photos/pudding.avi';
createdVideoPath = 'CV_2-TRANSFORMATIONS/photos/sheared_pudding.avi';

main(originalVideoPath, createdVideoPath);


% Main function to process the videos and compare frames
function main(originalVideoPath, createdVideoPath)
    % Extract the first frame of both original and created videos
    originalFrame = extractFirstFrame(originalVideoPath);
    createdFrame = extractFirstFrame(createdVideoPath);
    
    % Compare the pudding sizes in both frames
    comparePuddingSize(originalFrame, createdFrame);
end


% Function to extract the first frame from a video
function frame = extractFirstFrame(videoPath)
    vid = VideoReader(videoPath);
    frame = readFrame(vid); % Read the first frame
end

% Function to find the pudding region (bounding box) in an image
function [boundingBox, puddingRegion] = findPuddingRegion(image)
    % Convert the image to grayscale
    grayImage = rgb2gray(image);
    
    % Threshold to separate the pudding (assumed to be darker than white background)
    threshold = 200; % White threshold (you can adjust this value)
    binaryImage = grayImage < threshold; % Pudding will be black or darker
    
    % Find the bounding box of the pudding region
    stats = regionprops(binaryImage, 'BoundingBox', 'Area');
    
    % Find the largest area (assuming the pudding is the largest dark region)
    [~, idx] = max([stats.Area]); 
    boundingBox = stats(idx).BoundingBox; % [x, y, width, height]
    
    % Extract the pudding region from the image
    puddingRegion = imcrop(image, boundingBox); % Crop the pudding region
end

% Function to compare the pudding size between original and created videos
function comparePuddingSize(originalImage, createdImage)
    % Get the bounding box and region of pudding for original and created images
    [originalBoundingBox, originalPudding] = findPuddingRegion(originalImage);
    [createdBoundingBox, createdPudding] = findPuddingRegion(createdImage);
    
    % Compare sizes (width and height)
    originalWidth = originalBoundingBox(3);
    originalHeight = originalBoundingBox(4);
    createdWidth = createdBoundingBox(3);
    createdHeight = createdBoundingBox(4);
    
    % Display the comparison
    fprintf('Original Pudding Size: Width = %.2f, Height = %.2f\n', originalWidth, originalHeight);
    fprintf('Created Pudding Size: Width = %.2f, Height = %.2f\n', createdWidth, createdHeight);
    
    % Calculate the scaling factors
    scaleX = originalWidth / createdWidth;
    scaleY = originalHeight / createdHeight;
    
    % Print scaling factors
    fprintf('Scaling Factors: ScaleX = %.2f, ScaleY = %.2f\n', scaleX, scaleY);
    
    % Resize the created image to match the original size
    % First resize the entire image
    adjustedCreatedImage = imresize(createdImage, [size(originalImage, 1), size(originalImage, 2)]);
    
    % Resize the pudding region to match the original pudding size
    adjustedCreatedPudding = imresize(createdPudding, [originalHeight, originalWidth]);
    
    % Create a mask for the pudding region (white background elsewhere)
    adjustedCreatedImage = uint8(adjustedCreatedImage); % Make sure it's the right format
    mask = false(size(createdImage, 1), size(createdImage, 2));
    mask(round(createdBoundingBox(2)):round(createdBoundingBox(2) + createdBoundingBox(4)), ...
         round(createdBoundingBox(1)):round(createdBoundingBox(1) + createdBoundingBox(3))) = true;
    
    % Apply the adjusted pudding to the created frame
    adjustedCreatedImage(repmat(mask, [1, 1, 3])) = 255;  % Set the non-pudding region to white
    
    % Overlay the resized pudding onto the adjusted created image
    adjustedCreatedImage(round(originalBoundingBox(2)):round(originalBoundingBox(2) + originalBoundingBox(4)), ...
        round(originalBoundingBox(1)):round(originalBoundingBox(1) + originalBoundingBox(3)), :) = adjustedCreatedPudding;
    
    % Display the adjusted image
    figure;
    subplot(1, 2, 1);
    imshow(originalImage);
    title('Original Image');
    
    subplot(1, 2, 2);
    imshow(adjustedCreatedImage);
    title('Adjusted Created Image');
    
    % Save the adjusted image (optional)
    imwrite(adjustedCreatedImage, 'adjusted_created_frame.png');
    
    % Optionally: Process the full video by resizing each frame (if required)
end
