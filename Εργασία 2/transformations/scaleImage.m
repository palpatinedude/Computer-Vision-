function transformedImage = scaleImage(image, parameters,display)
    scaleFactor = parameters.scaleFactor;

    % scaling matrix
    transformMatrix = [scaleFactor 0 0; 0 scaleFactor 0; 0 0 1];
    transform = affine2d(transformMatrix); 
  %  outputRef = imref2d(size(image)*round(scaleFactor)); 

    % apply transformation
    scaledImage = imwarp(image, transform);
%{    
    % center scaled image on a blank canvas
    originalSize = size(image);
    paddedImage = centerImage(originalSize, scaledImage);
%}  
    if display == 1
    plotTitle = displayTransDetails('scale', parameters, size(image), size(scaledImage));
    displayImages(image, scaledImage, plotTitle);
    end

    transformedImage = scaledImage;
end
