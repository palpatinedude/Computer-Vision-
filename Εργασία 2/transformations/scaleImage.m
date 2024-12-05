function transformedImage = scaleImage(image, parameters,display)
    scaleFactor = parameters.scaleFactor;

    % scaling matrix
    transformMatrix = [scaleFactor 0 0; 0 scaleFactor 0; 0 0 1];
    transform = affine2d(transformMatrix); 

    % apply transformation
    scaledImage = imwarp(image, transform);
    
    % center scaled image on a blank canvas
    originalSize = size(image);
    paddedImage = centerImage(originalSize, scaledImage);
    
    if display == 1
    plotTitle = displayDetails('scale', parameters, size(image), size(paddedImage));
    displayImages(image, paddedImage, plotTitle, 'scale');
    end
    transformedImage = paddedImage;
end
%{
function transformedImage = scaleImage(image, parameters)
    scaleFactor = parameters.scaleFactor;

    % Create scaling matrix
    transformMatrix = [scaleFactor 0 0; 0 scaleFactor 0; 0 0 1];
    transform = affine2d(transformMatrix); 

    % Compute new scaled size
    scaledImage = imwarp(image, transform);
    [rowsScaled, colsScaled, ~] = size(scaledImage);

    % Create a blank canvas of the same size as the original image
    [rowsOrig, colsOrig, channels] = size(image);
    paddedImage = zeros(rowsOrig, colsOrig, channels, 'like', image);

    % Center the scaled image on the canvas
    rowStart = max(1, round((rowsOrig - rowsScaled) / 2));
    colStart = max(1, round((colsOrig - colsScaled) / 2));
    rowEnd = min(rowsOrig, rowStart + rowsScaled - 1);
    colEnd = min(colsOrig, colStart + colsScaled - 1);

    % Place the scaled image in the center
    paddedImage(rowStart:rowEnd, colStart:colEnd, :) = scaledImage(1:(rowEnd - rowStart + 1), 1:(colEnd - colStart + 1), :);

    % Get plotTitle from displayTransformationDetails
    plotTitle = displayTransformationDetails('scale', parameters, size(image), size(paddedImage));

    % Display the images with the generated title
    displayImages(image, paddedImage, plotTitle, 'scale');

    transformedImage = paddedImage;
end

function transformedImage = scaleImage(image, parameters)
    scaleFactor = parameters.scaleFactor;

    % create scaling matrix
    transformMatrix = [scaleFactor 0 0; 0 scaleFactor 0; 0 0 1];
    transform = affine2d(transformMatrix); 
    newSize = round(size(image) * scaleFactor);

    % apply scaling transformation
    transformedImage = imwarp(image, transform, 'OutputView', imref2d(newSize));

    % get plotTitle from displayTransformationDetails
    plotTitle = displayTransformationDetails('scale', parameters, size(image), size(transformedImage));

    % display the images with the generated title
    displayImages(image, transformedImage, plotTitle,'scale');
end
%}
