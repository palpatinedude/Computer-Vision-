% main goal of this part is to apply custom transformations in a image in order to place it
% in front of  background image and with the help of a mask blend with the aim of creating a video.
% Also see how different methods of interpolation affect image quality .

% function to execure 4th and 5th parts of the procedure
function part5(bg,fg,mask,originalPath)

  % Prepare video writer
  outputPath = 'transf_windmill.avi';

 % createdParam = checkVideo(outputPath);
  originalParam = checkVideo(originalPath);

  videoWriter = VideoWriter(outputPath, 'Motion JPEG AVI');
  videoWriter.FrameRate = originalParam.FrameRate;
  open(videoWriter);

  % Preprocess images (remove red background and convert mask to binary)
  windmill = removeRedBackground(fg);  % Remove red background
  maskBinary = preprocessMask(mask);         % Convert mask to binary
  
  % Get image dimensions
  [height, width, ~] = size(bg);

  parameters = struct();
  parameters.scaleFactor = 0.95; % Store scaling factor in parameters structure
  parameters.angle = 0; % Initialize the angle for rotation

  % Scale windmill and mask
  scaledWindmill = transformImage(windmill, 'scale', parameters, 0);
  scaledMask = transformImage(maskBinary, 'scale', parameters, 0);

  % Initial displacement (where the windmill is placed on the background)
  displacement = [width * 0.5135, height * 0.41];

 % Process video frames
  processFrames(videoWriter, bg, scaledWindmill, scaledMask, displacement, parameters, originalParam,'');

  % Close video writer
  close(videoWriter);
  disp('Video of rotating windmill blades created successfully!');

  % compare video
  compareVideo(originalPath,outputPath);
end


