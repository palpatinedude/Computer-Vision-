% function to display transformation details
function plotTitle = displayTransDetails(transformationType, parameters, originalSize, transformedSize)
    disp([upper(transformationType), ' Transformation']);
    disp(['Original size: ', num2str(originalSize(1)), 'x', num2str(originalSize(2))]);
    disp(['Transformed size: ', num2str(transformedSize(1)), 'x', num2str(transformedSize(2))]);

    % dynamic title generation
    if strcmp(transformationType, 'scale')
        plotTitle = ['Scaled by ', num2str(parameters.scaleFactor)];
    elseif strcmp(transformationType, 'rotate')
        plotTitle = ['Rotated by ', num2str(parameters.angle), '° '];
    elseif strcmp(transformationType, 'shear')
        plotTitle = ['Sheared (Sx=', num2str(parameters.shearX), ', Sy=', num2str(parameters.shearY), ')'];
    elseif strcmp(transformationType, 'translate')
        plotTitle = ['Translated (Tx=', num2str(parameters.translateX), ', Ty=', num2str(parameters.translateY), ')'];
    elseif strcmp(transformationType, 'translateRotate')
        plotTitle = ['Translated (Tx=', num2str(parameters.translateX), ', Ty=', num2str(parameters.translateY), ...
                     '), Rotated by ', num2str(parameters.angle), '°'];
    else
        plotTitle = 'Unknown Transformation';
    end
end