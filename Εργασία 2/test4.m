% Main function to execute the 3rd part of the procedure
function test4(img, originalPath)
    % Define parameters
    outputPath = 'CV_2-TRANSFORMATIONS/photos/sheared_pudding.avi';
    shearFactor = 0.3; % Periodic shear factor
    shearDirection = 1; % Shear direction: 1 for x-axis only

    % Prepare for video processing
    originalParam = checkVideo(originalPath);

    % Create video writer
    videoWriter = VideoWriter(outputPath, 'Motion JPEG AVI');
    videoWriter.FrameRate = originalParam.FrameRate;
    videoWriter.Resolution = [originalParam.Width, originalParam.Height];
    open(videoWriter);

    % Create and play sheared video
    shearedVideo(videoWriter, img, shearFactor, shearDirection, originalParam);

    % Close video writer
    close(videoWriter);
    disp('Video of sheared pudding created successfully!');

    % Play the created video
    playVideo(outputPath);

    % Compare the first frames and the pudding region size
    compareFrameSizes(originalPath, outputPath);

    % Automatically create the pudding mask
    puddingMask = createPuddingMask(img);  % Create the mask for the pudding region

    % Compare the pudding region sizes for the first frame
    originalVideo = VideoReader(originalPath);
    createdVideo = VideoReader(outputPath);
    
    originalFrame = read(originalVideo, 1);
    createdFrame = read(createdVideo, 1);
    
    compareRegionSizes(originalFrame, createdFrame, puddingMask);

    % Display the first frames
    displayFirstFrames(originalPath, outputPath);

    % Display pudding region in the first created frame
    displayPuddingRegionNonWhite(originalPath, outputPath);

end

% Function to identify and display the pudding region in the first created frame
function displayPuddingRegionNonWhite(originalPath, createdPath)
    % Read the original and created videos
    originalVideo = VideoReader(originalPath);
    createdVideo = VideoReader(createdPath);
    
    % Extract the first frame from both videos
    originalFrame = read(originalVideo, 1);
    createdFrame = read(createdVideo, 1);
    
    % Create the pudding mask where everything that's not white is part of the pudding for both frames
    originalPuddingMask = createNonWhiteMask(originalFrame);
    createdPuddingMask = createNonWhiteMask(createdFrame);
    
    % Extract the pudding region from the first created frame using the mask
    createdPuddingRegion = extractPuddingRegion(createdFrame, createdPuddingMask);
    originalPuddingRegion = extractPuddingRegion(originalFrame,originalPuddingMask);
    
    % Display the original frame and the extracted pudding region from the created frame
    figure;
    
    subplot(1, 4, 1);
    imshow(createdFrame);
    title('Created Frame - First Frame');
    
    subplot(1, 4, 2);
    imshow(createdPuddingRegion);
    title('Extracted Pudding Region from Created Frame');

    subplot(1, 4, 3);
    imshow(originalFrame);
    title('Original Frame - First Frame');
    
    subplot(1, 4, 4);
    imshow(originalPuddingRegion);
    title('Original Pudding Region from Original Frame');
end





% Function to create a mask where everything that's not white is part of the pudding
function mask = createNonWhiteMask(img)
    % Convert image to double (normalize to [0, 1])
    img = im2double(img);

    % Define the threshold for non-white pixels (anything not close to [1, 1, 1])
    threshold = 0.95;  % Anything with a value less than this in RGB is considered non-white

    % Identify non-white pixels (based on RGB values)
    mask = (img(:,:,1) < threshold) | (img(:,:,2) < threshold) | (img(:,:,3) < threshold);
    
    % Convert the mask to a binary image (255 for non-white pixels, 0 for white pixels)
    mask = uint8(mask) * 255;  % Black for white pixels, white for non-white pixels
    
    % Clean up the mask (optional)
    mask = cleanMask(mask);  % Clean up mask with morphological operations if needed
end

% Refined function to create the pudding mask (color-based segmentation)
function mask = createPuddingMask(img)
    % Convert image to RGB (if not already)
    img = im2double(img);  % Normalize the image to [0, 1]

    % Define color thresholds for the pudding (brown and yellowish color)
    % The specific color ranges depend on the exact shades of the pudding
    lowerBound = [0.4, 0.2, 0.0];  % Lower bound of brown-yellow shades (in RGB)
    upperBound = [0.8, 0.7, 0.4];  % Upper bound of brown-yellow shades (in RGB)

    % Create mask where pixel values are within the defined color range
    mask = (img(:,:,1) >= lowerBound(1) & img(:,:,1) <= upperBound(1)) & ...
           (img(:,:,2) >= lowerBound(2) & img(:,:,2) <= upperBound(2)) & ...
           (img(:,:,3) >= lowerBound(3) & img(:,:,3) <= upperBound(3));
    
    % Convert the mask to a binary image (0 = background, 1 = pudding)
    mask = uint8(mask) * 255;  % Black for background, white for pudding

    % Clean up the mask (morphological operations)
    mask = cleanMask(mask);
