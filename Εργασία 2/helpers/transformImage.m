% function to apply different transformations
function transformedImage = transformImage(image, transformationType, parameters,display)
    switch transformationType
        case 'scale'
            transformedImage = scaleImage(image, parameters,display);
        case 'rotate'
            transformedImage = rotateImage(image, parameters,display);
        case 'shear'
            transformedImage = shearImage(image, parameters,display);
        case 'translate'
            transformedImage = translateImage(image, parameters,display);
        case 'translateRotate'
            transformedImage = translateRotateImage(image, parameters,display);
        otherwise
            error('Unknown transformation type.');
    end
end

