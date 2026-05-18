%% Ball on Beach animation - Natural motion with gravity
clear; close all; clc;  

addpath('../transformations'); 

bg   = imread('../CV_2-TRANSFORMATIONS/beach.jpg');       % Load background image (beach)
ball = imread('../CV_2-TRANSFORMATIONS/ball.jpg');        % Load ball image
mask = imread('../CV_2-TRANSFORMATIONS/ball_mask.jpg');   % Load ball mask (black = ball area)

% Resize ball and mask to desired scale
scaleBall = 0.155;                   % Scale factor for the ball
ball = imresize(ball, scaleBall);    
mask = imresize(mask, scaleBall);   

[H_bg, W_bg, ~] = size(bg);          % Background height and width
[H_b,  W_b,  ~] = size(ball);        % Ball height and width


% Animation parameters
numFrames = 190;                     % Total number of frames in animation
videoFrames = zeros(H_bg, W_bg, 3, numFrames, 'uint8');  % Preallocate video frame array

speedX = 10;                          % Horizontal speed of the ball (pixels/frame)
rotationSpeed = 7;                    % Ball rotation speed (degrees/frame)


% Bounce parameters
bounceFrames = 40;                    % Number of frames for each bounce
groundY = H_bg - 140;                 % Y-coordinate representing the ground

startX = W_bg + 85;                   % Starting X-position (offscreen right)
startY = groundY;                     % Starting Y-position at ground

% Heights of three bounces (decreasing for energy loss)
bounceHeights = [260, 160, 80];


% Create animation frames
for k = 1:numFrames


    % Horizontal motion (constant speed)
    posX = startX - speedX * k - W_b/2;  % Move ball left over time

    % Vertical motion (simulating bounce using a parabola)
    if k <= bounceFrames
        % First bounce
        t = (k-1)/(bounceFrames-1);       
        posY = startY - bounceHeights(1)*(4*t*(1-t)) - H_b/2;

    elseif k <= 2*bounceFrames
        % Second bounce
        t = (k-bounceFrames-1)/(bounceFrames-1);
        posY = startY - bounceHeights(2)*(4*t*(1-t)) - H_b/2;

    elseif k <= 3*bounceFrames
        % Third bounce
        t = (k-2*bounceFrames-1)/(bounceFrames-1);
        posY = startY - bounceHeights(3)*(4*t*(1-t)) - H_b/2;

    else
        % After last bounce, straight rolling
        posY = startY - H_b/2;  
    end


    % Ball rotation
    angle = rotationSpeed * k;  % Compute rotation angle
    ballRot = imrotate(ball, angle, 'bilinear', 'crop');  % Rotate ball image
    maskRot = imrotate(mask, angle, 'bilinear', 'crop');  % Rotate mask accordingly

    % Frame composition
    frame = bg;  % Start with background

    % Define region of interest (ROI) in background for ball placement
    roiX_start = round(posX)+1;
    roiY_start = round(posY)+1;
    roiX_end = roiX_start + size(ballRot,2) - 1;
    roiY_end = roiY_start + size(ballRot,1) - 1;

    % Clip ROI to background bounds to avoid indexing outside array
    xStart = max(1, roiX_start);
    xEnd   = min(W_bg, roiX_end);
    yStart = max(1, roiY_start);
    yEnd   = min(H_bg, roiY_end);

    % Calculate offsets for cropped ball and mask (if partially outside)
    ballX_start = 1 + (xStart - roiX_start);
    ballX_end   = size(ballRot,2) - (roiX_end - xEnd);
    ballY_start = 1 + (yStart - roiY_start);
    ballY_end   = size(ballRot,1) - (roiY_end - yEnd);

    % Crop rotated ball and mask to fit inside background ROI
    ballCrop = ballRot(ballY_start:ballY_end, ballX_start:ballX_end, :);
    maskCrop = maskRot(ballY_start:ballY_end, ballX_start:ballX_end) == 0;  % True where ball exists

    % Crop the corresponding background patch
    bgPatch = frame(yStart:yEnd, xStart:xEnd, :);


    % Overlay ball on background
    for c = 1:3
        blackPixels = (ballCrop(:,:,c) == 0) & maskCrop; % Find black pixels in ball
        ballCrop(:,:,c) = ballCrop(:,:,c).*uint8(~blackPixels) + bgPatch(:,:,c).*uint8(blackPixels); % Replace black pixels with background - binary masking
    end

    % Assign cropped ball into frame using mask
    for c = 1:3
       tempBg = frame(yStart:yEnd, xStart:xEnd, c);
       tempBallCh = ballCrop(:,:,c);
       tempBg(maskCrop) = tempBallCh(maskCrop);
       frame(yStart:yEnd, xStart:xEnd, c) = tempBg;
    end

    % Save the frame

    videoFrames(:,:,:,k) = frame;
end


implay(videoFrames);
v = VideoWriter('transf_beach.avi');
open(v);
writeVideo(v, videoFrames);
close(v);
