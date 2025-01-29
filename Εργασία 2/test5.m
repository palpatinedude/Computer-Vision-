function test5(img, originalPath)
    % Define parameters
    outputPath = 'CV_2-TRANSFORMATIONS/photos/sheared_pudding.avi';
    shearFactor = 0.3; % Periodic shear factor
    shearDirection = 1; % Shear direction: 1 for x-axis only

    % Prepare for video processing
    originalParam = checkVideo(originalPath);

    % Create video writer
    videoWriter = VideoWriter(outputPath, 'Motion JPEG AVI');
    videoWriter.FrameRate = originalParam.FrameRate;
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

    displayFirstFrames(originalPath, outputPath);
    displayPuddingRegionNonWhite(originalPath);

    % Modify the pudding region in the created video
    modifyPuddingRegion(originalPath, outputPath, 'CV_2-TRANSFORMATIONS/photos/modified_sheared_pudding.avi');
end

% Function to modify the pudding region based on the bounding box
function modifyPuddingRegion(originalPath, createdPath, outputPath)
    % Read the original and created videos
    originalVideo = VideoReader(originalPath);
    createdVideo = VideoReader(createdPath);
    
    % Create a new video writer to save the modified video
    videoWriter = VideoWriter(outputPath, 'Motion JPEG AVI');
    videoWriter.FrameRate = originalVideo.FrameRate;
    open(videoWriter);
    
    % Process each frame in the video
    while hasFrame(originalVideo) && hasFrame(createdVideo)
        % Read the current frames from both videos
        originalFrame = readFrame(originalVideo);
        createdFrame = readFrame(createdVideo);
        
        % Create the pudding mask for the original frame
        puddingMask = createNonWhiteMask(originalFrame);
        
        % Extract the bounding box of the pudding region from the mask
        stats = regionprops(puddingMask, 'BoundingBox');
        if ~isempty(stats)
            boundingBox = stats(1).BoundingBox;  % Take the first bounding box if multiple are found
            
            % Extract the pudding region from the original frame using the bounding box
            puddingRegionOriginal = imcrop(originalFrame, boundingBox);
            
            % Resize the pudding region from the original frame to fit into the created frame's bounding box
            puddingRegionResized = imresize(puddingRegionOriginal, [round(boundingBox(4)), round(boundingBox(3))]);
            
            % Insert the resized pudding region into the created frame at the position of the bounding box
            createdFrame(round(boundingBox(2)):round(boundingBox(2) + boundingBox(4)), ...
                         round(boundingBox(1)):round(boundingBox(1) + boundingBox(3)), :) = puddingRegionResized;
        end
        
        % Write the modified frame to the output video
        writeVideo(videoWriter, im2frame(im2uint8(createdFrame)));
    end
    
    % Close the video writer
    close(videoWriter);
    disp('Modified video created successfully!');
    
    % Play the modified video
    playVideo(outputPath);
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

% Function to clean up the mask with morphological operations
function cleanedMask = cleanMask(mask)
    % Perform morphological operations to remove small noise
    cleanedMask = imopen(mask, strel('disk', 5));  % Open operation (removes small objects)
    cleanedMask = imclose(cleanedMask, strel('disk', 10));  % Close operation (fills small holes)
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

% Play video from the given path
function playVideo(videoPath)
    implay(videoPath); % Play the video using implay
    disp(['Playing video: ', videoPath]);
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
