%{
function processFrames(videoWriter, bg, scaledWindmill, scaledMask, displacement, parameters, originalParam, method)
    numFrames = originalParam.NumFrames;
    rotationStep = 360 / numFrames; % Degrees per frame

    for frame = 1:numFrames
        
        parameters.angle = rotationStep * (frame - 1); % Update the rotation angle
        
        if isempty(method)
            % If method is empty, use the default transformImage behavior
            rotatedWindmill = transformImage(scaledWindmill, 'rotate', parameters, 0);
            rotatedMask = transformImage(scaledMask, 'rotate', parameters, 0);
        else
            % If method is not empty, use the specified interpolation method
            rotatedWindmill = imrotate(scaledWindmill, parameters.angle, method,'crop');
            rotatedMask = imrotate(scaledMask, parameters.angle, method,'crop');
            
            scaledWindmill = imresize(scaledWindmill, parameters.scaleFactor, method);
            scaledMask = imresize(scaledMask, parameters.scaleFactor, method);
        end

        [rotatedWindmillHeight, rotatedWindmillWidth, ~] = size(rotatedWindmill);
        [maskHeight, maskWidth, ~] = size(rotatedMask);
        
        % Resize the mask to match the rotated windmill size
        if rotatedWindmillHeight ~= maskHeight || rotatedWindmillWidth ~= maskWidth
            rotatedMask = imresize(rotatedMask, [rotatedWindmillHeight, rotatedWindmillWidth]);
        end  

        % Apply Gaussian smoothing to the mask for better blending
        alphaChannel = createAlpha(rotatedMask);

        % Blend the images
        blendedImage = blendImages(bg, rotatedWindmill, alphaChannel, displacement);

        % Resize and write to video
        blendedImage = imresize(blendedImage, [originalParam.Resolution(2), originalParam.Resolution(1)]);
        writeVideo(videoWriter, blendedImage);
    end
end
%}

function processFrames(videoWriter, bg, scaledWindmill, scaledMask, displacement, parameters, originalParam, method)
    numFrames = originalParam.NumFrames;
    rotationStep = 360 / numFrames; % Degrees per frame

    for frame = 1:numFrames
        
        parameters.angle = rotationStep * (frame - 1); % Update the rotation angle
        
        % Apply rotation and interpolation logic
        if isempty(method)
            % If method is empty, use the default transformImage behavior
            rotatedWindmill = transformImage(scaledWindmill, 'rotate', parameters, 0);
            rotatedMask = transformImage(scaledMask, 'rotate', parameters, 0);
        else
            % Rotate the windmill using imrotate and the specified interpolation method
            rotatedWindmill = imrotate(scaledWindmill, parameters.angle, method, 'crop');
    
            % Rotate the mask using imrotate and the same interpolation method
            rotatedMask = imrotate(scaledMask, parameters.angle, method, 'crop');
        end

        % Resize mask to match the rotated windmill size
        [rotatedWindmillHeight, rotatedWindmillWidth, ~] = size(rotatedWindmill);
        [maskHeight, maskWidth, ~] = size(rotatedMask);
        
        if rotatedWindmillHeight ~= maskHeight || rotatedWindmillWidth ~= maskWidth
            rotatedMask = imresize(rotatedMask, [rotatedWindmillHeight, rotatedWindmillWidth]);
        end  

        % Apply Gaussian smoothing to the mask for better blending
        alphaChannel = createAlpha(rotatedMask);

        % Blend the images
        blendedImage = blendImages(bg, rotatedWindmill, alphaChannel, displacement);

        % Resize and write to video
        blendedImage = imresize(blendedImage, [originalParam.Resolution(2), originalParam.Resolution(1)]);
        writeVideo(videoWriter, blendedImage);
    end
end

function alphaChannel = createAlpha(rotatedMask)
    % Create alpha channel by identifying non-black pixels
    alphaChannel = any(rotatedMask > 0, 3);  % Non-black pixels are opaque
    alphaChannel = im2double(alphaChannel);  % Convert to double for blending
    alphaChannel = imgaussfilt(alphaChannel, 5);  % Apply Gaussian smoothing to the alpha channel
end


function combinedImg = blendImages(bg, fg, alpha, displacement)
    % Get the size of the foreground (rotated windmill) and background
    [fgHeight, fgWidth, ~] = size(fg);
    [bgHeight, bgWidth, ~] = size(bg);
    
    % Calculate the start position for placing the windmill on the background
    % based on the displacement (anchor point)
    rowStart = round(displacement(2) - fgHeight / 2);
    colStart = round(displacement(1) - fgWidth / 2);

    % Ensure the region stays within the background bounds
    rowStart = max(rowStart, 1);
    colStart = max(colStart, 1);
    rowEnd = min(rowStart + fgHeight - 1, bgHeight);
    colEnd = min(colStart + fgWidth - 1, bgWidth);

    % Adjust the foreground and alpha regions to fit within the cropped area
    fgRegion = fg(1:(rowEnd - rowStart + 1), 1:(colEnd - colStart + 1), :);
    alphaRegion = alpha(1:(rowEnd - rowStart + 1), 1:(colEnd - colStart + 1));

    % Extract the corresponding region of the background
    bgRegion = bg(rowStart:rowEnd, colStart:colEnd, :);

   % Perform alpha blending
    combinedImg = bg;  % Initialize combined image
     alphaRegion = uint8(alphaRegion);

    for c = 1:3
        combinedImg(rowStart:rowEnd, colStart:colEnd, c) = ...
            (alphaRegion) .* fgRegion(:, :, c) + ...
            (1 - alphaRegion) .* bgRegion(:, :, c);
    end
end