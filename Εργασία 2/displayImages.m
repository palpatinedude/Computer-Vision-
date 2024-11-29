% function to display the original and transformed images
%{
function displayImages(originalImage, transformedImage, plotTitle,transformType)
    figure;
    subplot(1, 2, 1);
    imshow(originalImage);
    title('Original Image');
  %  axis image;

    subplot(1, 2, 2);
    imshow(transformedImage);
    title(plotTitle); 
   % axis image;
end
%}
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
%{
function displayImages(originalImage, transformedImage, plotTitle,transformType)
    % Get the size of the original and transformed images
    [rowsOrig, colsOrig, ~] = size(originalImage);
    [rowsTrans, colsTrans, ~] = size(transformedImage);

    % Display the original image
    figure;
    subplot(1, 2, 1);
    imshow(originalImage);
    title('Original Image');
    % Set the axis to reflect the image size
    axis on;
    xticks(0:colsOrig/5:colsOrig); % Adjust tick spacing for x-axis
    yticks(0:rowsOrig/5:rowsOrig); % Adjust tick spacing for y-axis
    xlabel('Width (pixels)');
    ylabel('Height (pixels)');
    axis image;

    % Display the transformed image
    subplot(1, 2, 2);
    imshow(transformedImage);
    title(plotTitle);
    % Set the axis to reflect the image size after transformation
    axis on;
    xticks(0:colsTrans/5:colsTrans); % Adjust tick spacing for x-axis
    yticks(0:rowsTrans/5:rowsTrans); % Adjust tick spacing for y-axis
    xlabel('Width (pixels)');
    ylabel('Height (pixels)');
    axis image;
end
%}