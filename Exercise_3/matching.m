%% This function performs feature matching between two images using
function [p1, p2] = matching(keypoints1, descriptors1, keypoints2, descriptors2)

    % Isolate the (x, y) coordinates for geometric mapping later
    keypoints1_pts = keypoints1(:, 1:2);
    keypoints2_pts = keypoints2(:, 1:2);
    
    fprintf('Keypoints in Image 1: %d\n', size(keypoints1,1));
    fprintf('Keypoints in Image 2: %d\n', size(keypoints2,1));

    % Euclidean distance and Lowe ratio test
    % We need to find which descriptor in img1 is most similar to one in img2
    fprintf('Computing Manual Euclidean Distances...\n');
    
    n1 = size(descriptors1, 1);
    n2 = size(descriptors2, 1);
    
    % Initialize arrays to store valid match indices
    matches_idx = [];
    best_matches_in_2 = [];
    
    % This handles ambiguous matches by ensuring the best match is significantly
    % better than the second best match
    ratio_thresh = 0.7;
    
    % Precalculate squared norms to speed up the distance formula
    norm1 = sum(descriptors1.^2, 2); % (n1 x 1)
    norm2 = sum(descriptors2.^2, 2); % (n2 x 1)
    

    % Iterate through every descriptor in the first image
    for i = 1:n1
        % Euclidean distance calculation using matrix operations for speed
        dists_sq = max(0, norm1(i) + norm2' - 2 * (descriptors1(i, :) * descriptors2'));
        dists = sqrt(dists_sq);
        
        % Sort distances to find the two closest neighbors in image 2
        [sorted_dists, sorted_idx] = sort(dists, 'ascend');
        
        d1 = sorted_dists(1); % Closest neighbor (best match candidate)
        d2 = sorted_dists(2); % Second closest neighbor
        
        % Lowe's ratio test
        % If the best match isn't much better than the second best, it's likely 
        % a repetitive pattern and should be discarded
        if d1 < ratio_thresh * d2
            matches_idx = [matches_idx; i];
            best_matches_in_2 = [best_matches_in_2; sorted_idx(1)];
        end
    end
    

    num_pts = length(matches_idx);
    
    % Extract the paired coordinates for the matched points
    p1 = keypoints1_pts(matches_idx, :);
    p2 = keypoints2_pts(best_matches_in_2, :);
    
    fprintf('Total Initial Matches: %d\n', num_pts);

end
