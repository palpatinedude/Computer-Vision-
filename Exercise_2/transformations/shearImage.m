% applies horizontal or vertical shear to an image
function transformedImage = shearImage(image, parameters)

    shearX = parameters.shearX;
    shearY = parameters.shearY;

    % create shear affine matrix
    transformMatrix = [1 shearX 0; shearY 1 0; 0 0 1];
    transform = affine2d(transformMatrix);

    % apply transformation while keeping original image size
    R = imref2d(size(image));  % keeps size constant for animation
    transformedImage = imwarp(image, transform, 'OutputView', R);

end