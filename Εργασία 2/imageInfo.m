% function of  basic preprocessing an image 
function imageInfo(image)

    sizeInfo = size(image);
    disp(['Size of Image: ', num2str(sizeInfo)]);

    % check image type 
    checkType(image);


    % original image
    figure;
    imshow(image);
    title(['Original Image ']);

    % convert to different formats 
 %   convertImage(image);
end