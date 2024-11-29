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