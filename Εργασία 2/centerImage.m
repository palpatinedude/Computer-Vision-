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