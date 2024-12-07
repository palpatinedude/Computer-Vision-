% function to display original and transformed images
function displayImages(originalImage, transformedImage, plotTitle)

    figure;
    % if original image is binary  and 3D
    if islogical(originalImage) && ndims(originalImage) == 3
        originalImage = originalImage(:,:,1);
    end
    
    subplot(1, 2, 1);
    imshow(originalImage);
    title('Original Image');
    axis on; % show in terms of pixels for width and height.
    xlabel('Width (pixels)');
    ylabel('Height (pixels)');
    axis image; % ensures image appears as square(equal scaling in both x and y directions).

    subplot(1, 2, 2);

    % if transformed image is binary and 3D
    if islogical(transformedImage) && ndims(transformedImage) == 3
        transformedImage = transformedImage(:,:,1); 
    end
    
    imshow(transformedImage);
    title(plotTitle);
    axis on;
    xlabel('Width (pixels)');
    ylabel('Height (pixels)');
    axis image;
end

