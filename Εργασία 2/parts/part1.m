% main scope to be familiarized with the corresponding functions and logi

% function to execute the 1st part of the procedure
function part1(img,img1)

   % scaling
   parameters.scaleFactor = 1.25; 
   scaledbeach = transformImage(img, 'scale', parameters,1);

   % rotation
   parameters.angle = 75; 
   rotatedbeach = transformImage(img, 'rotate', parameters,1);
   parameters.angle = -75; 
   rotatedI2 = transformImage(img, 'rotate', parameters,1);


   % shearing
   parameters.shearX = 1; 
   parameters.shearY = 0;  
   shearedbeach = transformImage(img, 'shear', parameters,1);

   % translation
   parameters.translateX = 200; 
   parameters.translateY = 100; 
   translatedbeach = transformImage(img, 'translate', parameters,1);


   % translation and rotation
   parameters.translateX = 250; 
   parameters.translateY = 50; 
   parameters.angle = 30;       
   translatedAndRotatedbeach = transformImage(img, 'translateRotate', parameters,1);


   % make a animation rotate ball
   numFrames = 300;            
   canvasSize = 1500;           
   rotationRadius = 300;     
   fps = 30; % frames per sec

   sequence = createAnimation(img1, numFrames, canvasSize, rotationRadius);
   implay(sequence, fps);

end


% function to create an animation of a ball rotating around a circle
function sequence = createAnimation(image, numFrames, canvasSize, rotationRadius)
    parameters.scaleFactor = 0.3; 
    %smallBall = resizeBall(image, scaleFactor);
    
    smallBall = transformImage(image, 'scale',parameters,1);


    % create the canvas for animation 
    ballCanvas = uint8(zeros(canvasSize, canvasSize, 3));

    % maximum dimension of the ball
    maxDim = size(smallBall, 1);
    
    % center of rotation
    centerX = canvasSize / 2;
    centerY = canvasSize / 2;
    
    % create animation sequence
    sequence = zeros([canvasSize, canvasSize, 3, numFrames], 'uint8');
    
    for i = 1:numFrames
        % reset the canvas to black
        ballCanvas(:,:,:) = uint8(0);
        
        % calculate the ball's position 
        [xPos, yPos] = calculatePosition(i, 360/numFrames, rotationRadius, centerX, centerY, maxDim);
        
        % place the ball on canvas
        ballCanvas(yPos:yPos+maxDim-1, xPos:xPos+maxDim-1, :) = smallBall;
        
        sequence(:, :, :, i) = ballCanvas;
    end
end


% function to calculate the position of the ball 
function [xPos, yPos] = calculatePosition(frameIndex, angleStep, radius, centerX, centerY, maxDim)
    % convert the angle step from degrees to radians
    angleRad = deg2rad(angleStep * frameIndex);
    
    % calculate the offset from the center using periodic functions
    offsetX = radius * cos(angleRad);
    offsetY = radius * sin(angleRad);
    
    % calculate the position of the ball
    xPos = round(centerX + offsetX - maxDim / 2);
    yPos = round(centerY + offsetY - maxDim / 2);
    
    % ensure the ball stays within the  bounds
    xPos = max(min(xPos, 1500 - maxDim), 1);
    yPos = max(min(yPos, 1500 - maxDim), 1);
end
