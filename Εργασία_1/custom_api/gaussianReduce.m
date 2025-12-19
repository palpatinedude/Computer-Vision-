 %% Applies gaussian filter and downsamples by 2
function x_next = gaussianReduce(x)
   
    h = [1 4 6 4 1]'/16;  % Gaussian kernel
    N = length(x);  

    % Create toeplitz matrix for convolution
    hN = [h; zeros(N-5,1)];  
    eN = [1; zeros(N-1,1)];  
    T = toeplitz(eN,[eN(1);hN(2:end)]);    

    % Convolution
    y = T * x(:);  

    % Downsampling by 2
    N2 = floor(N/2);  
    DN = zeros(N2, N);  
    for i = 1:N2
        DN(i, 2*i-1) = 1;  
    end
    x_next = DN * y;
end
