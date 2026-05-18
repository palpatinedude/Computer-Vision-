%% photometric.m
% Tests brightness/contrast changes and compares ECC vs LK.

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

outputDir = fullfile("results","photometric");
if ~exist(outputDir, "dir")
    mkdir(outputDir);
end

%% Select frames and levels
[frames, levels, resTag] = pick_frames_levels(S, vid, res);

T0 = im2double(frames{tid});   % template
I0 = im2double(frames{iid});   % image

%% Photometric parameters
contrasts  = [0.8 1.0 1.2 1.4];
brightness = [-0.1 0 0.1 0.2];

clip01 = @(X) min(max(X,0),1);

cases = ["template_only","image_only","both"];

PSNR_ECC = nan(numel(cases), numel(contrasts), numel(brightness));
PSNR_LK  = nan(numel(cases), numel(contrasts), numel(brightness));
DELTA    = nan(numel(cases), numel(contrasts), numel(brightness));
SAT_I    = nan(numel(cases), numel(contrasts), numel(brightness));
SAT_T    = nan(numel(cases), numel(contrasts), numel(brightness));

fprintf("A5 Photometric: %s_%s | template=%d image=%d | levels=%d | noi=%d\n", ...
    vid, resTag, tid, iid, levels, noi);

%% Main loop
for cc = 1:numel(cases)

    caseName = cases(cc);
    fprintf("\n--- Case: %s ---\n", caseName);

    for ia = 1:numel(contrasts)

        a = contrasts(ia);

        for ib = 1:numel(brightness)

            b = brightness(ib);

            T = T0;
            I = I0;

            switch caseName
                case "template_only"
                    T = clip01(a*T0 + b);

                case "image_only"
                    I = clip01(a*I0 + b);

                case "both"
                    T = clip01(a*T0 + b);
                    I = clip01(a*I0 + b);
            end

            SAT_T(cc,ia,ib) = mean(T(:)==0 | T(:)==1);
            SAT_I(cc,ia,ib) = mean(I(:)==0 | I(:)==1);

            [results, results_lk, RMSE_ECC, rho, RMSE_LK] = ...
                ecc_lk_alignment(I, T, levels, noi, transform, delta_p_init);

            rmse_ecc = last_finite(RMSE_ECC);
            rmse_lk  = last_finite(RMSE_LK);

            PSNR_ECC(cc,ia,ib) = 20*log10(255 / rmse_ecc);
            PSNR_LK(cc,ia,ib)  = 20*log10(255 / rmse_lk);
            DELTA(cc,ia,ib)    = PSNR_ECC(cc,ia,ib) - PSNR_LK(cc,ia,ib);

            fprintf("a=%.1f, b=%+.1f | ECC=%.2f dB | LK=%.2f dB | Δ=%.2f dB\n", ...
                a, b, PSNR_ECC(cc,ia,ib), PSNR_LK(cc,ia,ib), DELTA(cc,ia,ib));

            close all;
        end
    end
end

%% Save heatmaps
for cc = 1:numel(cases)

    caseName = cases(cc);
    runTag = sprintf("A5_%s_%s_t%d_i%d_%s", vid, resTag, tid, iid, caseName);

    fig = figure('Visible','on');
    imagesc(brightness, contrasts, squeeze(DELTA(cc,:,:)));
    set(gca,'YDir','normal');
    colorbar;
    xlabel('brightness b');
    ylabel('contrast a');
    title(['ΔPSNR = ECC - LK | ' strrep(runTag,'_','\_')]);

    exportgraphics(fig, fullfile(outputDir, runTag + "_DELTA.png"));
    close(fig);
end

%% Save saturation heatmap for image_only
cc_img = find(cases=="image_only", 1);

if ~isempty(cc_img)

    runTag = sprintf("A5_%s_%s_t%d_i%d_image_only", vid, resTag, tid, iid);

    fig = figure('Visible','on');
    imagesc(brightness, contrasts, squeeze(SAT_I(cc_img,:,:)));
    set(gca,'YDir','normal');
    colorbar;
    xlabel('brightness b');
    ylabel('contrast a');
    title(['Saturation ratio IMAGE | ' strrep(runTag,'_','\_')]);

    exportgraphics(fig, fullfile(outputDir, runTag + "_SAT_image.png"));
    close(fig);
end

%% Save numerical results
save(fullfile(outputDir, sprintf("A5_%s_%s_t%d_i%d_results.mat", ...
    vid, resTag, tid, iid)), ...
    "PSNR_ECC", "PSNR_LK", "DELTA", "SAT_I", "SAT_T", ...
    "contrasts", "brightness", "cases", ...
    "vid", "resTag", "tid", "iid", "levels", "noi", ...
    "transform", "delta_p_init");

fprintf("\nSaved photometric results in: %s\n", outputDir);