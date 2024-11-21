% Author : Marianthi Thodi
% AM : 1084576
% Year : 5th


disp('Hello, World!')
% PART 1 ---- play with functions

%  -------------  1.1 imread  ---------------------

I1 = imread('CV_2-TRANSFORMATIONS/photos/beach.jpg');
I2 = imread('CV_2-TRANSFORMATIONS/photos/ball2.jpg');
I3 = imread('CV_2-TRANSFORMATIONS/photos/binary.png');




% analyze and display each image
analyzeAndDisplayImage(I1);
analyzeAndDisplayImage(I2);
analyzeAndDisplayImage(I3);



%{
% check sizes
size_I1 = size(I1);
size_I2 = size(I2);
size_I3 = size(I3);



disp('Size of I1:');
disp(size_I1);
disp('Size of I2:');
disp(size_I2);
disp('Size of I3:');
disp(size_I3);



% display images
figure, imshow(I1);
title('Image 1 ');
figure, imshow(I2);
title('Image 2');
figure, imshow(I3);
title('Image 3');

% check type of each image
checkType(I1);  
checkType(I2);  
checkType(I3);

% convert image to other scales
convertImage(I1);
convertImage(I2);
convertImage(I3);

%}

% -----------------  1.2 imwrap affine2d ,imref2d,implay ---------------------

% scaling
parameters.scaleFactor = 0.25; 
scaledI1 = transformImage(I1, 'scale', parameters);

% display scaled image
updateSizeI1 = size(scaledI1);
disp(['Size of I1: ', num2str(size_I1)]);
disp(['Size of updated I1: ', num2str(updateSizeI1)]);
if updateSizeI1 == size_I1
    disp('The scaled image is the same as the original.');
else
    disp('The scaled image is different from the original.');
end

figure;
imshow(scaledI1);
title(['Scaled Image (' num2str(updateSizeI1(1)) 'x' num2str(updateSizeI1(2)) ')']);
axis image;

% rotation
parameters.angle = 75; 
rotatedI1 = transformImage(I1, 'rotate', parameters);

parameters.angle = -75; 
rotatedI2 = transformImage(I1, 'rotate', parameters);

updateSizeRotatedI1 = size(rotatedI1);
disp(['Size of original I1: ', num2str(size(I1))]);
disp(['Size of rotated I1: ', num2str(updateSizeRotatedI1)]);

figure;
imshow(rotatedI1);
title(['Rotated Image (' num2str(updateSizeRotatedI1(1)) 'x' num2str(updateSizeRotatedI1(2)) ')']);
axis image;

figure;
imshow(rotatedI2);
title(['Rotated Image (' num2str(updateSizeRotatedI1(1)) 'x' num2str(updateSizeRotatedI1(2)) ')']);
axis image;

% shearing
parameters.shearX = 1; 
parameters.shearY = 0;  
shearedI1 = transformImage(I1, 'shear', parameters);

figure;
imshow(shearedI1);
title(['Sheared Image (sh_x = ', num2str(parameters.shearX), ', sh_y = ', num2str(parameters.shearY), ')']);

% translation
parameters.translateX = 200; 
parameters.translateY = 100; 
translatedI1 = transformImage(I1, 'translate', parameters);

I1_ref = imref2d(size(I1)); % spatial reference for the original image

% adjust coordinate limits for translated image
translatedI1_ref = I1_ref;
translatedI1_ref.XWorldLimits(2) = translatedI1_ref.XWorldLimits(2) + parameters.translateX;
translatedI1_ref.YWorldLimits(2) = translatedI1_ref.YWorldLimits(2) + parameters.translateY;

figure;
subplot(1, 2, 1);
imshow(I1, I1_ref);
title('Original Image');
subplot(1, 2, 2);
imshow(translatedI1, translatedI1_ref);
title('Translated Image');

% translation and rotation
parameters.translateX = 250; 
parameters.translateY = 50; 
parameters.angle = 30;       
translatedAndRotatedI1 = transformImage(I1, 'translateAndRotate', parameters);

% adjust coordinate limits for  combined transformation
[rows, cols, ~] = size(translatedAndRotatedI1);
translatedAndRotatedI1_ref = imref2d([rows, cols]);
translatedAndRotatedI1_ref.XWorldLimits = [1, cols];
translatedAndRotatedI1_ref.YWorldLimits = [1, rows];

figure;
subplot(1, 2, 1);
imshow(I1, I1_ref); 
title('Original Image');
subplot(1, 2, 2);
imshow(translatedAndRotatedI1, translatedAndRotatedI1_ref);
title(['Translated and Rotated Image (' num2str(parameters.angle) '° rotation)']);


% create with implay a rotating ball 
frames = 300; % number of frames
angleStep = 360 / frames;
sequence = zeros([1500, 1500, 3, frames], 'uint8');  % increased canvas size

ball = imread('CV_2-TRANSFORMATIONS/photos/ball.jpg');

% resize the ball to be smaller
scaleFactor = 0.3; % reduce ball size
smallBall = imresize(ball, scaleFactor);

% convert grayscale to RGB if needed
if size(smallBall, 3) == 1
    smallBall = repmat(smallBall, [1 1 3]);
