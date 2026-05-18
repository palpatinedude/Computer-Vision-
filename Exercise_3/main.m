%% Main Pipeline of SIFT+Matching

img1 = im2double(imread('cameraman.tif'));

% Transformation of the second image to find matching keypoints
img2 = imresize(imrotate(img1, 15, 'bicubic', 'crop'), 0.8);
%img2 = imrotate(img1, 45, 'bicubic', 'crop');
%img2 = imresize(img1, 3.5, 'bicubic');
%img2 = imnoise(img1, 'gaussian', 0, 0.01);
%img2 = img1 + 50/255;          % Brightness +50
%img2 = min(max(img2, 0), 1);   % Clipping στο [0,1]


% Feature Extraction
% Call the SIFT function to find interest points and their 128D descriptors
fprintf('Extracting SIFT features...\n');
[keypoints1, descriptors1] = sift(img1);
[keypoints2, descriptors2] = sift(img2);

% Execute matching pipeline
[p1, p2] = matching(keypoints1, descriptors1, keypoints2, descriptors2);

% RANSAC geometric verification
ransac(img1, img2, p1, p2);
