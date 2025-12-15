close all; clear;
%% Implement Gaussian Pyramid

function x_next = gaussianReduce(x)
    % Gaussian kernel (5 elements)
    % The ' transpose converts the row vector into a column vector
    h = [1 4 6 4 1]'/16;  
    
    N = length(x);  % length of input signal
    
    % Create Toeplitz matrix T for convolution
    % Extend h with zeros to match signal length
    hN = [h; zeros(N-5,1)];  
    eN = [1; zeros(N-1,1)];  
    % Toeplitz matrix allows convolution via matrix multiplication
    T = toeplitz(eN,[eN(1);hN(2:end)]);    
    
    % Convolution using Toeplitz matrix
    y = T * x(:);  % ensures x is a column vector
    
    % Downsampling by 2
    N2 = floor(N/2);  % new length of downsampled signal
    DN = zeros(N2, N);  % initialize downsampling matrix
    for i = 1:N2
        DN(i, 2*i-1) = 1;  % keep every second element
    end
    
    % Apply downsampling
    x_next = DN * y;
end

% Create a Gaussian pyramid with L levels
function G = gaussianPyramid(x, L)
    x = x(:);  % convert input signal to a column vector
    G = cell(L+1,1);  % cell array to store all levels
    G{1} = x;  % level 0 = original signal
    
    for j = 1:L
        x = gaussianReduce(x);  % filter + downsample
        G{j+1} = x;            % store next level
    end
end

% Test for 1D signal
N = 64;
t = linspace(0, 2*pi, N);
x = sin(2*t) + 0.5*sin(5*t);  % example 

L = 4;  % number of pyramid levels
G = gaussianPyramid(x, L);


figure;
for j = 1:L+1
    subplot(L+1,1,j);
    plot(G{j}, '-o');
    title(['Gaussian Level ' num2str(j-1)]);
end
