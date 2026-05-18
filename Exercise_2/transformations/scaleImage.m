% function to scale images
function transformedImage = scaleImage(image, parameters)
    scaleFactor = parameters.scaleFactor;

    % scaling matrix
    transformMatrix = [scaleFactor 0 0; 0 scaleFactor 0; 0 0 1];
    transform = affine2d(transformMatrix); 

    % apply transformation
    scaledImage = imwarp(image, transform);
    
    % center scaled image on a blank canvas
    originalSize = size(image);
    paddedImage = centerImage(originalSize, scaledImage);
    

    %plotTitle = displayDetails('scale', parameters, size(image), size(paddedImage));
    %displayImages(image, paddedImage, plotTitle, 'scale');
    transformedImage = paddedImage;
end