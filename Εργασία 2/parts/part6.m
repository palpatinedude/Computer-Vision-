function part6(bg, fg, mask,originalPath)
  
  % Define interpolation methods
  interpolationMethods = {'nearest', 'bilinear', 'bicubic'};
  
  % Prepare for video processing
  originalParam = checkVideo(originalPath);
  
  % Loop over interpolation methods to generate video with each
  for i = 1:length(interpolationMethods)
    method = interpolationMethods{i};
    outputPath = ['transf_windmill_', method, '.avi'];
    
    % Create video writer
    videoWriter = VideoWriter(outputPath, 'Motion JPEG AVI');
    videoWriter.FrameRate = originalParam.FrameRate;
    open(videoWriter);
    
    % Preprocess images (remove red background and convert mask to binary)
    windmill = removeRedBackground(fg);  % Remove red background
    maskBinary = preprocessMask(mask);    % Convert mask to binary
    
    % Get image dimensions
    [height, width, ~] = size(bg);

    parameters = struct();
    parameters.scaleFactor = 0.95; % Scaling factor
    parameters.angle = 0; % Initial angle for rotation
    
    % Apply transformations (scaling)
    scaledWindmill = transformImage(windmill, 'scale', parameters, method);
    scaledMask = transformImage(maskBinary, 'scale', parameters, method);
    
    % Initial displacement (where the windmill is placed on the background)
    displacement = [width * 0.5135, height * 0.41];
    
    % Measure time to process frames
    tic; % Start timing the frame processing
    processFrames(videoWriter, bg, scaledWindmill, scaledMask, displacement, parameters, originalParam, method);
    elapsedTime = toc; % End timing
    disp(['Time taken for ', method, ' interpolation: ', num2str(elapsedTime), ' seconds']);
    
    % Close video writer
    close(videoWriter);
    disp(['Video of rotating windmill blades created successfully with ', method, ' interpolation!']);
    
    % Compare the generated video with the original
    compareVideo(originalPath, outputPath);
  end
end

