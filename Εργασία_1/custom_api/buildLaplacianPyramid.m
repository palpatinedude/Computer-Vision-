function L = buildLaplacianPyramid(G)
    % Number of laplacian levels (excluding the smallest level)
    L_levels = length(G) - 1;
    
    % Initialize cell array to store laplacian pyramid
    L = cell(L_levels+1,1);
    
    % Loop through all levels except the smallest
    for j = 1:L_levels
        % Expand the next coarser level
        Gj_up = gaussianExpand(G{j+1});  
        
        % Compute length difference between current level and expanded
        len_diff = length(G{j}) - length(Gj_up);
        
        % If expanded is smaller, pad with zeros
        if len_diff > 0
            Gj_up = [Gj_up; zeros(len_diff,1)];
        % If expanded is larger, crop it
        elseif len_diff < 0
            Gj_up = Gj_up(1:length(G{j}));
        end
        
        % Subtract expanded coarser level to get laplacian detail
        L{j} = G{j} - Gj_up;  
    end
    
    % Smallest level remains the same (coarsest image)
    L{end} = G{end};
end
