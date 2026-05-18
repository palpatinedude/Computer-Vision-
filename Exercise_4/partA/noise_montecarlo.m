%% noise_montecarlo.m
% Monte Carlo noise experiments for ECC vs Lucas-Kanade.
% Gaussian: N(0, sigma^2), sigma^2 = 4, 8, 12 gray levels
% Uniform: U[-alpha, alpha], alpha = 6*sqrt(3), 12*sqrt(3), 18*sqrt(3)

clear; close all; clc;

%% Load setup data
S = load(fullfile("results","A0_data.mat"), "data");

%% Experiment settings
vid = "video1";      % "video1" or "video2"
res = "high";        % "low" or "high"

tid = 1;
iid = 20;

noi = 30;
transform = 'affine';
delta_p_init = zeros(2,3);

numRuns = 100;

outputDir = fullfile("results","noise");
if ~exist(outputDir, "dir")
    mkdir(outputDir);
end

%% Select frames
[frames, levels, resTag] = pick_frames_levels(S, vid, res);

T0 = im2double(frames{tid});
I0 = im2double(frames{iid});

clip01 = @(X) min(max(X,0),1);

%% Noise parameters in gray levels
gaussVars = [4 8 12];                  % sigma^2
uniformAlphas = [6 12 18] * sqrt(3);   % alpha

%% Storage
PSNR_G_ECC = nan(numel(gaussVars), numRuns);
PSNR_G_LK  = nan(numel(gaussVars), numRuns);

PSNR_U_ECC = nan(numel(uniformAlphas), numRuns);
PSNR_U_LK  = nan(numel(uniformAlphas), numRuns);

fprintf("A6 Noise Monte Carlo: %s_%s | template=%d image=%d | levels=%d | runs=%d\n", ...
    vid, resTag, tid, iid, levels, numRuns);

%% Gaussian Noise
fprintf("\n===== Gaussian Noise =====\n");

for s = 1:numel(gaussVars)

    sigma2 = gaussVars(s);
    sigma = sqrt(sigma2);

    fprintf("\nGaussian sigma^2 = %.1f gray levels\n", sigma2);

    for r = 1:numRuns

        % Noise is specified in gray levels, frames are [0,1]
        noise = (sigma/255) * randn(size(I0));

        I_noisy = clip01(I0 + noise);

        [~, ~, RMSE_ECC, ~, RMSE_LK] = ...
            ecc_lk_alignment(I_noisy, T0, levels, noi, transform, delta_p_init);

        rmse_ecc = last_finite(RMSE_ECC);
        rmse_lk  = last_finite(RMSE_LK);

        PSNR_G_ECC(s,r) = 20*log10(255 / rmse_ecc);
        PSNR_G_LK(s,r)  = 20*log10(255 / rmse_lk);

        close all;
    end

    fprintf("ECC mean = %.2f dB, std = %.2f\n", ...
        mean(PSNR_G_ECC(s,:), 'omitnan'), std(PSNR_G_ECC(s,:), 'omitnan'));

    fprintf("LK  mean = %.2f dB, std = %.2f\n", ...
        mean(PSNR_G_LK(s,:), 'omitnan'), std(PSNR_G_LK(s,:), 'omitnan'));
end

%% Uniform Noise 
fprintf("\n===== Uniform Noise =====\n");

for a = 1:numel(uniformAlphas)

    alpha = uniformAlphas(a);

    fprintf("\nUniform alpha = %.2f gray levels\n", alpha);

    for r = 1:numRuns

        % Uniform noise U[-alpha, alpha] in gray levels
        noise = (alpha/255) * (2*rand(size(I0)) - 1);

        I_noisy = clip01(I0 + noise);

        [~, ~, RMSE_ECC, ~, RMSE_LK] = ...
            ecc_lk_alignment(I_noisy, T0, levels, noi, transform, delta_p_init);

        rmse_ecc = last_finite(RMSE_ECC);
        rmse_lk  = last_finite(RMSE_LK);

        PSNR_U_ECC(a,r) = 20*log10(255 / rmse_ecc);
        PSNR_U_LK(a,r)  = 20*log10(255 / rmse_lk);

        close all;
    end

    fprintf("ECC mean = %.2f dB, std = %.2f\n", ...
        mean(PSNR_U_ECC(a,:), 'omitnan'), std(PSNR_U_ECC(a,:), 'omitnan'));

    fprintf("LK  mean = %.2f dB, std = %.2f\n", ...
        mean(PSNR_U_LK(a,:), 'omitnan'), std(PSNR_U_LK(a,:), 'omitnan'));
end

%% Summary statistics
G_ECC_mean = mean(PSNR_G_ECC, 2, 'omitnan');
G_ECC_std  = std(PSNR_G_ECC, 0, 2, 'omitnan');
G_LK_mean  = mean(PSNR_G_LK, 2, 'omitnan');
G_LK_std   = std(PSNR_G_LK, 0, 2, 'omitnan');

U_ECC_mean = mean(PSNR_U_ECC, 2, 'omitnan');
U_ECC_std  = std(PSNR_U_ECC, 0, 2, 'omitnan');
U_LK_mean  = mean(PSNR_U_LK, 2, 'omitnan');
U_LK_std   = std(PSNR_U_LK, 0, 2, 'omitnan');

%% Plot Gaussian results
fig = figure('Visible','on');
errorbar(gaussVars, G_ECC_mean, G_ECC_std, '-o', 'LineWidth', 1.5); hold on;
errorbar(gaussVars, G_LK_mean,  G_LK_std,  '-s', 'LineWidth', 1.5);
grid on;
xlabel('\sigma^2 Gaussian noise (gray levels)');
ylabel('Mean PSNR-like (dB)');
legend('ECC','LK','Location','best');
title(sprintf('Gaussian Noise Monte Carlo | %s\\_%s', vid, resTag));
exportgraphics(fig, fullfile(outputDir, sprintf("A6_%s_%s_gaussian.png", vid, resTag)));
close(fig);

%% Plot Uniform results
fig = figure('Visible','on');
errorbar(uniformAlphas, U_ECC_mean, U_ECC_std, '-o', 'LineWidth', 1.5); hold on;
errorbar(uniformAlphas, U_LK_mean,  U_LK_std,  '-s', 'LineWidth', 1.5);
grid on;
xlabel('\alpha Uniform noise (gray levels)');
ylabel('Mean PSNR-like (dB)');
legend('ECC','LK','Location','best');
title(sprintf('Uniform Noise Monte Carlo | %s\\_%s', vid, resTag));
exportgraphics(fig, fullfile(outputDir, sprintf("A6_%s_%s_uniform.png", vid, resTag)));
close(fig);

%% Save numerical results
save(fullfile(outputDir, sprintf("A6_%s_%s_noise_results.mat", vid, resTag)), ...
    "PSNR_G_ECC", "PSNR_G_LK", "PSNR_U_ECC", "PSNR_U_LK", ...
    "G_ECC_mean", "G_ECC_std", "G_LK_mean", "G_LK_std", ...
    "U_ECC_mean", "U_ECC_std", "U_LK_mean", "U_LK_std", ...
    "gaussVars", "uniformAlphas", ...
    "vid", "resTag", "tid", "iid", "levels", "noi", ...
    "transform", "delta_p_init", "numRuns");

fprintf("\nSaved noise results in: %s\n", outputDir);