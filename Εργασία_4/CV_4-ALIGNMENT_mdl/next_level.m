%% This script update warp parameters between pyramid levels for affine and homography transforms.
function warp2 = next_level(warp, transform, dir)
    switch lower(transform)
        case 'affine'
            % warp(1:2,1:2) stores A_inc = A - I
            % Why store A_inc = A - I?
            % - That lets the algorithm linearize around "no motion"
            
            % warp(1:2,3)   stores translation t in pixels

            % Linear part (dimensionless, unchanged)
            A_inc = warp(1:2,1:2);

            % Translation (depends on pixel scale)
            t = warp(1:2,3);

            % Rescale translation when changing pyramid level
            if dir == 0
                t = t / 2;    % coarser level
            else
                t = t * 2;    % finer level
            end

            % Build updated warp
            warp2 = warp;
            warp2(1:2,1:2) = A_inc;
            warp2(1:2,3)   = t;
            warp2(3,:)     = 0;

        case 'homography'
            % Coordinate change must preserve the same physical mapping:
            % H_level = inv(S) * H * S

            if dir == 0
                s = 0.5;      % coarser level
            else
                s = 2.0;      % finer level
            end

            % Coordinate scaling matrix
            S = [s 0 0;
                 0 s 0;
                 0 0 1];

            % Update homography 
            warp2 = (S \ warp) * S;

        otherwise
            error('Unknown transform "%s". Use "affine" or "homography".', transform);
    end
end
