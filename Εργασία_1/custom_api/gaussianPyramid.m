function G = gaussianPyramid(x, L)
    x = x(:);  % ensure input is a column vector
    
    % Initialize cell array to store pyramid
    G = cell(L+1,1);  
    G{1} = x;  % finest level is the original image

    % Build pyramid by repeatedly reducing the image
    for j = 1:L
        x = gaussianReduce(x);  % reduce to next coarser level
        G{j+1} = x;            % store in pyramid
    end
end
