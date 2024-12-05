% Author : Marianthi Thodi
% AM : 1084576
% Year : 5th

addpath('transformations/');
disp('Hello, World!')
% PART 1 ---- play with functions

%  -------------  1.1 imread  ---------------------


beach = imread('CV_2-TRANSFORMATIONS/photos/beach.jpg');
ball = imread('CV_2-TRANSFORMATIONS/photos/ball.jpg');
windmillBack= imread('CV_2-TRANSFORMATIONS/photos/windmill_back.jpeg');
pudding = imread('CV_2-TRANSFORMATIONS/photos/pudding.png');
windmill = imread('CV_2-TRANSFORMATIONS/photos/windmill.png');
mask = imread('CV_2-TRANSFORMATIONS/photos/windmill_mask.png');



% display image information
for i = 1:length(images)
    imageInfo(images{i});
end


% -----------------  1.2 imwrap affine2d ,imref2d,implay ---------------------

% scaling
parameters.scaleFactor = 1.25; 
scaledbeach = transformImage(beach, 'scale', parameters,1);

% rotation
parameters.angle = 75; 
rotatedbeach = transformImage(beach, 'rotate', parameters);
parameters.angle = -75; 
rotatedI2 = transformImage(beach, 'rotate', parameters,1);


% shearing
parameters.shearX = 1; 
parameters.shearY = 0;  
shearedbeach = transformImage(beach, 'shear', parameters,1);

% translation
parameters.translateX = 200; 
parameters.translateY = 100; 
translatedbeach = transformImage(beach, 'translate', parameters,1);


% translation and rotation
parameters.translateX = 250; 
parameters.translateY = 50; 
parameters.angle = 30;       
translatedAndRotatedbeach = transformImage(beach, 'translateRotate', parameters,1);

% make a animation rotate ball
numFrames = 300;            
canvasSize = 1500;           
rotationRadius = 300;     
fps = 30; % frames per sec

sequence = createAnimation(ball, numFrames, canvasSize, rotationRadius);
implay(sequence, fps);



% PART 2 ---- applies different scaling transformations to create multiple scaled versions

% define scaling factors
scales = [0.5, 1.2, 1.5];

% create the composite image with scaled versions
compositeImg = compositeImage(windmillBack, scales);

% display the result
figure;
imshow(compositeImg);
title('Composite Image with Multiple Scales');






% PART 3,4 ---- create periodic shear effect on the image
outputPath = 'CV_2-TRANSFORMATIONS/photos/sheared_pudding.avi';
shearFactor = 0.6; % periodic shear factor
numFrames = 30; % number of frames
shearDirection = 1; % shear along x-axis

% create and play sheared video
shearedVideo(pudding, outputPath, shearFactor, numFrames, shearDirection);


% PART 5 ---- create animated windmill transformation video











%{

% set video parameters
outputPath = 'CV_2-TRANSFORMATIONS/photos/transf_windmill.avi';
numFrames = 120;  
rotationAngle = 360; % total rotation across frames
scaleFactor = 1.2; 
%{
% create video writer
%videoWriter = VideoWriter(outputPath, 'Uncompressed AVI');
%open(videoWriter);

% create figure for animation
figure;
axis off;
axis equal;

% loop through frames
for t = 1:numFrames
    % calculate rotation angle for current frame
    angle = (rotationAngle / numFrames) * t;

    % scale windmill image
  %  scaleParams.scaleFactor = scaleFactor;
   % scaledWindmill = transformImage(coImage, 'scale', scaleParams); 
    %scaledAlpha = transformImage(alphaChannel, 'scale', scaleParams); 

    % rotate scaled windmill image
    rotatedWindmill = imrotate(scaledWindmill, angle, 'bilinear', 'crop');
    rotatedAlpha = imrotate(scaledAlpha, angle, 'bilinear', 'crop');

    maskedWindmill = double(rotatedWindmill) .* double(rotatedAlpha); 
    maskedWindmill = uint8(maskedWindmill); % convert back to integers after processing
end    
%}

%{
    % resize background if needed
    if size(windmillBack, 1) ~= size(maskedWindmill, 1) || size(windmillBack, 2) ~= size(maskedWindmill, 2)
        windmillBack = imresize(windmillBack, [size(maskedWindmill, 1), size(maskedWindmill, 2)]);
    end

    % ensure background and windmill are same class
    if ~isa(windmillBack, class(maskedWindmill))
        windmillBack = im2uint8(windmillBack); % convert to uint8
    end

    % blend background and windmill manually
    compositeImage = windmillBack; % initialize composite image
    for c = 1:3
        compositeImage(:, :, c) = uint8( ...
            double(windmillBack(:, :, c)) .* (1 - rotatedAlpha) + ...
            double(maskedWindmill(:, :, c)) .* rotatedAlpha ...
        );
    end

    % display composite image
    imshow(compositeImage);
    
    % capture frame and write to video
    frame = getframe(gcf);
    writeVideo(videoWriter, frame);%}
end

% close video writer
close(videoWriter);

disp('Video created and saved as transf_windmill.avi');
%}



