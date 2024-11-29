% function to apply different transformations
function transformedImage = transformImage(image, transformationType, parameters)
    switch transformationType
        case 'scale'
            transformedImage = scaleImage(image, parameters);
        case 'rotate'
            transformedImage = rotateImage(image, parameters);
        case 'shear'
            transformedImage = shearImage(image, parameters);
        case 'translate'
            transformedImage = translateImage(image, parameters);
        case 'translateRotate'
            transformedImage = translateRotateImage(image, parameters);
        otherwise
            error('Unknown transformation type.');
    end
end

%{
function transformedImage = transformImage(image, transformationType, parameters)
 
    switch transformationType
        case 'scale'
            % scale factor
            scaleFactor = parameters.scaleFactor;
            transformMatrix = [scaleFactor 0 0; 0 scaleFactor 0; 0 0 1];
            
            % apply scaling transformation 
            transform = affine2d(transformMatrix); 
          
            newSize = round(size(image) * scaleFactor);
            transformedImage = imwarp(image, transform, 'OutputView', imref2d(newSize)); % scale image
            
            size_I1 = size(image); 
            updateSizeI1 = size(transformedImage); 

            disp(['Scale Factor: ', num2str(scaleFactor)]);
            disp(['Size of original image: ', num2str(size_I1(1)), 'x', num2str(size_I1(2))]);
            disp(['Size of scaled image: ', num2str(updateSizeI1(1)), 'x', num2str(updateSizeI1(2))]);

            % set dynamic title
            plotTitle = ['Scaled by ', num2str(scaleFactor), ...
                         ' (Original: ', num2str(size_I1(1)), 'x', num2str(size_I1(2)), ...
                         ', Scaled: ', num2str(updateSizeI1(1)), 'x', num2str(updateSizeI1(2)), ')'];

        case 'rotate'
            % rotation angle
            angle = parameters.angle;
            transformMatrix = [cosd(angle) -sind(angle) 0; sind(angle) cosd(angle) 0; 0 0 1];
            
            % apply rotation transformation 
            transform = affine2d(transformMatrix);  
            transformedImage = imwarp(image, transform, 'OutputView', imref2d(size(image))); % rotate  image
            
            size_I1 = size(image); 
            updateSizeRotatedI1 = size(transformedImage);

            disp(['Rotation angle: ', num2str(angle), ' degrees']);
            disp(['Size of rotated image: ', num2str(updateSizeRotatedI1(1)), 'x', num2str(updateSizeRotatedI1(2))]);

            % set dynamic title
            plotTitle = ['Rotated by ', num2str(angle), '° ', ...
                         '(Original: ', num2str(size_I1(1)), 'x', num2str(size_I1(2)), ...
                         ', Rotated: ', num2str(updateSizeRotatedI1(1)), 'x', num2str(updateSizeRotatedI1(2)), ')'];

        case 'shear'
            % shear factors
            shearX = parameters.shearX;
            shearY = parameters.shearY;

            transformMatrix = [1 shearX 0; shearY 1 0; 0 0 1];

            % check validity of shear matrix
            if det(transformMatrix(1:2, 1:2)) == 0
                error('Invalid shear matrix: determinant is 0.');
            end

            % apply shear transformation 
            transform = affine2d(transformMatrix);
            transformedImage = imwarp(image, transform, 'OutputView', imref2d(size(image) * 2)); % double output size for shearing

            disp(['Shear Factors: Sx=', num2str(shearX), ', Sy=', num2str(shearY)]);

            % set dynamic title
            plotTitle = ['Sheared (Sx=', num2str(shearX), ', Sy=', num2str(shearY), ')'];

        case 'translate'
            % translation offsets
            translateX = parameters.translateX;
            translateY = parameters.translateY;

            transformMatrix = [1 0 0; 0 1 0; translateX translateY 1];

            % apply translation transformation 
            transform = affine2d(transformMatrix);
            outputRef = imref2d(size(image) * 2); 
            transformedImage = imwarp(image, transform, 'OutputView', outputRef);

            disp(['Translation Offsets: Tx=', num2str(translateX), ', Ty=', num2str(translateY)]);

            % set dynamic title
            plotTitle = ['Translated (Tx=', num2str(translateX), ', Ty=', num2str(translateY), ')'];

        case 'translateAndRotate'
            % translation and rotation parameters
            translateX = parameters.translateX;
            translateY = parameters.translateY;
            angle = parameters.angle;

            translationMatrix = [1 0 0; 0 1 0; translateX translateY 1];
            rotationMatrix = [cosd(angle) -sind(angle) 0; sind(angle) cosd(angle) 0; 0 0 1];
            transformMatrix = translationMatrix * rotationMatrix;

            % apply combined transformation 
            transform = affine2d(transformMatrix);
            outputRef = imref2d(size(image) * 2);
            transformedImage = imwarp(image, transform, 'OutputView', outputRef);

            disp(['Translation: Tx=', num2str(translateX), ', Ty=', num2str(translateY)]);
            disp(['Rotation angle: ', num2str(angle), ' degrees']);

            % set dynamic title
            plotTitle = ['Translated (Tx=', num2str(translateX), ', Ty=', num2str(translateY), ...
                         '), Rotated by ', num2str(angle), '°'];

        otherwise
            error('Unknown transformation type.');
    end
    % display original and transformed images
    figure;
    subplot(1, 2, 1);
    imshow(image);
    title('Original Image');
    axis image;

    subplot(1, 2, 2);
    imshow(transformedImage);
    title(plotTitle);
    axis image;
  
end  
%}



