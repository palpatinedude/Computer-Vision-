%% Ball kicked toward the horizon 
clear; close all; clc;
addpath('../transformations'); 


bg   = imread('../CV_2-TRANSFORMATIONS/beach.jpg');   % background image
ball = imread('../CV_2-TRANSFORMATIONS/ball.jpg');    % ball image
mask = imread('../CV_2-TRANSFORMATIONS/ball_mask.jpg'); % mask of ball (black=ball)

[H_bg, W_bg, ~] = size(bg);  % get background dimensions


initScale = 0.13;  % initial size of the ball

% Animation parameters
numFrames = 185;  % total number of frames
videoFrames = zeros(H_bg, W_bg, 3, numFrames, 'uint8'); % preallocate video array

% Start & end positions
startX = W_bg * 0.5; % ball starting X (middle)
startY = H_bg - 20;  % ball starting Y (bottom of image)
endX   = W_bg * 0.50;   % ball final X (horizon center)
endY   = H_bg * 0.39;   % ball final Y (sea line)

% Scaling parameters
scaleStart = initScale; % start scale
scaleEnd = 0.03;        % end scale near horizon

% Rotation parameters
rotationSpeed = 6;         % rotation degrees per frame
rotationAccelFall = 0.08;  % extra rotation acceleration during fall

% Arc parameters
arcHeight = 620; % maximum height of the ball in pixels
tApex = 0.35;    % fraction of frames to reach apex
kApex = floor(numFrames*tApex); % frame index of apex
apexY = startY - arcHeight;     % Y position at apex

% Animation loop
for k = 1:numFrames
    t = (k-1)/(numFrames-1); % normalized time [0,1]

    posX = startX;  

    if k <= kApex
        % Ascend: cubic ease for natural motion
        tNorm = k/kApex;
        posY = startY - arcHeight*(1 - (1-tNorm)^3);
    else
        % Fall towards the sea with acceleration
        tFall = (k - kApex)/(numFrames - kApex);
        posY = apexY + (endY - apexY)*(tFall + 0.7*tFall^2);
    end
  
    % Scaling: interpolate size from start to end
    scale = scaleStart*(1-t) + scaleEnd*t;
    ballS = imresize(ball, scale);  % resize ball
    maskS = imresize(mask, scale);  % resize mask

    % Rotation: faster during fall
    if k <= kApex
        angle = rotationSpeed * k; % rotate while going up
    else
        angle = rotationSpeed * k + rotationAccelFall*(k - kApex)^2; % add extra rotation while falling
    end
    ballR = imrotate(ballS, angle, 'bilinear', 'crop'); % rotate ball image
    maskR = imrotate(maskS, angle, 'bilinear', 'crop'); % rotate mask

    [Hb, Wb, ~] = size(ballR); % get rotated ball size

    % ROI & composition: calculate where to place ball on background
    x1 = round(posX - Wb/2);
    y1 = round(posY - Hb/2);
    x2 = x1 + Wb - 1;
    y2 = y1 + Hb - 1;

    xs = max(1,x1); xe = min(W_bg,x2);
    ys = max(1,y1); ye = min(H_bg,y2);

    bx1 = 1 + (xs - x1); by1 = 1 + (ys - y1);
    bx2 = Wb - (x2 - xe); by2 = Hb - (y2 - ye);

    ballCrop = ballR(by1:by2, bx1:bx2, :);  % cropped rotated ball
    maskCrop = maskR(by1:by2, bx1:bx2) == 0; % binary mask for blending

    frame = bg; % start with background
    bgPatch = frame(ys:ye, xs:xe, :); % background region to blend

    % remove black pixels from ball using mask
    for c = 1:3
        blackPixels = (ballCrop(:,:,c) == 0) & maskCrop;
        ballCrop(:,:,c) = ballCrop(:,:,c).*uint8(~blackPixels) + bgPatch(:,:,c).*uint8(blackPixels);
    end

    % blend ball onto background
    for c = 1:3
        frame(ys:ye, xs:xe, c) = frame(ys:ye, xs:xe, c).*uint8(~maskCrop) + ballCrop(:,:,c).*uint8(maskCrop);
    end

    videoFrames(:,:,:,k) = frame; 
end

implay(videoFrames); 

v = VideoWriter('transf_beach_horizon.avi');
open(v);
writeVideo(v, videoFrames);
close(v);
