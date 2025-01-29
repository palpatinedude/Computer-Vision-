% main goal of this part is to combine multiple scaled versions of the image

% function to execute the 2nd part of the procedure
function part2(img,direction)

  % Define scaling factors
  scales = [2.5, 1.2, 1.5, 3.2];

  for i = 1:length(scales)
     for j = 1:length(scales)-i
        if scales(j) > scales(j+1)  
          temp = scales(j);
          scales(j) = scales(j+1); 
          scales(j+1) = temp;
         
       end
    end
  end

  % create the composite image with scaled versions
  compositeImg = compositeImage(img, scales,direction);

  % display the result
  figure;
  imshow(compositeImg);
  title('Composite image with multiple scales');
  
end

% function to create a composite image by concatenating scaled images based on the direction (either 'horizontal' or 'vertical')
function compositeImg = compositeImage(image, scales, direction)
    total_width = 0;
    total_height = 0;
    scaled_images = cell(1, length(scales));
    
    max_width = 0;
    max_height = 0;

    % scale each image and calculate total width and height based on direction
    for i = 1:length(scales)
        parameters.scaleFactor = scales(i);
        scaled_images{i} = transformImage(image, 'scale', parameters, 0);
        
        [h, w, ~] = size(scaled_images{i});
        
        % update total width and height 
        max_width = max(max_width, w);
        max_height = max(max_height, h);
        
        % update total width or total height 
        if strcmp(direction, 'horizontal')
            total_width = total_width + w;
        elseif strcmp(direction, 'vertical')
            total_height = total_height + h;
        end
    end
    
    % preallocate for composite image
    if strcmp(direction, 'horizontal')
        compositeImg = zeros(max_height, total_width, size(image, 3), 'like', image);
    elseif strcmp(direction, 'vertical')
        compositeImg = zeros(total_height, max_width, size(image, 3), 'like', image);
    end
    
    % concatenate scaled images
    current_width = 1;
    current_height = 1;
    for i = 1:length(scaled_images)
        scaled_img = scaled_images{i};
        [h, w, ~] = size(scaled_img);
        
        if strcmp(direction, 'horizontal')
            compositeImg(1:h, current_width:current_width+w-1, :) = scaled_img;
            current_width = current_width + w;
        elseif strcmp(direction, 'vertical')
            compositeImg(current_height:current_height+h-1, 1:w, :) = scaled_img;
            current_height = current_height + h;
        end
    end
end

%{

% function to create a composite image by concatenating scaled images
function compositeImg = compositeImage(image,scales)
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
        current_width = current_width+w;

 
    end
end
%}