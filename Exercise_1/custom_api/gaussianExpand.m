function x_exp = gaussianExpand(x)
    h = [1 4 6 4 1]'/8;  % Gaussian kernel (normalized)
    N = length(x);  
    
    % Upsample: insert zeros between original samples
    x_up = zeros(2*N,1);  
    x_up(1:2:end) = x;  
    
    % Prepare kernel vector for convolution (pad with zeros)
    hN = [h; zeros(2*N - 5,1)];  
    
    % Prepare first column of toeplitz matrix (delta function)
    eN = [1; zeros(2*N-1,1)];    
    
    % Create toeplitz convolution matrix
    T = toeplitz(eN,[eN(1);hN(2:end)]);    
    
    % Apply convolution to get expanded signal
    x_exp = T * x_up;
end