%{


% function to apply different transformations
function transformedImage = transformImage(image, transformationType, parameters)
    switch transformationType
        case 'scale'
           scaleFactor = parameters.scaleFactor;
           transformMatrix = [scaleFactor 0 0; 0 scaleFactor 0; 0 0 1];


           size_I1 = size(image); % size of original image
           scaledI1 = imresize(image, scaleFactor); % scale image
           updateSizeI1 = size(scaledI1); %  size scaled image

           disp(['Size of οriginal image: ', num2str(size_I1(1)), 'x', num2str(size_I1(2))]);
           disp(['Size of scaled image: ', num2str(updateSizeI1(1)), 'x', num2str(updateSizeI1(2))]);  

           figure;
           imshow(scaledI1);
           title(['Original(' num2str(size_I1(1)) 'x' num2str(size_I1(2)) '),Scaled (' num2str(updateSizeI1(1)) 'x' num2str(updateSizeI1(2)) ')']);
           axis image;
                       
         case 'rotate'
           angle = parameters.angle;
           transformMatrix = [cosd(angle) -sind(angle) 0; sind(angle) cosd(angle) 0; 0 0 1];

           rotatedI1 = imrotate(image, angle); 
           updateSizeRotatedI1 = size(rotatedI1);

           disp(['Rotation angle: ', num2str(angle), ' degrees']);
           disp(['Size of aotated image: ', num2str(updateSizeRotatedI1(1)), 'x', num2str(updateSizeRotatedI1(2))]);

           figure;
           imshow(rotatedI1);
           title(['Rotated Image (' num2str(updateSizeRotatedI1(1)) 'x' num2str(updateSizeRotatedI1(2)) '), Rotated by ' num2str(angle) '°']);
           axis image;

        case 'shear'
            shearX = parameters.shearX; 
            shearY = parameters.shearY;

            transformMatrix = [1 shearX 0; shearY 1 0; 0 0 1];
            if det(transformMatrix(1:2,1:2)) == 0
                error('Invalid shear matrix: determinant is 0.');
            end     
        
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

%}

