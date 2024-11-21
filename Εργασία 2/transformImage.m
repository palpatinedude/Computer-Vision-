% function to apply different transformations
function transformedImage = transformImage(image, transformationType, parameters)
    switch transformationType
        case 'scale'
            scaleFactor = parameters.scaleFactor;
            transformMatrix = [scaleFactor 0 0; 0 scaleFactor 0; 0 0 1];
        
        case 'rotate'
            angle = parameters.angle;
            transformMatrix = [cosd(angle) -sind(angle) 0; sind(angle) cosd(angle) 0; 0 0 1];
        
        case 'shear'
            shearX = parameters.shearX;
            shearY = parameters.shearY;
            if det([1 shearX; shearY 1]) == 0
                error('Invalid shear matrix: determinant is 0.');
            end
            transformMatrix = [1 shearX 0; shearY 1 0; 0 0 1];
        
        case 'translate'
            translateX = parameters.translateX;
            translateY = parameters.translateY;
            transformMatrix = [1 0 0; 0 1 0; translateX translateY 1];
        
        case 'translateAndRotate'
            translateX = parameters.translateX;
            translateY = parameters.translateY;
            angle = parameters.angle;
            translationMatrix = [1 0 0; 0 1 0; translateX translateY 1];
            rotationMatrix = [cosd(angle) -sind(angle) 0; sind(angle) cosd(angle) 0; 0 0 1];
            transformMatrix = translationMatrix * rotationMatrix;
        
        otherwise
            error('Unknown transformation type.');
    end
    
    % apply affine transformation
    transform = affine2d(transformMatrix);
    transformedImage = imwarp(image, transform);
end