% Function to rotate the windmill blades with the mask
function rotatedWindmill = rotateMill(windmill, mask, angle)
    % Use the rotateImage function to rotate the blades
    % The `parameters` structure will hold the rotation angle
    
    parameters.angle = angle;
    
    % Call the rotateImage function from transformations folder
    rotatedWindmill = rotateImage(windmill, parameters);
    
    % Apply the mask to the rotated image (only rotating the blades, not the background)
    rotatedWindmill = bsxfun(@times, rotatedWindmill, cast(mask, 'like', rotatedWindmill)); % Apply the mask
end