% function to rotate an image by a given angle
function transformedImage = rotateImage(image, parameters)
    angle = parameters.angle;

    % rotation matrix
    transformMatrix = [cosd(angle) -sind(angle) 0; sind(angle) cosd(angle) 0; 0 0 1];
    transform = affine2d(transformMatrix);  
    
    % apply transformation
    transformedImage = imwarp(image, transform); 
   
    plotTitle = displayDetails('rotate', parameters, size(image), size(transformedImage));
    displayImages(image, transformedImage, plotTitle, 'rotate');
end