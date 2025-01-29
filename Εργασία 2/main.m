% Author : Marianthi Thodi
% AM : 1084576
% Year : 5th

% The main goal of this exercise is to learn how to apply geometric transformations to images and animations using affine and projective transformations.
% Exercise in manipulating images through scaling, rotation, shearing, and translation.
% See how different interpolation methods affect the image quality . 


addpath('transformations/');
addpath('helpers/');
addpath('parts/');

% load images
beach = imread('CV_2-TRANSFORMATIONS/photos/beach.jpg');
ball = imread('CV_2-TRANSFORMATIONS/photos/ball.jpg');
windmillBack= imread('CV_2-TRANSFORMATIONS/photos/windmill_back.jpeg');
pudding = imread('CV_2-TRANSFORMATIONS/photos/pudding.png');
windmill = imread('CV_2-TRANSFORMATIONS/photos/windmill.png');
mask = imread('CV_2-TRANSFORMATIONS/photos/windmill_mask.png');
ballMask = imread('CV_2-TRANSFORMATIONS/photos/ball_mask.jpg');

originalPuddVideo = 'CV_2-TRANSFORMATIONS/photos/pudding.avi';
originalWindVideo = 'CV_2-TRANSFORMATIONS/photos/windmill.avi';

images = {beach,ball,windmillBack,pudding,windmill,mask}; % cell to store multiple images of different sizes and formats


%{
% display image information
for i = 1:length(images)
    imageInfo(images{i});
end
%}


% execute the first part of the procedure(play with functions)
%part1(beach,ball);

% execute the second part of the procedure(concatenate multiple version of scaled image either vertical or horizontal)
%part2(windmillBack,'vertical');

% execute third --> shearDirection = 2 and forth --> shearDirection = 1 parts of the procedure(create periodic shear effect on the image)
%implay(originalPuddVideo);
part31(pudding,originalPuddVideo);
%test4(pudding,originalPuddVideo);
% execute fifth part of procedure
%part5(windmillBack,windmill,mask,originalPath);

% execute sixth part of procedure
%part6(windmillBack,windmill,mask,originalWindVideo);


% execute seventh part of procedure
%part7(beach,ball,ballMask);















%









