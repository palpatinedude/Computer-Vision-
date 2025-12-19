%% Familiarization with basic functions

clear; close all;

I = imread('CV_2-TRANSFORMATIONS/pudding.png');  
figure; imshow(I); title('Pudding Image');

% Affine transformation (2x scaling and shearing)
% 2x scaling
A_scale = [2 0 0; 0 2 0; 0 0 1];       % Affine matrix for scaling
tform_scale = affine2d(A_scale);       % Create affine transformation object
R = imref2d(size(I));                   % Keep the original image size
J_scale = imwarp(I, tform_scale, 'OutputView', R); % Apply transformation
figure; imshow(J_scale); title('Affine - 2x Scaling');

% Horizontal shearing
A_shear = [1 0.5 0; 0 1 0; 0 0 1];     % Affine matrix for horizontal shear
tform_shear = affine2d(A_shear);       % Create affine transformation object
J_shear = imwarp(I, tform_shear, 'OutputView', R); % Apply transformation
figure; imshow(J_shear); title('Affine - Horizontal Shearing');

% Projective transformation
H = [1 0.2 0; 0.1 1 0; 0 0 1];         % Homography matrix
tform_proj = projective2d(H);          % Create projective transformation object
J_proj = imwarp(I, tform_proj, 'OutputView', R); % Apply transformation
figure; imshow(J_proj); title('Projective Transformation');

% Create a sequence of images
videoFrames = cell(1,10);   % Preallocate 10 frames
for k = 1:10
    angle = k*0.1;          % Gradual horizontal shearing
    A_anim = [1 angle 0; 0 1 0; 0 0 1];  % Affine matrix for animation
    tform_anim = affine2d(A_anim);       % Create affine transformation object
    videoFrames{k} = imwarp(I, tform_anim, 'OutputView', R); % Apply transformation
end


% Convert cell array to 4D numeric array for implay
numFrames = numel(videoFrames);
[height, width, channels] = size(videoFrames{1});   % Get image size
videoArray = zeros(height, width, channels, numFrames, 'like', videoFrames{1});  % Preserve type

for k = 1:numFrames
    videoArray(:,:,:,k) = videoFrames{k};  % Fill 4D array
end

implay(videoArray);  
