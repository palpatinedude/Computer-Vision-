%% Implement Gaussian pyramid function

addpath('custom_api/');

close all; clear;

% Test 1D gaussian pyramid
N = 64;
t = linspace(0, 2*pi, N);
x = sin(2*t) + 0.5*sin(5*t);  

L = 4;  % number of levels
G = gaussianPyramid(x, L); % helper function

figure;
for j = 1:L+1
    subplot(L+1,1,j);
    plot(G{j}, '-o');
    title(['Gaussian Level ' num2str(j-1)]);
end
%{
close all; 
clear;

function x_next = gaussianReduce(x)
    % Ensure x is a column vector
    x = x(:);

    % Gaussian kernel (column vector)
    h = [1 4 6 4 1]' / 16;

    N = length(x); % length of input signal

    % Extend h with zeros to match signal length
    hN = [h; zeros(N-5,1)];
    eN = [1; zeros(N-1,1)];

    % Create toeplitz matrix for convolution
    T = toeplitz(eN, [eN(1); hN(2:end)]);

    % Convolution using toeplitz matrix
    y = T * x;

    % Downsampling by 2
    N2 = floor(N / 2);
    DN = zeros(N2, N); % initialize downsampling matrix
    for i = 1:N2
        DN(i, 2*i-1) = 1; % keep every second element
    end

    % Apply downsampling
    x_next = DN * y;
end

% Create gaussian pyramid with L levels
function G = gaussianPyramid(x, L)
    x = x(:); % ensure column vector
    G = cell(L+1, 1); % cell array to store pyramid levels
    G{1} = x; % level 0 = original signal

    for j = 1:L
        x = gaussianReduce(x); % filter and downsample
        G{j+1} = x; % store next level
    end
end

% Test for 1D signal
N = 64;
t = linspace(0, 2*pi, N);
x = sin(2*t) + 0.5*sin(5*t); % example signal

L = 4; % number of pyramid levels
G = gaussianPyramid(x, L);

figure;
for j = 1:L+1
    subplot(L+1, 1, j);
    plot(G{j}, '-o');
    title(['Gaussian Level ' num2str(j-1)]);
end
%}

