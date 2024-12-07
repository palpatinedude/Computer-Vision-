% main goal is to create periodic sequence of images using shearing transformation.

% function to execute the 3rd part of the procedure
function part3(img)
  % define parameters
  outputPath = 'CV_2-TRANSFORMATIONS/photos/sheared_pudding.avi';
  shearFactor = 0.6; % periodic shear factor
  numFrames = 30; % number of frames
  shearDirection = 1; % if 1 --> along x ifelse 2 --> along x and y

  % create and play sheared video
  shearedVideo(img, outputPath, shearFactor, numFrames, shearDirection);

end

% create a periodic shear effect and save as video
function shearedVideo(image, outputPath, shearFactor, numFrames, shearDirection)
    try
        outputVideo = VideoWriter(outputPath, 'Motion JPEG AVI'); 
        disp('Using Motion JPEG AVI profile.');
    catch
        error('Failed to initialize video writer. Check the file path and system codecs.');
    end
    open(outputVideo);

    [originalRows, originalCols, ~] = size(image);
    
    % shear parameters and apply shear for each frame
    for i = 1:numFrames
        params = shearParams(i, numFrames, shearFactor, shearDirection);
        shearedImg = transformImage(image, 'shear', params,0); 
        
        % resize in order to keep the original image size cause from shearing can cause the image to be cropped 
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

function params = shearParams(frameIndex, totalFrames, shearFactor, shearDirection)
    t = frameIndex / totalFrames * 2 * pi; 
    
    if shearDirection == 1 % shear along x-axis or reverse and its only by y
        params.shearX = shearFactor * sin(t);
        params.shearY = 0;
    elseif shearDirection == 2 % shear both x and y axes
        params.shearX = shearFactor * sin(t);
        params.shearY = shearFactor * cos(t);
    end
end


% play video from the given path
function playVideo(videoPath)
    implay(videoPath); % play the video using implay
    disp(['Playing video: ', videoPath]);
end
