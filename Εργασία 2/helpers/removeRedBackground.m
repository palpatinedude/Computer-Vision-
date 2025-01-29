function imgNoRed = removeRedBackground(img)
    img = im2double(img);  
    redMask = (img(:, :, 1) > 0.8 & img(:, :, 2) < 0.2 & img(:, :, 3) < 0.2);
    imgNoRed = img .* repmat(1 - double(redMask), [1, 1, 3]);
    imgNoRed = im2uint8(imgNoRed); 
end
