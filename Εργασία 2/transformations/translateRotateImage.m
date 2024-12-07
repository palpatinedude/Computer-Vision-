% function to translate and rotate an image
function transformedImage = translateRotateImage(image, parameters,display)
    % extract translation and rotation parameters
    translateX = parameters.translateX;
    translateY = parameters.translateY;
    angle = parameters.angle;

    % translation and rotation matrices
    translationMatrix = [1 0 0; 0 1 0; translateX translateY 1];
    rotationMatrix = [cosd(angle) -sind(angle) 0; sind(angle) cosd(angle) 0; 0 0 1];
    transformMatrix = translationMatrix * rotationMatrix;

    % apply transformation
    transform = affine2d(transformMatrix);
    transformedImage = imwarp(image, transform);
%{
    % center transformed image on a blank canvas
    originalSize = size(image);
    transformedImage = centerImage(originalSize, transformedImage);
%}
    if display == 1
    plotTitle = displayTransDetails('translateRotate', parameters, size(image), size(transformedImage));
    displayImages(image, transformedImage, plotTitle);
    end

end
