%% Sift Implementation Based on Lowe's Original Paper
function [keypoints, descriptors] = sift(img_input)
    % Parameters
    sigma0 = 1.6;            % Initial blur level
    num_octaves = 4;        % Number of times the image is downsampled
    num_levels = 3;         % Number of scale levels per octave
    contrast_threshold = 0.01; % Decides whether a feature in an image
    edge_threshold = 10;    % Ratio to filter out points on edges (Hessian matrix)
    d = 4;                  % 4x4 grid cells for the descriptor
    n_bins = 8;             % 8 orientation bins per cell (4*4*8 = 128 dimensions)
    
    % Pre processing
    img = im2double(img_input);
    if size(img,3) == 3, img = rgb2gray(img); end
    
    % Upsample the image by 2x. This increases the number of stable keypoints 
    % by capturing higher frequency information before the first smoothing
    img = imresize(img, 2, 'bicubic');

    % Apply initial blur
    img = imgaussfilt(img, sqrt(sigma0^2 - (0.5*2)^2)); 
    
    % Constructing the gaussian & DoG pyramid
    % SIFT finds features across scales
    % blurring and subtracting adjacent blurs 
    G = cell(num_octaves, 1); % Stores Gaussian blurred images
    D = cell(num_octaves, 1); % Stores DoG images
    temp_img = img;
    
    

    for o = 1:num_octaves
        [h, w] = size(temp_img);
        L = zeros(h, w, num_levels + 3);
        DoG = zeros(h, w, num_levels + 2);
        for l = 1:num_levels + 3
            % Calculate specific sigma for this scale level
            sig = sigma0 * 2^((l-1)/num_levels);
            L(:,:,l) = imgaussfilt(temp_img, sig);
            if l > 1
                % DoG is an approximation of the Laplacian of Gaussian (blob detector)
                DoG(:,:,l-1) = L(:,:,l) - L(:,:,l-1);
            end
        end
        G{o} = L; D{o} = DoG;
        % Prepare image for next octave by downsampling the middle level
        temp_img = imresize(L(:,:,num_levels+1), 0.5, 'nearest');
    end
    
    % Keypoint detection & localization
    raw_kp = [];
    for o = 1:num_octaves
        [H, W, Ls] = size(D{o});
        % Iterate through scales and pixels (skipping boundaries)
        for l = 2:Ls-1
            for x = 15:H-15
                for y = 15:W-15
                    % Check 26 neighbors
                    patch = D{o}(x-1:x+1, y-1:y+1, l-1:l+1);
                    val = D{o}(x,y,l);
                    
                    % Ignore weak low contrast points
                    if abs(val) < 0.8 * contrast_threshold, continue; end
                    
                    % Find local extrema
                    if val == max(patch(:)) || val == min(patch(:))
                        % Subpixel Taylor Expansion
                        % Uses derivatives to find the true peak between pixels
                        dx = (D{o}(x+1,y,l)-D{o}(x-1,y,l))/2;
                        dy = (D{o}(x,y+1,l)-D{o}(x,y-1,l))/2;
                        ds = (D{o}(x,y,l+1)-D{o}(x,y,l-1))/2;
                        
                        Dxx = D{o}(x+1,y,l)+D{o}(x-1,y,l)-2*val;
                        Dyy = D{o}(x,y+1,l)+D{o}(x,y-1,l)-2*val;
                        Dss = D{o}(x,y,l+1)+D{o}(x,y,l-1)-2*val;
                        Dxy = (D{o}(x+1,y+1,l)-D{o}(x+1,y-1,l)-D{o}(x-1,y+1,l)+D{o}(x-1,y-1,l))/4;
                        Dxs = (D{o}(x+1,y,l+1)-D{o}(x+1,y,l-1)-D{o}(x-1,y,l+1)+D{o}(x-1,y,l-1))/4;
                        Dys = (D{o}(x,y+1,l+1)-D{o}(x,y+1,l-1)-D{o}(x,y-1,l+1)+D{o}(x,y-1,l-1))/4;
                        
                        H_mat = [Dxx Dxy Dxs; Dxy Dyy Dys; Dxs Dys Dss];
                        if det(H_mat) == 0, continue; end
                        offset = -H_mat \ [dx; dy; ds]; % Solve for precise location
                        
                        % If offset is small enough, the point is stable
                        if max(abs(offset)) < 0.5
                            % Edge Rejection 
                            % Removes points that are sharp in one direction but flat 
                            % in another (like a line), which are poor for matching.
                            tr = Dxx + Dyy; detH = Dxx*Dyy - Dxy^2;
                            if detH > 0 && (tr^2/detH) < (edge_threshold+1)^2/edge_threshold
                                raw_kp = [raw_kp; o, l, x+offset(1), y+offset(2)];
                            end
                        end
                    end
                end
            end
        end
    end
    
    % Orientation assigment
    keypoints = []; descriptors = [];
    for i = 1:size(raw_kp,1)
        o = raw_kp(i,1); l = round(raw_kp(i,2)); x = raw_kp(i,3); y = raw_kp(i,4);
        scale = sigma0 * 2^((l-1)/num_levels);
        
        % Calculate a gradient histogram around the keypoint
        hist = zeros(1, 36);
        radius = round(3 * 1.5 * scale);
        for dx = -radius:radius
            for dy = -radius:radius
                px = round(x+dx); py = round(y+dy);
                if px<2 || px>size(G{o},1)-1 || py<2 || py>size(G{o},2)-1, continue; end
                % Gradient magnitude and direction
                gx = G{o}(px+1,py,l)-G{o}(px-1,py,l);
                gy = G{o}(px,py+1,l)-G{o}(px,py-1,l);
                mag = sqrt(gx^2+gy^2) * exp(-(dx^2+dy^2)/(2*(1.5*scale)^2));
                theta = mod(atan2d(gy,gx), 360);
                % Sort into 36 bins (10 degrees each)
                bin = min(floor(theta/10)+1, 36);
                hist(bin) = hist(bin) + mag;
            end
        end
        
        % Identify peak orientation
        [max_v, main_bin] = max(hist);
        % Parabolic fit for precise orientation
        l_idx = mod(main_bin-2,36)+1; r_idx = mod(main_bin,36)+1;
        dist_off = 0.5*(hist(l_idx)-hist(r_idx))/(hist(l_idx)-2*max_v+hist(r_idx)+eps);
        final_ori = mod((main_bin-1 + dist_off)*10, 360);
        
        % Descriptor generation
        % Create the 128D vector based on the local 4x4 grid
        d_vec = compute_trilinear_descriptor(G{o}(:,:,l), x, y, final_ori, scale, d, n_bins);
        
        % Rescale coordinates back to the original image dimensions
        keypoints = [keypoints; (y*2^(o-1))/2, (x*2^(o-1))/2, scale, final_ori];
        descriptors = [descriptors; d_vec];
    end
