% image conversion function
function convertImage(I)
    % check dimensions of the image
    dims = length(size(I));

    if dims == 3  % if the image is RGB
        % convert RGB to grayscale
        grayI = rgb2gray(I);
        disp('converted to grayscale from RGB');

        % convert grayscale to binary
        binaryI = imbinarize(grayI);  % first normalize and then put the threshold
        disp('converted to binary');
        
        % plot RGB, grayscale, and binary images
        figure;
        subplot(1, 3, 1); % first subplot
        imshow(I);
        title('RGB image');

        subplot(1, 3, 2); % second subplot
        imshow(grayI);
        title('grayscale image');

        subplot(1, 3, 3); % third subplot
        imshow(binaryI);
        title('binary image');

        % plot histograms
        figure;
        subplot(1, 2, 1); 
        histogram(grayI);
        title('histogram of grayscale image');
        
        subplot(1, 2, 2); 
        histogram(binaryI);
        title('histogram of binary image');

    elseif dims == 2  % if the image is already grayscale
        disp('already grayscale');
        
        % convert grayscale to binary
        binaryI = imbinarize(I);  
        disp('converted to binary');
        
        % plot grayscale and binary images
        figure;
        subplot(1, 2, 1); % first subplot
        imshow(I);
        title('grayscale image');
        
        subplot(1, 2, 2); % second subplot
        imshow(binaryI);
        title('binary image');

        % plot histograms
        figure;
        subplot(1, 2, 1); 
        histogram(I);
        title('histogram of grayscale image');
        
        subplot(1, 2, 2); 
        histogram(binaryI);
        title('histogram of binary image');
        
    else
        disp('unsupported image dimensions.');
    end
end
