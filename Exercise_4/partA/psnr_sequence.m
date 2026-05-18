%% This script sequential frame alignment: template=k, image=k+1

clear; close all; clc;
S = load(fullfile("results","A0_data.mat"), "data");

% Output folder
outputDir = fullfile("results","psnr_sequences");

if ~exist(outputDir, "dir")
    mkdir(outputDir);
end

% Runs
runs = { ...
    struct('video','video2','res','low'),  ...
    struct('video','video2','res','high'), ...
    struct('video','video1','res','low'),  ...
    struct('video','video1','res','high') ...
};

for rr = 1:numel(runs)

    vid = runs{rr}.video;
    res = runs{rr}.res;

    % Select frames and pyramid levels based on resolution
    [frames, levels, resTag] = pick_frames_levels(S, vid, res);

    N = numel(frames);
    psnr_ecc_seq = nan(1, N-1);
    psnr_lk_seq  = nan(1, N-1);

    fprintf('%s_%s | levels=%d | pairs=%d\n', vid, resTag, levels, N-1);

    for k = 1:(N-1)

        template = frames{k};
        image    = frames{k+1};

        % Run alignment: align image (k+1) to template (k)
        [~, ~, MSE, ~, MSELK] = ecc_lk_alignment( ...
            image, template, levels, ...
            S.data.params.noi, ...
            S.data.params.transform, ...
            S.data.params.delta_p_init);

        % Use final available value
        rmse_ecc = last_finite(MSE);
        rmse_lk  = last_finite(MSELK);

        % Convert to PSNR-like (dB)
        if ~isnan(rmse_ecc) && rmse_ecc > 0
            psnr_ecc_seq(k) = 20*log10(255 / rmse_ecc);
        end

        if ~isnan(rmse_lk) && rmse_lk > 0
            psnr_lk_seq(k) = 20*log10(255 / rmse_lk);
        end

        close all;
    end

    runName = sprintf('%s_%s_seq', vid, resTag);

    % Plot
    fig = figure('Name', ['A4 PSNR-like - ' runName], 'Visible', 'on');

    plot(psnr_ecc_seq, 'k', 'LineWidth', 1.5); hold on;
    plot(psnr_lk_seq,  'r', 'LineWidth', 1.5); hold off;

    grid on;
    xlabel('k (template = frame k, image = frame k+1)');
    ylabel('PSNR-like (dB)');
    legend('ECC','LK','Location','best');
    title(['A4: PSNR-like per consecutive pair - ' strrep(runName,'_','\_')]);

    % Save plot
    exportgraphics(fig, fullfile(outputDir, [runName '_psnr_sequence.png']));
    close(fig);

    % Save numerical data
    save(fullfile(outputDir, [runName '_psnr_sequence.mat']), ...
        'psnr_ecc_seq', 'psnr_lk_seq', ...
        'levels', 'vid', 'resTag');

end

fprintf('\nSaved A4 outputs into %s/ \n', outputDir);