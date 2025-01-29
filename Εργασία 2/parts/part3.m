% Main function to execute the 3rd part of the procedure
function part3(img, originalPath)
    % Define parameters
    outputPath = 'CV_2-TRANSFORMATIONS/photos/sheared_pudding.avi';
    shearFactor = 0.5; % Periodic shear factor
    shearDirection = 1; % Shear direction: 1 for x-axis only

    % Prepare for video processing
    originalParam = checkVideo(originalPath);

    % Create video writer
    videoWriter = VideoWriter(outputPath, 'Motion JPEG AVI');
    videoWriter.FrameRate = originalParam.FrameRate;
    open(videoWriter);

     % Calculate expanded frame size to fit sheared images
 %   [expandedHeight, expandedWidth] = calculateExpandedSize(originalParam, shearFactor);

    % Create and play sheared video
    %shearedVideo(videoWriter, img, shearFactor, shearDirection, originalParam,expandedHeight,expandedWidth);
     shearedVideo(videoWriter, img, shearFactor, shearDirection, originalParam);

    % Close video writer
    close(videoWriter);
    disp('Video of sheared pudding created successfully!');

    playVideo(outputPath);

    displayFirstFrames(originalPath, outputPath);

    % Compare metrics
   % compareVideo(originalPath, outputPath);
end

% Create a periodic shear effect and save as video
function shearedVideo(videoWriter, image, shearFactor, shearDirection, originalParam)
    try
        numFrames = originalParam.NumFrames;
        image = black2White(image);
       
        % Create the shear transformation for each frame and write to the video
        for i = 1:numFrames
          %  params = shearParams(i, numFrames, shearFactor, shearDirection);
           % shearedImg = applyShear(image, params, [50, 50]);  % Apply shear with a fixed base point

            % Apply mask to replace black pixels with white
            shearedImg = black2White(shearedImg);

            % Center the sheared image in the expanded frame
         %   centeredImg = centerImage(shearedImg, expandedHeight, expandedWidth);

            % Convert to video frame and write
          %  frame = im2frame(im2uint8(centeredImg));

            % Resize the sheared image to match the original video's resolution
           shearedImgResized = imresize(shearedImg, [originalParam.Height, originalParam.Width]);

            % Convert the resized frame to a video frame and write to video
           frame = im2frame(im2uint8(shearedImgResized));
           
            writeVideo(videoWriter, frame); 
        end  
    catch exception
        disp(['Error in sheared video creation: ', exception.message]);
    end
end

function [expandedHeight, expandedWidth] = calculateExpandedSize(originalParam, shearFactor)
    % Estimate the maximum size increase due to shearing
    maxShear = abs(shearFactor) * originalParam.Height; % Maximum shift along x-axis
    expandedWidth = ceil(originalParam.Width + maxShear);
    expandedHeight = ceil(originalParam.Height + maxShear); 
end

function centeredImg = centerImage(image, targetHeight, targetWidth)
    % Create a blank canvas of the target size
    [imgHeight, imgWidth, channels] = size(image);
    centeredImg = uint8(255 * ones(targetHeight, targetWidth, channels)); % White background

    % Calculate offsets to center the image
    offsetY = floor((targetHeight - imgHeight) / 2);
    offsetX = floor((targetWidth - imgWidth) / 2);

    % Place the original image onto the center of the canvas
    centeredImg(offsetY + (1:imgHeight), offsetX + (1:imgWidth), :) = image;
end



% Calculate shear parameters for each frame
function params = shearParams(frameIndex, totalFrames, shearFactor, shearDirection)
    t = frameIndex / totalFrames * 2 * pi; 

    % Initialize shear values
    params.shearX = 0; 
    params.shearY = 0;
    
    if shearDirection == 1 % shear along x-axis only
        params.shearX = shearFactor * (-cos(t));
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