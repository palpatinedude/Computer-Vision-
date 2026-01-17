%% This script tests brightness/contrast changes and compares ECC vs LK using heatmaps.
clear; close all; clc;

S = load(fullfile("results","A0_data.mat"), "data");

vid = "video1";
res = "high";      % 'low' or 'high'
tid = 1;
iid = 20;

frames = data.(vid).(res).frames;
T0 = im2double(frames{tid});   % template
I0 = im2double(frames{iid});   % image

% Select frames and pyramid levels based on resolution
[frames, levels, resTag] = pick_frames_levels(S, vid, res);

contrasts  = [0.8 1.0 1.2 1.4];   % contrast a
brightness = [-0.1 0 0.1 0.2];    % brightness b
clip01 = @(X) min(max(X,0),1);    % clip to [0,1]

cases = ["template_only","image_only","both"];

PSNR_ECC = nan(numel(cases), numel(contrasts), numel(brightness));
PSNR_LK  = nan(numel(cases), numel(contrasts), numel(brightness));
DELTA    = nan(numel(cases), numel(contrasts), numel(brightness)); % ECC - LK
SAT_I    = nan(numel(cases), numel(contrasts), numel(brightness)); % image clipping ratio
SAT_T    = nan(numel(cases), numel(contrasts), numel(brightness)); % template clipping ratio

fprintf("A5 photometric heatmaps: %s_%s | pair t=%d i=%d | levels=%d | noi=%d\n", ...
    vid, res, tid, iid, levels, noi);

% Main loop 
for cc = 1:numel(cases)
    caseName = cases(cc);
    fprintf("\n--- Case: %s ---\n", caseName);

    for ia = 1:numel(contrasts)
        a = contrasts(ia);

        for ib = 1:numel(brightness)
            b = brightness(ib);

            % Start from original images
            T = T0; I = I0;

            % Apply brightness/contrast to selected image(s)
            switch caseName
                case "template_only"
                    T = clip01(a*T0 + b);
                case "image_only"
                    I = clip01(a*I0 + b);
                case "both"
                    T = clip01(a*T0 + b);
                    I = clip01(a*I0 + b);
            end

            % How much clipping happened (saturation ratio)
            SAT_T(cc,ia,ib) = mean(T(:)==0 | T(:)==1);
            SAT_I(cc,ia,ib) = mean(I(:)==0 | I(:)==1);

            % Run alignment (ECC + LK)
            [~, ~, RMSE_ECC, ~, RMSE_LK] = ...
                ecc_lk_alignment(I, T, levels, S.data.params.noi, S.data.params.transform, S.data.params.delta_p_init);

            rmse_ecc = last_finite(RMSE_ECC);
            rmse_lk  = last_finite(RMSE_LK);

            % PSNR-like and difference
            PSNR_ECC(cc,ia,ib) = 20*log10(255 / rmse_ecc);
            PSNR_LK(cc,ia,ib)  = 20*log10(255 / rmse_lk);
            DELTA(cc,ia,ib)    = PSNR_ECC(cc,ia,ib) - PSNR_LK(cc,ia,ib);

            fprintf("a=%.1f, b=%+.1f | ΔPSNR=%.2f dB | satI=%.3f satT=%.3f\n", ...
                a, b, DELTA(cc,ia,ib), SAT_I(cc,ia,ib), SAT_T(cc,ia,ib));

            close all; 
        end
    end
end

% ΔPSNR (ECC - LK)
for cc = 1:numel(cases)
    caseName = cases(cc);
    runTag = sprintf("A5_%s_%s_t%d_i%d_%s", vid, res, tid, iid, caseName);

    fig = figure('Visible','on');
    imagesc(brightness, contrasts, squeeze(DELTA(cc,:,:)));
    set(gca,'YDir','normal'); colorbar;
    xlabel('brightness b (im2double)');
    ylabel('contrast a');
    title(['ΔPSNR (ECC - LK) - ' strrep(runTag,'_','\_')]);

    exportgraphics(fig, fullfile(S.data.params.outputDir, runTag + "_DELTA.png"));
    close(fig);
end

% Save saturation heatmap 
cc_img = find(cases=="image_only", 1);
if ~isempty(cc_img)
    runTag = sprintf("A5_%s_%s_t%d_i%d_%s", vid, res, tid, iid, "image_only");

    fig = figure('Visible','on');
    imagesc(brightness, contrasts, squeeze(SAT_I(cc_img,:,:)));
    set(gca,'YDir','normal'); colorbar;
    xlabel('brightness b (im2double)');
    ylabel('contrast a');
    title(['Saturation ratio (IMAGE) - ' strrep(runTag,'_','\_')]);

    exportgraphics(fig, fullfile( S.data.params.outputDir, runTag + "_SAT_image_REPORT.png"));
    close(fig);
end

fprintf("\nSaved outputs in %s/:\n", S.data.params.outputDir);