end

 % This function creates a feature vector that is invariant to rotation and illumination
function desc = compute_trilinear_descriptor(img_l, x, y, ori, scale, d, n_bins)
    [H, W] = size(img_l);
    hist_grid = zeros(d, d, n_bins);
    cos_t = cosd(-ori); sin_t = sind(-ori); % Rotation to achieve rotation invariance
    
    cell_size = scale * 3;
    radius = round(sqrt(2) * cell_size * (d + 1) / 2);
    desc_sigma = d / 2; % Gaussian weight for the descriptor window
    
    for dx = -radius:radius
        for dy = -radius:radius
            % Rotate local coordinates relative to keypoint orientation
            rx = cos_t * dx - sin_t * dy;
            ry = sin_t * dx + cos_t * dy;
            
            % Normalize position within the 4x4 grid
            nx = rx / cell_size;
            ny = ry / cell_size;
            bin_x = nx + d/2 - 0.5;
            bin_y = ny + d/2 - 0.5;
            
            % Check if pixel falls inside the descriptor window
            if bin_x > -1 && bin_x < d && bin_y > -1 && bin_y < d
                px = round(x + dx); py = round(y + dy);
                if px<2 || px>H-1 || py<2 || py>W-1, continue; end
                
                % Gradient calculation
                gx = img_l(px+1, py) - img_l(px-1, py);
                gy = img_l(px, py+1) - img_l(px, py-1);
                mag = sqrt(gx^2+gy^2) * exp(-(nx^2+ny^2)/(2*desc_sigma^2));
                theta = mod(atan2d(gy,gx) - ori, 360);
                bin_ori = (theta / 360) * n_bins;
                
                % Trilinear interpolation: 
                % Distribute the gradient magnitude into neighboring bins 
                % to prevent sudden changes if a feature moves slightly
                for x_off = 0:1
                    x_idx = floor(bin_x) + x_off;
                    if x_idx < 0 || x_idx >= d, continue; end
                    wx = 1 - abs(bin_x - x_idx);
                    for y_off = 0:1
                        y_idx = floor(bin_y) + y_off;
                        if y_idx < 0 || y_idx >= d, continue; end
                        wy = 1 - abs(bin_y - y_idx);
                        for o_off = 0:1
                            o_idx = mod(floor(bin_ori) + o_off, n_bins);
                            wo = 1 - abs(bin_ori - (floor(bin_ori) + o_off));
                            
                            hist_grid(x_idx+1, y_idx+1, o_idx+1) = ...
                                hist_grid(x_idx+1, y_idx+1, o_idx+1) + mag * wx * wy * wo;
                        end
                    end
                end
            end
        end
    end
    
    % Final normalization and clipping to reduce effects of lighting changes
    desc = reshape(hist_grid, 1, 128);
    desc = desc / (norm(desc) + eps);
    desc(desc > 0.2) = 0.2; 
    desc = desc / (norm(desc) + eps);
end