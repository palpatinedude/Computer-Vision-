function displayImages(originalImage, transformedImage, plotTitle, transformType)
    % Display the original image
    figure;
    subplot(1, 2, 1);
    imshow(originalImage);
    title('Original Image');
    axis on;
    xlabel('Width (pixels)');
    ylabel('Height (pixels)');
    axis image;

    % Display the transformed image
    subplot(1, 2, 2);
    imshow(transformedImage);
    title(plotTitle);
    axis on;
    xlabel('Width (pixels)');
    ylabel('Height (pixels)');
    axis image;
end