%{
% function to apply different transformations
function transformedImage = transformImage(image, transformationType, parameters)

    if ~ischar(transformationType)
        error('transformationType must be a string, e.g., "scale", "rotate", etc.');
    end
    
    % switch case to handle transformation types
    switch transformationType
        case 'scale'
            % scaling transformation
            scaleFactor = parameters.scaleFactor;
            transformMatrix = [scaleFactor 0 0; 0 scaleFactor 0; 0 0 1];
            transformedImage = applyTransformation(image, transformMatrix);
            displayTransformationResult(image, transformedImage, 'Scaled Image');
        
        case 'rotate'
            % rotation transformation
            angle = parameters.angle;
            transformMatrix = [cosd(angle) -sind(angle) 0; sind(angle) cosd(angle) 0; 0 0 1];
            transformedImage = applyTransformation(image, transformMatrix);
            displayTransformationResult(image, transformedImage, ['Rotated Image (' num2str(angle) '°)']);
        
        case 'shear'
            % shearing transformation
            shearX = parameters.shearX;
            shearY = parameters.shearY;
            transformMatrix = [1 shearX 0; shearY 1 0; 0 0 1];
            % validate shear matrix
            if det(transformMatrix(1:2, 1:2)) == 0
                error('Invalid shear matrix: determinant is 0.');
            end
            transformedImage = applyTransformation(image, transformMatrix);
            displayTransformationResult(image, transformedImage, ['Sheared Image (sh_x = ' num2str(shearX) ', sh_y = ' num2str(shearY) ')']);
        
        case 'translate'
            % translation transformation
            translateX = parameters.translateX;
            translateY = parameters.translateY;
            transformMatrix = [1 0 0; 0 1 0; translateX translateY 1];
            transformedImage = applyTransformation(image, transformMatrix);
            displayTransformationResult(image, transformedImage, 'Translated Image');
        
        case 'translateAndRotate'
            % combined translation and rotation
            translateX = parameters.translateX;
            translateY = parameters.translateY;
            angle = parameters.angle;
            translationMatrix = [1 0 0; 0 1 0; translateX translateY 1];
            rotationMatrix = [cosd(angle) -sind(angle) 0; sind(angle) cosd(angle) 0; 0 0 1];
            transformMatrix = translationMatrix * rotationMatrix;
            transformedImage = applyTransformation(image, transformMatrix);
            displayTransformationResult(image, transformedImage, ['Translated and Rotated Image (' num2str(angle) '° rotation)']);
        
        otherwise
            error('Unknown transformation type.');
    end
end

% function to apply affine transformation
function transformedImage = applyTransformation(image, transformMatrix)
    % apply affine transformation with automatic output view adjustment
    transform = affine2d(transformMatrix);
    transformedImage = imwarp(image, transform, 'OutputView', imref2d(size(image)));
end

% function to display transformation 
function displayTransformationResult(originalImage, transformedImage, titleText)
    figure;
    subplot(1, 2, 1);
    imshow(originalImage);
    title('Original Image');
    subplot(1, 2, 2);
    imshow(transformedImage);
    title(titleText);
end

%}
%{
function transformedImage = transformImage(image, ~, parameters)
    switch transformationType
        %initialize  transform matrix
        transformMatrix = eye(3);
        case 'scale'
            scaleFactor = parameters.scaleFactor;
            transformMatrix = [scaleFactor 0 0; 0 scaleFactor 0; 0 0 1];

            % display scaled image
            size_I1 = size(image);
            scaledI1 = imresize(image, scaleFactor);
            updateSizeI1 = size(scaledI1);
            disp(['Size of I1: ', num2str(size_I1)]);
            disp(['Size of updated I1: ', num2str(updateSizeI1)]);  
            figure;
            imshow(scaledI1);
            title(['Scaled Image (' num2str(updateSizeI1(1)) 'x' num2str(updateSizeI1(2)) ')']);
            axis image;

        case 'rotate'
            angle = parameters.angle;
            transformMatrix = [cosd(angle) -sind(angle) 0; sind(angle) cosd(angle) 0; 0 0 1];
            figure;
            imshow(rotatedI1);
            title(['Rotated Image (' num2str(updateSizeRotatedI1(1)) 'x' num2str(updateSizeRotatedI1(2)) ')']);
            axis image;

            figure;
            imshow(rotatedI2);
            title(['Rotated Image (' num2str(updateSizeRotatedI1(1)) 'x' num2str(updateSizeRotatedI1(2)) ')']);
            axis image;
        
        case 'shear'
            shearX = parameters.shearX; 
            shearY = parameters.shearY;

            transformMatrix = [1 shearX 0; shearY 1 0; 0 0 1];
            if det(transformMatrix(1:2,1:2)) == 0
                error('Invalid shear matrix: determinant is 0.');
            end     

            figure;
            imshow(shearedI1);
            title(['Sheared Image (sh_x = ', num2str(parameters.shearX), ', sh_y = ', num2str(parameters.shearY), ')']);
        
        case 'translate'
            translateX = parameters.translateX;
            translateY = parameters.translateY;
            transformMatrix = [1 0 0; 0 1 0; translateX translateY 1];

            I1_ref = imref2d(size(I1)); % spatial reference for the original image

            % adjust coordinate limits for translated image
            translatedI1_ref = I1_ref;
            translatedI1_ref.XWorldLimits(2) = translatedI1_ref.XWorldLimits(2) + parameters.translateX;
            translatedI1_ref.YWorldLimits(2) = translatedI1_ref.YWorldLimits(2) + parameters.translateY;

            figure;
            subplot(1, 2, 1);
            imshow(I1, I1_ref);
            title('Original Image');
            subplot(1, 2, 2);
            imshow(translatedI1, translatedI1_ref);
            title('Translated Image');
         
        case 'translateAndRotate'
            translateX = parameters.translateX;
            translateY = parameters.translateY;
            angle = parameters.angle;
            translationMatrix = [1 0 0; 0 1 0; translateX translateY 1];
            rotationMatrix = [cosd(angle) -sind(angle) 0; sind(angle) cosd(angle) 0; 0 0 1];
            transformMatrix = translationMatrix * rotationMatrix;
        
                % adjust coordinate limits for  combined transformation
           [rows, cols, ~] = size(translatedAndRotatedI1);
           translatedAndRotatedI1_ref = imref2d([rows, cols]);
        translatedAndRotatedI1_ref.XWorldLimits = [1, cols];
translatedAndRotatedI1_ref.YWorldLimits = [1, rows];

figure;
subplot(1, 2, 1);
imshow(I1, I1_ref); 
title('Original Image');
subplot(1, 2, 2);
imshow(translatedAndRotatedI1, translatedAndRotatedI1_ref);
title(['Translated and Rotated Image (' num2str(parameters.angle) '° rotation)']);

        otherwise
            error('Unknown transformation type.');
    end
    
    % apply affine transformation
    transform = affine2d(transformMatrix);
    transformedImage = imwarp(image, transform);
end
%}