end

% create canva
canvasSize = 1500;
ballCanvas = uint8(zeros(canvasSize, canvasSize, 3));  
maxDim = size(smallBall, 1); % get ball size

% set the rotation radius (
rotationRadius = 300;  

% set the center of the rotation
centerX = canvasSize / 2;
centerY = canvasSize / 2;

% create animation by rotating the ball
for i = 1:frames
    % calculate new position based on angle
    angleRad = deg2rad(angleStep * i);  
    offsetX = rotationRadius * cos(angleRad);
    offsetY = rotationRadius * sin(angleRad);
    
    % reset canva to black
    ballCanvas(:,:,:) = uint8(0);  
    
    % compute new position
    ballPositionX = round(centerX + offsetX - maxDim / 2);
    ballPositionY = round(centerY + offsetY - maxDim / 2);
    
    % ensure ball stays within canvas bounds
    ballPositionX = max(min(ballPositionX, canvasSize - maxDim), 1);
    ballPositionY = max(min(ballPositionY, canvasSize - maxDim), 1);
    
    % place ball on canvas
    ballCanvas(ballPositionY:ballPositionY+maxDim-1, ballPositionX:ballPositionX+maxDim-1, :) = smallBall;
    
    % store in sequence
    sequence(:, :, :, i) = ballCanvas;
end

% play the animation at 30 fps
implay(sequence, 30);




% step 1: read the image
img = imread('your_image.png'); % load the image
imshow(img); % show the original image
title('Original Image');

% step 2: define scaling factors
scales = [0.5, 1.2, 1.5]; % scaling factors

% step 3: initialize an empty array for the composite image
composite_img = [];

% step 4: apply scaling and combine images
for i = 1:length(scales)
    scaled_img = imresize(img, scales(i)); % scale the image
    if i == 1
        composite_img = scaled_img; % first image
    else
        composite_img = [composite_img, scaled_img]; % concatenate scaled images
    end
end

% step 5: display the final composite image
figure;
imshow(composite_img);
title('Composite Image with Multiple Scales');



%{
function analyzeAndDisplayImage(image, imageName)
    % Display image info (size and type)
    sizeInfo = size(image);
    disp(['Image Name: ', imageName]);
    disp(['Size of Image: ', num2str(sizeInfo)]);
    
    % Check image type
    if isa(image, 'uint8')
        disp('Image Type: uint8');
    elseif isa(image, 'uint16')
        disp('Image Type: uint16');
    elseif isa(image, 'double')
        disp('Image Type: double');
    else
        disp(['Image Type: ', class(image)]);
    end
    
    % Display the original image
    figure;
    imshow(image);
    title(['Original Image: ', imageName]);
    
    % Convert image to grayscale if not already
    if size(image, 3) == 3
        grayscaleImage = rgb2gray(image);
        figure;
        imshow(grayscaleImage);
        title(['Grayscale Conversion: ', imageName]);
    end
    
    % Convert to double format
    doubleImage = im2double(image);
    figure;
    imshow(doubleImage);
    title(['Double Format: ', imageName]);
    
    % Convert to binary (threshold-based)
    if size(image, 3) == 3
        binaryImage = imbinarize(rgb2gray(image)); % Grayscale first for RGB images
    else
        binaryImage = imbinarize(image); % Direct for single-channel images
    end
    figure;
    imshow(binaryImage);
    title(['Binary Conversion: ', imageName]);
end


%}



%{



% translation

% translation parameters
tx = 200; % shift right by 100 pixels
ty = 100;  % shift down by 50 pixels

% translation matrix
translationMatrix = [1 0 0; 0 1 0; tx ty 1];
translationTransform = affine2d(translationMatrix);
translatedI1 = imwarp(I1, translationTransform);

% spatial reference object for  original image
I1_ref = imref2d(size(I1));

% adjust the coordinate limits of the translated image 
translatedI1_ref = I1_ref;  
translatedI1_ref.XWorldLimits(2) = translatedI1_ref.XWorldLimits(2) + tx;
translatedI1_ref.YWorldLimits(2) = translatedI1_ref.YWorldLimits(2) + ty;

figure;
subplot(1, 2, 1);
imshow(I1, I1_ref); 
title('Original Image');
subplot(1, 2, 2);
imshow(translatedI1, translatedI1_ref); 
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
translatedAndRotatedI1 = imwarp(I1, combinedTransform);

% spatial reference object for original image
I1_ref = imref2d(size(I1));
[rows, cols, ~] = size(translatedAndRotatedI1);

% adjust the  coordinate limits based on the transformed image size
translatedAndRotatedI1_ref = imref2d([rows, cols]); 
translatedAndRotatedI1_ref.XWorldLimits = [1, cols]; 
translatedAndRotatedI1_ref.YWorldLimits = [1, rows]; 

% plot the original and transformed images side by side
figure;
subplot(1, 2, 1);
imshow(I1, I1_ref); % Display the original image
title('Original Image');

subplot(1, 2, 2);
imshow(translatedAndRotatedI1, translatedAndRotatedI1_ref); 
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

