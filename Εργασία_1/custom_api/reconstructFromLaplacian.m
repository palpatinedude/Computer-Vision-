function G0 = reconstructFromLaplacian(L)
    % Get the number of laplacian levels (excluding the smallest level)
    L_levels = length(L) - 1;
    
    % Start from the smallest level (coarsest image)
    G = L{end};  
    
    % Loop from the coarsest to the finest level
    for j = L_levels:-1:1
        % Expand the current image to the next finer level
        G = gaussianExpand(G);  
        
        % Calculate the size difference between laplacian level and expanded image
        len_diff = length(L{j}) - length(G);
        
        % If expanded image is smaller, pad with zeros
        if len_diff > 0
            G = [G; zeros(len_diff,1)];
        % If expanded image is larger, crop it
        elseif len_diff < 0
            G = G(1:length(L{j}));
        end
        
        % Add the laplacian detail of the current level
        G = G + L{j};  
    end
    
    % Return the reconstructed image
    G0 = G;  
end