end

% Function to clean up the mask with morphological operations
function cleanedMask = cleanMask(mask)
    % Perform morphological operations to remove small noise
    cleanedMask = imopen(mask, strel('disk', 5));  % Open operation (removes small objects)
    cleanedMask = imclose(cleanedMask, strel('disk', 10));  % Close operation (fills small holes)
end



% Function to extract the pudding region from the frame using a mask
function puddingRegion = extractPuddingRegion(frame, mask)
    % Ensure the mask is the same size as the frame
    [frameHeight, frameWidth, numChannels] = size(frame);

    % If the frame is RGB, expand the mask to match the number of channels
    if numChannels == 3
        mask = repmat(mask, [1, 1, 3]); % Replicate the mask across all channels
    end

    % Resize the mask to the same size as the frame (if needed)
    if size(mask, 1) ~= frameHeight || size(mask, 2) ~= frameWidth
        mask = imresize(mask, [frameHeight, frameWidth]);
    end

    % Apply the mask to the frame (zero out areas outside the pudding region)
    puddingRegion = frame .* uint8(mask); % Element-wise multiplication

    % Convert to grayscale and binarize to identify the white pudding region
    % Since pudding is white, we want to isolate white areas
    grayPuddingRegion = rgb2gray(puddingRegion);  % Convert to grayscale
    binaryPuddingRegion = grayPuddingRegion > 200; % Consider pixels with value > 200 as white

    % Use regionprops to find the bounding box of the white region (pudding)
    stats = regionprops(binaryPuddingRegion, 'BoundingBox');  % Get bounding box

    % Display the bounding box sizes
    if ~isempty(stats)
        for k = 1:length(stats)
            boundingBox = stats(k).BoundingBox;
            width = boundingBox(3);
            height = boundingBox(4);
            
            % Adjust the bounding box size to match Bounding Box 2's dimensions
            targetWidth = 241; % Target bounding box width
            targetHeight = 209; % Target bounding box height

            % Calculate scaling factors
            scale_width = targetWidth / width;
            scale_height = targetHeight / height;

            % Adjust the bounding box dimensions
            adjustedWidth = width * scale_width;
            adjustedHeight = height * scale_height;

            % Adjust the position of the bounding box (optional)
            xPos = boundingBox(1) * scale_width;
            yPos = boundingBox(2) * scale_height;

            disp(['Original Bounding Box ', num2str(k), ' - Width: ', num2str(width), ', Height: ', num2str(height)]);
            disp(['Adjusted Bounding Box ', num2str(k), ' - Width: ', num2str(adjustedWidth), ', Height: ', num2str(adjustedHeight)]);
            disp(['Adjusted Position - X: ', num2str(xPos), ', Y: ', num2str(yPos)]);

            % Optionally, you could draw the adjusted bounding box on the frame
            frame = insertShape(frame, 'Rectangle', [xPos, yPos, adjustedWidth, adjustedHeight], 'Color', 'green', 'LineWidth', 3);
        end
    else
        disp('No white pudding region detected.');
    end
end

% Function to compare the pudding region sizes
function compareRegionSizes(originalFrame, createdFrame, puddingMask)
    % Resize both frames to the same resolution (512x512)
    originalFrameResized = imresize(originalFrame, [512, 512]);
    createdFrameResized = imresize(createdFrame, [512, 512]);

    % Extract the pudding region from both frames using the mask
    originalRegion = extractPuddingRegion(originalFrameResized, puddingMask);
    createdRegion = extractPuddingRegion(createdFrameResized, puddingMask);
    
    % Count the non-zero pixels in each region (size of the pudding)
    originalSize = sum(originalRegion(:) > 0); % Number of non-zero pixels
    createdSize = sum(createdRegion(:) > 0);   % Number of non-zero pixels
    
    % Display the sizes of the pudding region
    disp(['Original pudding region size: ', num2str(originalSize)]);
    disp(['Created pudding region size: ', num2str(createdSize)]);
    
    % Compare the two sizes
    if originalSize == createdSize
        disp('The pudding region sizes are identical.');
    else
        disp('The pudding region sizes are different.');
    end
end


% Function to compare the frame sizes of the original and created videos
function compareFrameSizes(originalPath, createdPath)
    % Get video parameters for both videos
    originalVideo = VideoReader(originalPath);
    createdVideo = VideoReader(createdPath);
    
    % Get the resolution of the first frame from both videos
    originalFrame = read(originalVideo, 1);
    createdFrame = read(createdVideo, 1);
    
    originalSize = size(originalFrame);
    createdSize = size(createdFrame);
    
    % Compare the frame sizes
    disp(['Original frame size: ', num2str(originalSize(1)), ' x ', num2str(originalSize(2))]);
    disp(['Created frame size: ', num2str(createdSize(1)), ' x ', num2str(createdSize(2))]);
    
    if isequal(originalSize, createdSize)
        disp('The frame sizes are identical.');
    else
        disp('The frame sizes are different.');
    end
end

