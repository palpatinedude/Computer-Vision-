%{
% Binomial kernel (normalized)
h = [1 4 6 4 1]/16;
x_discrete = -2:2;


% Continuous Gaussian for time-domain visualization
x_cont = linspace(-2.5, 2.5, 100);
sigma = 1;
G = exp(-x_cont.^2/(2*sigma^2));
G = G / max(G);      % Normalize peak to 1
G = G * max(h);      % Scale to match binomial kernel peak


% Gaussian for frequency-domain comparison (discrete points)
G_fft_points = exp(-x_discrete.^2/(2*sigma^2));
G_fft_points = G_fft_points / sum(G_fft_points);  % Normalize sum = 1

% FFT parameters
NFFT = 512;                % Zero-padding for smooth spectrum
H = fft(h, NFFT);
G_fft = fft(G_fft_points, NFFT);
f = linspace(-0.5, 0.5, NFFT);  % Normalized frequency centered at 0
H_shift = fftshift(H);            % Shift zero freq to center
G_shift = fftshift(G_fft);        % Shift Gaussian FFT


% Create figure with 2 subplots
figure;

% Time Domain
subplot(2,1,1);
stem(x_discrete, h, 'filled'); hold on;
plot(x_cont, G, 'r', 'LineWidth', 2);
xlabel('x');
ylabel('Amplitude');
title('Binomial Kernel vs Gaussian (Time Domain)');
legend('Binomial Kernel','Gaussian');
grid on;

% Frequency Domain (Low-Pass) 
subplot(2,1,2);
plot(f, abs(H_shift), 'b', 'LineWidth', 2); hold on;
plot(f, abs(G_shift), 'r--', 'LineWidth', 2);
xlabel('Normalized Frequency');
ylabel('Magnitude');
title('Frequency Response (Low-Pass) of Binomial Kernel vs Gaussian');
legend('Binomial Kernel','Gaussian');
grid on;
%}


% Binomial kernel 
h = [1 4 6 4 1]/16;
x_discrete = -2:2;


% Continuous Gaussian for time-domain visualization
sigma = 1;
x_cont = linspace(-2.5, 2.5, 100);
G_cont = exp(-x_cont.^2/(2*sigma^2));
G_cont = G_cont / max(G_cont) * max(h);   % Scale to match binomial peak


% Discrete Gaussian for frequency-domain comparison
G_fspecial = fspecial('gaussian', [1 5], sigma);  % normalized sum = 1

% ------------------------------
% FFT for frequency comparison
NFFT = 512;
H = fft(h, NFFT);
G_fft = fft(G_fspecial, NFFT);
f = linspace(-0.5, 0.5, NFFT);  % Normalized frequency
H_shift = fftshift(H);
G_shift = fftshift(G_fft);

%
% Plot figure with 2 subplots
figure;

% Time Domain
subplot(2,1,1);
stem(x_discrete, h, 'filled'); hold on;
plot(x_cont, G_cont, 'r', 'LineWidth', 2);
xlabel('x');
ylabel('Amplitude');
title('Binomial Kernel vs Gaussian (Time Domain)');
legend('Binomial Kernel','Continuous Gaussian');
grid on;

% Frequency Domain 
subplot(2,1,2);
plot(f, abs(H_shift), 'b', 'LineWidth', 2); hold on;
plot(f, abs(G_shift), 'r--', 'LineWidth', 2);
xlabel('Normalized Frequency');
ylabel('Magnitude');
title('Frequency Response (Low-Pass) of Binomial Kernel vs Gaussian');
legend('Binomial Kernel','fspecial Gaussian');
grid on;
