function binImg3D = preprocessMask(mask)
    grayImg = rgb2gray(uint8(mask)); 
    binImg = imbinarize(grayImg); 
    binImg = ~binImg;  
    binImg3D = repmat(binImg, [1, 1, 3]); 
end