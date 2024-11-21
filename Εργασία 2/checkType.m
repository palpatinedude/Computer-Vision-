% define type of image
function checkType(I)
    dims = length(size(I));
    disp(dims);
    disp(['Dimensions: ', num2str(dims)]);

    % if it's 2D image
   if dims == 2
    if islogical(I) 
        disp('Is binary image only black (0) and white (1).');
    else
        disp('Is grayscale image.');
    end

    % if it's  3D image 
  elseif dims == 3
        if size(I, 3) == 3
            disp('Is RGB image');
        else
            disp('3D image but not RGB');
        end
    else
        disp('The image has unexpected dimensions.');
    end

      % check image type
    if isa(image, 'uint8')
        disp('Image Type: uint8');
    elseif isa(image, 'uint16')
        disp('Image Type: uint16');
    elseif isa(image, 'double')
        disp('Image Type: double');
    else
        disp(['Image Type: ', class(image)]);
    end
end