% function to translate an image by given parameters in x and y directions
function transformedImage = translateImage(image, parameters,display)
    translateX = parameters.translateX;
    translateY = parameters.translateY;
   
    % translation matrix
    transformMatrix = [1 0 0; 0 1 0; translateX translateY 1];

    % apply  transformation
    transform = affine2d(transformMatrix);
    outputRef = imref2d(size(image) * 2); 
   
    transformedImage = imwarp(image, transform,'OutputView',outputRef);

    if display == 1
    plotTitle = displayTransDetails('translate', parameters, size(image), size(transformedImage));
    displayImages(image, transformedImage, plotTitle);
    end
end