% Step 1: Load the background and overlay images
background = imread('background.jpg'); % Replace with your background image
overlay = imread('overlay.jpg'); % Replace with your overlay image

% Convert to double for processing
background = im2double(background);
overlay = im2double(overlay);

% Step 2: Define the region and resize the overlay image
region = [50, 100, 200, 300]; % [row_start, col_start, row_end, col_end]
overlay_resized = imresize(overlay, [region(3)-region(1)+1, region(4)-region(2)+1]);

% Step 3: Create a mask for the region
mask = zeros(size(background, 1), size(background, 2));
mask(region(1):region(3), region(2):region(4)) = 1;

% If the image is color, replicate the mask for each channel
if size(background, 3) == 3
    mask = repmat(mask, [1, 1, 3]);
end

% Step 4: Replace the region in the background with the overlay
result = background;
result(mask == 1) = overlay_resized(mask == 1);

% Step 5: Visualize the result
figure;
subplot(1, 3, 1), imshow(background), title('Background Image');
subplot(1, 3, 2), imshow(overlay), title('Overlay Image');
subplot(1, 3, 3), imshow(result), title('Resulting Image');