% create a periodic shear effect and save as video
function shearedVideo(image, outputPath, shearFactor, numFrames, shearDirection)
    try
        outputVideo = VideoWriter(outputPath, 'Motion JPEG AVI'); 
        disp('Using Motion JPEG AVI profile.');
    catch
        error('Failed to initialize video writer. Check the file path and system codecs.');
    end
    open(outputVideo);

    [originalRows, originalCols, channels] = size(image);
    
    % shear parameters and apply shear for each frame
    for i = 1:numFrames
        params = shearParams(i, numFrames, shearFactor, shearDirection);
        shearedImg = transformImage(image, 'shear', params); 
        
        % resize each sheared image original size
        shearedImgResized = imresize(shearedImg, [originalRows, originalCols]);
        writeVideo(outputVideo, im2frame(im2uint8(shearedImgResized))); 
        
        % Uncomment to visualize the frames during creation (optional)
        % imshow(shearedImg); 
        % title(['Frame ', num2str(i)]);
        % pause(0.1); 
    end

    close(outputVideo);
    disp(['Sheared video created successfully: ', outputPath]);

    playVideo(outputPath);
end

%{
function createShearedVideo(image, outputPath, shearFactor, numFrames, shearDirection)
 

    % set up video writer
    try
        outputVideo = VideoWriter(outputPath, 'Motion JPEG AVI'); 
        disp('Using Motion JPEG AVI profile.');
    catch
        error('Failed to initialize video writer. Check the file path and system codecs.');
    end
    open(outputVideo);

    % create shear parameters and apply shear for each frame
    for i = 1:numFrames
        params = calculateShearParams(i, numFrames, shearFactor, shearDirection);
        shearedImg = transformImage(image, 'shear', params); % apply shear
        writeVideo(outputVideo, im2frame(im2uint8(shearedImg))); % write frame to video
        imshow(shearedImg); 
        title(['Frame ', num2str(i)]);
        pause(0.1); % add a pause to simulate playback during creation
    end

    % close the video file
    close(outputVideo);
    disp(['Sheared video created successfully: ', outputPath]);

    % play the video
    playVideo(outputPath);
end

% calculate shear parameters for the current frame
function params = calculateShearParams(frameIndex, totalFrames, shearFactor, shearDirection)
    t = frameIndex / totalFrames * 2 * pi; % periodic function
    shearX = 0;
    shearY = 0;
    if shearDirection == 1 % shear along x-axis
        shearX = shearFactor * sin(t);
    elseif shearDirection == 2 % shear along y-axis
        shearY = shearFactor * sin(t);
    end
    params.shearX = shearX;
    params.shearY = shearY;
end
%}
% play video from the given path
function playVideo(videoPath)
    implay(videoPath); % play the video using implay
    disp(['Playing video: ', videoPath]);
end


