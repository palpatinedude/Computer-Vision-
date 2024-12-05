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
