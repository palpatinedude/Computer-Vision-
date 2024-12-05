% function to create a composite image by concatenating scaled images
function compositeImg = compositeImage(image, scales)
    total_width = 0;
    scaled_images = cell(1, length(scales));
    
    % scale each image and calculate total width
    for i = 1:length(scales)
        parameters.scaleFactor = scales(i);
        scaled_images{i} = transformImage(image, 'scale', parameters,0);
        total_width = total_width + size(scaled_images{i}, 2);
    end
    
    % preallocate composite image
    max_height = size(image, 1);
    compositeImg = zeros(max_height, total_width, size(image, 3), 'like', image);
    
    % concatenate scaled images
    current_width = 1;
    for i = 1:length(scaled_images)
        scaled_img = scaled_images{i};
        [h, w, ~] = size(scaled_img);
        compositeImg(1:h, current_width:current_width+w-1, :) = scaled_img;
        current_width = current_width + w;
    end
end