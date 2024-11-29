function params = shearParams(frameIndex, totalFrames, shearFactor, shearDirection)
    t = frameIndex / totalFrames * 2 * pi; 
    shearX = 0;
    shearY = 0;
    
    if shearDirection == 1 % shear along x-axis
        shearX = shearFactor * sin(t);
    elseif shearDirection == 2 % shear both x and y axes
        shearX = shearFactor * sin(t);
        shearY = shearFactor * cos(t);
    end
    
    params.shearX = shearX;
    params.shearY = shearY;
end