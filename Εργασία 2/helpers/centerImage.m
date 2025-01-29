

% function to center transformed image on a blank canvas
function centeredImage = centerImage(originalSize, transformedImage)
    rowsO = originalSize(1);
    colsO = originalSize(2);
    if length(originalSize) < 3
        channelsO = 1; 
        disp('Grayscale .');
    else
        channelsO = originalSize(3); 
    end

    % get transformed image dimensions
    [rowsT, colsT, ~] = size(transformedImage);


    % create blank canvas 
    centeredImage = zeros(rowsO, colsO, channelsO, 'like', transformedImage);

    % calculate position to center the transformed image on the canvas
    rowStart = max(round((rowsO - rowsT) / 2),1);
    colStart = max(round((colsO - colsT) / 2),1);
 
    % prevent exceeding canvas size
    rowEnd = min(rowsO, rowStart + rowsT - 1); 
    colEnd = min(colsO, colStart + colsT - 1); 

    % place  transformed image into the centered canvas
    centeredImage(rowStart:rowEnd, colStart:colEnd, :) = transformedImage(1:(rowEnd - rowStart + 1), 1:(colEnd - colStart + 1), :);

end


%{
% Function to center the transformed image on a blank canvas of the original size
function centeredImage = centerImage(originalSize, transformedImage)
    % Ensure that originalSize is not empty and has the correct number of dimensions
    if isempty(originalSize) || length(originalSize) < 2
        error('Original size must have at least two dimensions (height and width).');
    end
    
    % Get the dimensions of the original image
    rowsO = originalSize(1); % height of the original image
    colsO = originalSize(2); % width of the original image
    
    % Check for channels, assuming grayscale if no third dimension exists
    if length(originalSize) < 3
        channelsO = 1; % Grayscale
        disp('Grayscale image detected.');
    else
        channelsO = originalSize(3); % Color image
    end

    % Get the dimensions of the transformed image
    [rowsT, colsT, ~] = size(transformedImage);

    % Create a blank canvas with the same size as the original image
    centeredImage = zeros(rowsO, colsO, channelsO, 'like', transformedImage);

    % Calculate the position to center the transformed image on the canvas
    rowStart = max(round((rowsO - rowsT) / 2), 1);
    colStart = max(round((colsO - colsT) / 2), 1);

    % Prevent the transformed image from exceeding the canvas boundaries
    rowEnd = min(rowsO, rowStart + rowsT - 1);
    colEnd = min(colsO, colStart + colsT - 1);

    % Place the transformed image onto the canvas at the calculated position
    centeredImage(rowStart:rowEnd, colStart:colEnd, :) = transformedImage(1:(rowEnd - rowStart + 1), 1:(colEnd - colStart + 1), :);
end
%}
