% function to shear an image by given factors
function transformedImage = shearImage(image, parameters,display)
    shearX = parameters.shearX;
    shearY = parameters.shearY;

    % shear matrix
    transformMatrix = [1 shearX 0; shearY 1 0; 0 0 1];

    % validate  matrix
    if det(transformMatrix(1:2, 1:2)) == 0
        error('Invalid shear matrix: determinant is 0.');
    end

    % apply transformation
    transform = affine2d(transformMatrix);
%    outputRef = imref2d(size(image) * 2); 
    transformedImage = imwarp(image, transform);
    
    if display == 1
    plotTitle = displayDetails('shear', parameters, size(image), size(transformedImage));
    displayImages(image, transformedImage, plotTitle, 'shear');
    end

end