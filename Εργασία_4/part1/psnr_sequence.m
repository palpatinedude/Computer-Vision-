%{
%% This script sequential frame alignment: template=k, image=k+1


clear; close all; clc;
addpath("../CV_4-ALIGNMENT_mdl/");

load(fullfile("results","A0_data.mat"), "data");

noi          = 30;
transform    = 'affine';
delta_p_init = zeros(2,3);

% Runs
runs = { ...
    struct('video','video2','res','low'),  ...
    struct('video','video2','res','high') ...
    struct('video','video1','res','low'),  ...
    struct('video','video1','res','high') ...
};

A4 = struct();
outdir = "results";   % where plots and .mat files are saved


for rr = 1:numel(runs)
    vid = runs{rr}.video;
    res = runs{rr}.res;

    % Pick frames and pyramid levels based on resolution
    switch lower(res)
        case 'low'
            frames = data.(vid).low.frames;
            levels = 2;
            resTag = 'low';
        case 'high'
            frames = data.(vid).high.frames;
            levels = 3;
            resTag = 'high';
    end

    N = numel(frames);
    psnr_ecc_seq = nan(1, N-1);
    psnr_lk_seq  = nan(1, N-1);

    fprintf('%s_%s | levels=%d | pairs=%d\n', vid, resTag, levels, N-1);


    for k = 1:(N-1)
        template = frames{k};
        image    = frames{k+1};

        % Run alignment: align image (k+1) to template (k)
        [~, ~, MSE, ~, MSELK] = ecc_lk_alignment(image, template, levels, noi, transform, delta_p_init);

        % Use final available value (early stop)
        rmse_ecc = last_finite(MSE);
        rmse_lk  = last_finite(MSELK);

        % Convert to PSNR-like (dB)
        if ~isnan(rmse_ecc) && rmse_ecc > 0
            psnr_ecc_seq(k) = 20*log10(255 / rmse_ecc);
        end
        if ~isnan(rmse_lk) && rmse_lk > 0
            psnr_lk_seq(k)  = 20*log10(255 / rmse_lk);
        end

        close all;
    end

    runName = sprintf('%s_%s_seq', vid, resTag);

    % Store results in struct
    A4.(runName).psnr_ecc = psnr_ecc_seq;
    A4.(runName).psnr_lk  = psnr_lk_seq;
    A4.(runName).levels   = levels;
    A4.(runName).noi      = noi;

    % Plot
    fig = figure('Name', ['A4 PSNR-like - ' runName], 'Visible', 'on');
    plot(psnr_ecc_seq, 'k', 'LineWidth', 1.5); hold on;
    plot(psnr_lk_seq,  'r', 'LineWidth', 1.5); hold off;
    grid on;
    xlabel('k (template = frame k, image = frame k+1)');
    ylabel('PSNR-like (dB)');
    legend('ECC','LK','Location','best');
    title(['A4: PSNR-like per consecutive pair - ' strrep(runName,'_','\_')]);

    % Save plot + per-run mat
    exportgraphics(fig, fullfile(outdir, [runName '_psnr_sequence.png']));
    close(fig);

    save(fullfile(outdir, [runName '_psnr_sequence.mat']), ...
        'psnr_ecc_seq','psnr_lk_seq','levels','noi','vid','resTag');
end

save(fullfile(outdir, 'A4_psnr_sequences_all.mat'), 'A4', 'runs', 'noi', 'transform', 'delta_p_init');

warning('on','all');
fprintf('\nSaved A4 outputs into %s/ (plots + mats)\n', outdir);


function v = last_finite(x)
% Returns last finite positive value of vector x, else NaN
    v = NaN;
    if isempty(x), return; end
    idx = find(isfinite(x) & x > 0, 1, 'last');
    if ~isempty(idx)
        v = x(idx);
    end
end
%}
%% This script sequential frame alignment: template=k, image=k+1


clear; close all; clc;
S = load(fullfile("results","A0_data.mat"), "data");

% Runs
runs = { ...
    struct('video','video2','res','low'),  ...
    struct('video','video2','res','high') ...
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
        [~, ~, MSE, ~, MSELK] = ecc_lk_alignment(image, template, levels, S.data.params.noi, S.data.params.transform, S.data.params.delta_p_init);

        % Use final available value (early stop)
        rmse_ecc = last_finite(MSE);
        rmse_lk  = last_finite(MSELK);

        % Convert to PSNR-like (dB)
        if ~isnan(rmse_ecc) && rmse_ecc > 0
            psnr_ecc_seq(k) = 20*log10(255 / rmse_ecc);
        end
        if ~isnan(rmse_lk) && rmse_lk > 0
            psnr_lk_seq(k)  = 20*log10(255 / rmse_lk);
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
    exportgraphics(fig, fullfile(S.data.params.outputDir, [runName '_psnr_sequence.png']));
    close(fig);

end

fprintf('\nSaved A4 outputs into %s/ \n',S.data.params.outputDir);



