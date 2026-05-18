%% From Gaussian To Laplacian

addpath('../custom_api/');

close all; clear;

% Original signal
N = 64;
t = linspace(0, 2*pi, N);
x = sin(2*t) + 0.5*sin(5*t);

% Build gaussian pyramid
L_levels = 4;
G = gaussianPyramid(x, L_levels);

% Build gaplacian pyramid
Lap = buildLaplacianPyramid(G);

% Reconstruct signal
x_reconstructed = reconstructFromLaplacian(Lap);

figure; plot(x,'-o','LineWidth',1.5); title('Original Signal');

figure;
for j = 1:L_levels+1
    subplot(L_levels+1,1,j);
    plot(G{j},'-o'); title(['Gaussian Level ' num2str(j-1)]);
end

figure;
for j = 1:L_levels+1
    subplot(L_levels+1,1,j);
    plot(Lap{j},'-o'); title(['Laplacian Level ' num2str(j)]);
end
%{
close all; clear;

function x_next = gaussianReduce(x)
    % Gaussian kernel
    h = [1 4 6 4 1]'/16;  % normalized 1D gaussian kernel
    N = length(x);
    
    % Create toeplitz matrix T
    hN = [h; zeros(N-5,1)];  % pad with zeros to match signal length
    eN = [1; zeros(N-1,1)];  % first column for toeplitz
    T = toeplitz(eN,[eN(1);hN(2:end)]);   % construct toeplitz matrix for convolution
    
    % Convolution
    y = T * x(:);  
    
    % Downsampling using DN matrix
    N2 = floor(N/2);
    DN = zeros(N2, N);
    for i = 1:N2
        DN(i, 2*i-1) = 1;  % keep every second element
    end
    
    x_next = DN * y;  % downsampled signal
end


% Create a gaussian pyramid with L levels
function G = gaussianPyramid(x, L)
    
    x = x(:);  % ensure column vector
    G = cell(L+1,1);
    G{1} = x;  % level 0 = original signal
    
    for j = 1:L
        x = gaussianReduce(x);  % reduce resolution
        G{j+1} = x;
    end
end


function x_exp = gaussianExpand(x)
    h = [1 4 6 4 1]'/8;  % divide by 8 instead of 16 for expansion
    N = length(x);
    
    % Upsample by factor of 2
    x_up = zeros(2*N,1);
    x_up(1:2:end) = x;  % insert zeros between samples
    
    % Convolution with kernel h
    hN = [h; zeros(2*N - 5,1)];  % pad kernel
    eN = [1; zeros(2*N-1,1)];    % first column for Toeplitz
    T = toeplitz(eN,[eN(1);hN(2:end)]);    
    
    x_exp = T * x_up;  % expanded signal
end



function L = buildLaplacianPyramid(G)
    % G = Gaussian pyramid {G0, G1, ..., GL}
    L_levels = length(G) - 1;
    L = cell(L_levels+1,1);
    
    for j = 1:L_levels
        Gj_up = gaussianExpand(G{j+1});  % expand next level
        
        % Adjust length if needed
        len_diff = length(G{j}) - length(Gj_up);
        if len_diff > 0
            Gj_up = [Gj_up; zeros(len_diff,1)];
        elseif len_diff < 0
            Gj_up = Gj_up(1:length(G{j}));
        end
        
        L{j} = G{j} - Gj_up;  % compute Laplacian level
    end
    
    % Last level of laplacian pyramid = last gaussian level
    L{end} = G{end};
end


function G0 = reconstructFromLaplacian(L)
    L_levels = length(L) - 1;
    G = L{end};  % start from coarsest level
    
    for j = L_levels:-1:1
        G = gaussianExpand(G);  % expand to finer level
        
        len_diff = length(L{j}) - length(G);
        if len_diff > 0
            G = [G; zeros(len_diff,1)];
        elseif len_diff < 0
            G = G(1:length(L{j}));
        end
        
        G = G + L{j};  % add laplacian detail
    end
    
    G0 = G;  % reconstructed signal
end



% Original 1D signal
N = 64;
t = linspace(0, 2*pi, N);
x = sin(2*t) + 0.5*sin(5*t);

% Gaussian pyramid
L_levels = 4;
G = gaussianPyramid(x,L_levels);

% Laplacian pyramid
Lap = buildLaplacianPyramid(G);

% Reconstruction
x_reconstructed = reconstructFromLaplacian(Lap);

% Original signal figure
figure;
plot(x,'-o','LineWidth',1.5);
title('Original Signal x_0');
xlabel('Sample Index'); ylabel('Amplitude');
grid on;

% Gaussian pyramid Levels figure
figure;
num_levels = L_levels + 1;
for j = 1:num_levels
    subplot(num_levels,1,j);
    plot(G{j},'-o','LineWidth',1.2);
    title(['Gaussian Level G_{' num2str(j-1) '}']);
    xlabel('Sample Index'); ylabel('Amplitude');
    grid on;
end

% Laplacian pyramid Levels figure
figure;
for j = 1:num_levels
    subplot(num_levels,1,j);
    plot(Lap{j},'-o','LineWidth',1.2);
    title(['Laplacian Level L_{' num2str(j) '}']);
    xlabel('Sample Index'); ylabel('Amplitude');
    grid on;
end

% Step by step reconstruction figure
G_recon = Lap{end};  % start from coarsest level
figure;
plot(G_recon,'-xr','LineWidth',1.5); hold on;
title('Step-by-Step Reconstruction');
xlabel('Sample Index'); ylabel('Amplitude');
grid on;

for j = L_levels:-1:1
    G_recon = gaussianExpand(G_recon);
    len_diff = length(Lap{j}) - length(G_recon);
    if len_diff > 0
        G_recon = [G_recon; zeros(len_diff,1)];
    elseif len_diff < 0
        G_recon = G_recon(1:length(Lap{j}));
    end
    G_recon = G_recon + Lap{j};
    
    plot(G_recon,'-o','DisplayName',['After adding L_{' num2str(j) '}']);
end

plot(x,'-k','LineWidth',2,'DisplayName','Original x'); % overlay original signal
legend show;
hold off;


% FFT of laplacian Levels
figure;
for j=1:num_levels
    xj = Lap{j};
    N = length(xj);
    Xj = fftshift(fft(xj));
    magX = abs(Xj);
    f = linspace(-0.5,0.5,N);  

    subplot(num_levels,1,j);
    plot(f, magX, 'LineWidth',1.2);
    title(['FFT of Laplacian Level L_{' num2str(j) '}']); xlabel('Normalized Frequency'); ylabel('|X(f)|'); grid on;
end
%}


