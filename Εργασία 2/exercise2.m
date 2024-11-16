% Author : Marianthi Thodi
% AM : 1084576
% Year : 5th


disp('Hello, World!')
% PART 1 ---- play with functions

%  -------------  1.1 imread  ---------------------

I1 = imread('CV_2-TRANSFORMATIONS/photos/beach.jpg');
I2 = imread('CV_2-TRANSFORMATIONS/photos/ball2.jpg');
I3 = imread('CV_2-TRANSFORMATIONS/photos/binary.png');

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


% -----------------  1.2 imwrap and affine2d  ---------------------


% scaling
scaleMatrix = [0.25 0 0; 0 0.25 0; 0 0 1]; 
scaleTransform = affine2d(scaleMatrix);
scaledI1 = imwarp(I1, scaleTransform);


updateSizeI1 = size(scaledI1);
disp(['Size of I1: ', num2str(size_I1)]);
disp(['Size of updated I1: ', num2str(updateSizeI1)]);
% check if original and scaled images are the same
if updateSizeI1 == size_I1
    disp('The scaled image is the same as the original.');
else
    disp('The scaled image is different from the original.');
   
end

% plot scaled image
figure;
imshow(scaledI1);
title(['Scaled Image (' num2str(updateSizeI1(1)) 'x' num2str(updateSizeI1(2)) ')']);
axis image; 
 

% rotation 
theta = 75; % degrees
theta1 = -75;
rotationMatrix1 = [cosd(theta) -sind(theta) 0; ...
                  sind(theta) cosd(theta) 0; ...
                  0 0 1]; 
rotationMatrix2 = [cosd(theta1) -sind(theta1) 0; ...
                  sind(theta1) cosd(theta1) 0; ...
                  0 0 1]; 

rotationTransform1 = affine2d(rotationMatrix1); 
rotationTransform2 = affine2d(rotationMatrix2); 
rotatedI1 = imwarp(I1, rotationTransform1);
rotatedI2 = imwarp(I1, rotationTransform2);

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








