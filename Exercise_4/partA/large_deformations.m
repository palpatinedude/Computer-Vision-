%% This script runs the ECC-LK alignment algorithm on selected frame pairs

clear; close all; clc;
S = load(fullfile("results","A0_data.mat"), "data");

addpath(genpath('utils'));

% Output folder
outputDir = fullfile("results","large_deformations");

if ~exist(outputDir, "dir")
    mkdir(outputDir);
end

% Frame pair definition 
tid       = 1;              % template frame index
test_iids = [10 30 50];     % target frame indices

% What to run 
runs = { ...
    struct('video','video2','res','low'),  ...
    struct('video','video2','res','high'), ...
    struct('video','video1','res','low'), ...
    struct('video','video1','res','high') ...
};


% Main loop 
for rr = 1:numel(runs)
    vid = runs{rr}.video;
    res = runs{rr}.res;

    % Select frames and pyramid levels based on resolution
    [frames, levels, resTag] = pick_frames_levels(S, vid, res);

    fprintf('Running %s_%s (levels=%d)\n', vid, resTag, levels);
    fprintf('template=%d, targets=[%s]\n', tid, num2str(test_iids));

    for r = 1:numel(test_iids)
        iid = test_iids(r);

        % Select template and target image
        template = frames{tid};
        image    = frames{iid};

        fprintf("\n=== Run %d/%d: %s_%s | template=%d, image=%d ===\n", ...
            r, numel(test_iids), vid, resTag, tid, iid);

        % Run ECC + LK alignment
        [results, results_lk, MSE, rho, MSELK] = ...
            ecc_lk_alignment(image, template, levels, S.data.params.noi, S.data.params.transform, S.data.params.delta_p_init);

        % Store
        runName = sprintf('%s_%s_t%d_i%d', vid, resTag, tid, iid);

        % Plot convergence
        fig = figure('Name', ['Convergence - ' runName], 'Visible','on');

        % ECC correlation over iterations
        subplot(2,1,1);
        plot(rho, 'LineWidth', 1.5);
        grid on;
        xlabel('Iteration');
        ylabel('\rho (ECC)');
        title(['ECC correlation \rho - ' runName]);

        % PSNR-like metric for ECC and LK (from RMSE vectors)
        subplot(2,1,2);
        psnr_ecc = 20*log10(255 ./ MSE);
        psnr_lk  = 20*log10(255 ./ MSELK);
        plot(psnr_ecc, 'k', 'LineWidth', 1.5); hold on;
        plot(psnr_lk,  'r', 'LineWidth', 1.5); hold off;
        grid on;
        xlabel('Iteration');
        ylabel('PSNR-like (dB)');
        legend('ECC','LK', 'Location','best');
        title(['PSNR-like vs iteration - ' runName]);

        % Save convergence plot
        exportgraphics(fig, fullfile(outputDir, [runName '_convergence.png']));

        close(fig);
    end
end

fprintf('\nSaved A3 outputs into %s/ \n',outputDir);
