clear; close all;

% Extracts an object from an image and places it int a blank canva with mask
function [temp_img, temp_mask] = addObject(imagePath, scale, offset, H, W, objNum)

    img = im2double(imread(imagePath));
    
    % Display image for interactive mask creation
    figure; imshow(img); title(['Draw mask for object ', num2str(objNum)]);
    h = drawfreehand();          
    mask = createMask(h);        % Create a binary mask from the drawn region

    % Find bounding box of the mask
    [r,c] = find(mask);
    r1 = min(r); r2 = max(r);
    c1 = min(c); c2 = max(c);

    % Crop object and corresponding mask
    obj = img(r1:r2, c1:c2, :);
    obj_mask = mask(r1:r2, c1:c2);

    % Resize object and mask a
    obj = imresize(obj, scale);
    obj_mask = imresize(obj_mask, scale);

    % Feather mask for smooth edges
    obj_mask = imgaussfilt(double(obj_mask),7);

    % Compute position to place object in the final image
    row = round(H/2 - size(obj,1)/2 + offset(1));
    col = round(W/2 - size(obj,2)/2 + offset(2));
    row = max(1,row); col = max(1,col);

    % Create temporary image and mask the size of the final canva
    h_obj = size(obj,1); w_obj = size(obj,2);
    temp_img = zeros(H,W,3);
    temp_mask = zeros(H,W);

    % Place the object and mask into the temporary canva
    temp_img(row:row+h_obj-1, col:col+w_obj-1, :) = obj;
    temp_mask(row:row+h_obj-1, col:col+w_obj-1) = obj_mask;
end

% Load background
bg = im2double(imread('CV_1-PYRAMIDS/photos/P200.jpg'));
[H,W,~] = size(bg);

objList = { ...
    'CV_1-PYRAMIDS/photos/dog1.jpg', 0.11, [680, -389]; ...
    'CV_1-PYRAMIDS/photos/dog2.jpg', 0.21, [900, 920]; ...
    'CV_1-PYRAMIDS/photos/cat.jpg', 0.10, [780, 580]; ...
    'CV_1-PYRAMIDS/photos/bench.jpg', 0.34, [860, 80]; ...
    'mycat.jpg', 0.45, [780, -800]; ...
};

numObjs = size(objList,1);

% Initialize masks and images
masks = cell(1,numObjs);
images = cell(1,numObjs);

% Draw masks and place objects using addObject function
for k = 1:numObjs
    [images{k}, masks{k}] = addObject(objList{k,1}, objList{k,2}, objList{k,3}, H, W, k);
end

% Include background as an extra object
bg_mask = ones(H,W);

% Subtract all object masks to get background region
for k = 1:numObjs
    bg_mask = bg_mask - masks{k};
end
bg_mask = max(bg_mask,0);  % Make sure mask does not exceed 1

% Add background image and its mask to the lists
images{numObjs+1} = bg;
masks{numObjs+1} = bg_mask;
numObjs = numObjs + 1;

% Pyramid parameters
levels = 5;
Gmasks = cell(1,numObjs);
LI = cell(1,numObjs);

% Create gaussian pyramid for masks and laplacian pyramid for images
for k = 1:numObjs
    Gmasks{k} = genPyr(masks{k}, 'gauss', levels);
    LI{k} = genPyr(images{k}, 'laplace', levels);
end

% Create blended pyramid
B = cell(1,levels);
for l = 1:levels
    B{l} = zeros(size(LI{1}{l}));
    for k = 1:numObjs
        mask_resized = imresize(Gmasks{k}{l}, [size(LI{k}{l},1), size(LI{k}{l},2)]);
        B{l} = B{l} + mask_resized .* LI{k}{l};
    end
end

% Plot blended pyramid levels
figure('Name','Blended Pyramid Levels');
for l = 1:levels
    subplot(1,levels,l);
    imshow(B{l}+0.5);
    title(['Blended Level ', num2str(l)]);
end

% Reconstruct final blended image
I_blend = pyrReconstruct(B);

figure; imshow(I_blend); title('Final Pyramid Blended Image');