%{
% resize the mask to match  rotated image
if size(mask, 1) ~= size(rotatedWindmill, 1) || size(mask, 2) ~= size(rotatedWindmill, 2)
    mask = imresize(mask, [size(rotatedWindmill, 1), size(rotatedWindmill, 2)]);
end

% apply the mask 
maskedBlades = rotatedWindmill .* uint8(mask);  
imshow(maskedRotatedBlades);

for i = 1:numFrames
    % update rotation angle
    parameters.angle = (i - 1) * rotationAngle;
    rotatedWindmill = rotateImage(windmill, parameters);

    % apply mask to isolate the rotating blades
    maskedRotatedBlades = rotatedWindmill .* uint8(mask);

    imshow(maskedRotatedBlades);
    title(['Rotated and masked windmill frame ', num2str(i), ' angle: ', num2str(parameters.angle)]);
    pause(0.1); 
end

% Close and save the video
close(outputVideo);
disp(['Windmill video created successfully at ', outputPath]);

%}






%{



% translation

% translation parameters
tx = 200; % shift right by 100 pixels
ty = 100;  % shift down by 50 pixels

% translation matrix
translationMatrix = [1 0 0; 0 1 0; tx ty 1];
translationTransform = affine2d(translationMatrix);
translatedbeach = imwarp(beach, translationTransform);

% spatial reference object for  original image
beach_ref = imref2d(size(beach));

% adjust the coordinate limits of the translated image 
translatedbeach_ref = beach_ref;  
translatedbeach_ref.XWorldLimits(2) = translatedbeach_ref.XWorldLimits(2) + tx;
translatedbeach_ref.YWorldLimits(2) = translatedbeach_ref.YWorldLimits(2) + ty;

figure;
subplot(1, 2, 1);
imshow(beach, beach_ref); 
title('Original Image');
subplot(1, 2, 2);
imshow(translatedbeach, translatedbeach_ref); 
title('Translated Image');


% translation and rotation
tx = 250; % shift right by 250 pixels
ty = 50;  % shift down by 50 pixels

theta = 30; % rotation by 30 degrees

% create the translation matrix
translationMatrix = [1 0 0; 0 1 0; tx ty 1];

% create the rotation matrix
rotationMatrix = [cosd(theta) -sind(theta) 0; 
                  sind(theta) cosd(theta) 0; 
                  0 0 1];

% multiple the matrices
combinedMatrix = translationMatrix * rotationMatrix;
combinedTransform = affine2d(combinedMatrix);
translatedAndRotatedbeach = imwarp(beach, combinedTransform);

% spatial reference object for original image
beach_ref = imref2d(size(beach));
[rows, cols, ~] = size(translatedAndRotatedbeach);

% adjust the  coordinate limits based on the transformed image size
translatedAndRotatedbeach_ref = imref2d([rows, cols]); 
translatedAndRotatedbeach_ref.XWorldLimits = [1, cols]; 
translatedAndRotatedbeach_ref.YWorldLimits = [1, rows]; 

% plot the original and transformed images side by side
figure;
subplot(1, 2, 1);
imshow(beach, beach_ref); % Display the original image
title('Original Image');

subplot(1, 2, 2);
imshow(translatedAndRotatedbeach, translatedAndRotatedbeach_ref); 
title(['Translated and Rotated Image (' num2str(theta) '° rotation)']);



%
function preprocessImage(image, imageName)
    % Analyze image info
    disp(['Image Name: ', imageName]);
    disp(['Size: ', num2str(size(image))]);

    % Preprocess: Convert to grayscale, binary, and normalize
    convertImage(image);

    % Apply Gaussian smoothing
    smoothedImage = imgaussfilt(rgb2gray(image), 2);
    figure;
    imshow(smoothedImage);
    title(['Smoothed Image: ', imageName]);

    % Normalize
    normalizedImage = double(image) / 255;
    figure;
    imshow(normalizedImage);
    title(['Normalized Image: ', imageName]);
end


%}
%}