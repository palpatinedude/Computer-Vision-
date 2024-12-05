% function to rotate an image by a given angle
function transformedImage = rotateImage(image, parameters,display)
    angle = parameters.angle;

    % rotation matrix
    transformMatrix = [cosd(angle) -sind(angle) 0; sind(angle) cosd(angle) 0; 0 0 1];
    transform = affine2d(transformMatrix);  
    
    % apply transformation
    transformedImage = imwarp(image, transform); 
   %{
    if display == 1
      plotTitle = displayDetails('rotate', parameters, size(image), size(transformedImage));
      displayImages(image, transformedImage, plotTitle, 'rotate');
    end
   %}
    % Center the rotated image on a blank canvas (same size as the original)
    originalSize = size(image);
    paddedImage = centerImage(originalSize, transformedImage);

    if display == 1
        plotTitle = displayDetails('rotate', parameters, size(image), size(paddedImage));
        displayImages(image, paddedImage, plotTitle, 'rotate');
    end

    % Return the centered, rotated image
    transformedImage = paddedImage;

end