function displayFirstFrames(originalPath, createdPath)
    % Read the first frame of the original video
    originalVideo = VideoReader(originalPath);
    originalFrame = read(originalVideo, 1);  % Read the first frame
    
    % Read the first frame of the created video
    createdVideo = VideoReader(createdPath);
    createdFrame = read(createdVideo, 1);   % Read the first frame
    
    % Create a figure for displaying the frames
    figure;
    
    % Display the first frame of the original video
    subplot(1, 2, 1);
    imshow(originalFrame);
    title('Original Video - First Frame');
    
    % Display the first frame of the created video
    subplot(1, 2, 2);
    imshow(createdFrame);
    title('Created Video - First Frame');
end

% Create a periodic shear effect and save as video
function shearedVideo(videoWriter, image, shearFactor, shearDirection, originalParam)
    try
        numFrames = originalParam.NumFrames;
        image = black2White(image);

        % Create the shear transformation for each frame and write to the video
        for i = 1:numFrames
            params = shearParams(i, numFrames, shearFactor, shearDirection);
            shearedImg = applyShear(image, params, [50, 50]);  % Apply shear with a fixed base point

            % Apply mask to replace black pixels with white
            shearedImg = black2White(shearedImg);

            % Resize to match the original video size (to preserve resolution)
            shearedImgResized = imresize(shearedImg, [originalParam.Resolution(2), originalParam.Resolution(1)]);
            
            frame = im2frame(im2uint8(shearedImgResized));
            writeVideo(videoWriter, frame); 
        end  
    catch exception
        disp(['Error in sheared video creation: ', exception.message]);
    end
end

% Calculate shear parameters for each frame
function params = shearParams(frameIndex, totalFrames, shearFactor, shearDirection)
    t = frameIndex / totalFrames * 2 * pi; 

    % Initialize shear values
    params.shearX = 0; 
    params.shearY = 0;
    
    if shearDirection == 1 % shear along x-axis only
        params.shearX = shearFactor * cos(t);
        params.shearY = 0;  % No shear in y direction
    elseif shearDirection == 2 % shear both x and y axes
        params.shearX = shearFactor * sin(t);
        params.shearY = shearFactor * sin(t);
    end
end

% Apply shear transformation to the image along the x-axis while keeping the base point fixed
function shearedImg = applyShear(image, params, basePoint)
    % Get the size of the image
    [height, width, channels] = size(image);
    
    % Create meshgrid for pixel coordinates
    [X, Y] = meshgrid(1:width, 1:height);
    
    % Translate coordinates so the base point is at the origin
    X = X - basePoint(1);  % Shift X by base point
    Y = Y - basePoint(2);  % Shift Y by base point
    
    % Apply shear along the X-axis
    newX = X + params.shearX * Y;  % Apply shear along X based on Y-coordinate
    
    % Translate back to the original position
    newX = newX + basePoint(1);  % Shift X back to original position
    Y = Y + basePoint(2);  % Shift Y back (no change in Y)

    % Interpolate the pixels to get the new sheared frame
    shearedImg = interp2(X, Y, double(image(:,:,1)), newX, Y, 'linear', 0); % Apply shear for the red channel
    
    % If the image has more channels (RGB), apply the same transformation to all channels
    if channels > 1
        for c = 2:channels
            shearedImg(:,:,c) = interp2(X, Y, double(image(:,:,c)), newX, Y, 'linear', 0);
        end
    end

    % Convert back to uint8 for displaying
    shearedImg = uint8(shearedImg);
end

% Function to replace black pixels with white
function modifiedImage = black2White(image)
    % Convert image to grayscale if it is RGB
    if size(image, 3) == 3
        grayImage = rgb2gray(image);
    else
        grayImage = image;
    end

    % Threshold to identify black pixels (black pixels will have near zero intensity)
    blackPixels = grayImage < 10;  % 10 is the threshold for identifying black pixels
    
    % Create a modified image by replacing black pixels with white
    modifiedImage = image;
    modifiedImage(repmat(blackPixels, [1, 1, 3])) = 255; % Set black pixels to white (255)
end

% Play video from the given path
function playVideo(videoPath)
    implay(videoPath); % Play the video using implay
    disp(['Playing video: ', videoPath]);
end

% Function to check the video parameters (e.g., frame rate, number of frames)
function videoParameters = checkVideo(videoPath)
    % Load the video
    video = VideoReader(videoPath);

    % Create a structure to store properties
    videoParameters = struct();
    videoParameters.Resolution = [video.Width, video.Height];
    videoParameters.FrameRate = video.FrameRate;
    videoParameters.NumFrames = video.NumFrames;
    videoParameters.Duration = video.Duration;

    % Display general video properties
    fprintf('Video File: %s\n', videoPath);
    fprintf('Resolution: %dx%d\n', video.Width, video.Height);
    fprintf('Frame Rate: %.2f fps\n', video.FrameRate);
    fprintf('Total Frames: %d\n', video.NumFrames);
    fprintf('Duration: %.2f seconds\n', video.Duration);
end