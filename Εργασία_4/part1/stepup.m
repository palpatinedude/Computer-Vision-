%% This script load all video frames and constants into memory

clear; close all; clc;

% Project root directory 
projectDir = fullfile(pwd, "../CV_4-ALIGNMENT_mdl");

% Results directory
outputDir = fullfile(pwd, "results/");

% Utils
utils = fullfile(pwd, "utils/");



% Video files
files.video1_low  = fullfile(projectDir, "video1_low.avi");
files.video1_high = fullfile(projectDir, "video1_high.avi");
files.video2_low  = fullfile(projectDir, "video2_low.avi");
files.video2_high = fullfile(projectDir, "video2_high.avi");


% Load frames 
% Each element: frames{k} = grayscale double image in [0,1]
data.video1.low.frames  = load_video_frames(files.video1_low);
data.video1.high.frames = load_video_frames(files.video1_high);
data.video2.low.frames  = load_video_frames(files.video2_low);
data.video2.high.frames = load_video_frames(files.video2_high);

% Parameters 
data.params = struct();

data.params.noi          = 30;          % iterations per pyramid level
data.params.transform    = 'affine';    % motion model
data.params.delta_p_init = zeros(2,3);  % initial affine parameters (increment form)
data.params.projectDir   = projectDir;
data.params.outputDir = outputDir;
data.params.utils = utils;
data.params.transform = 'affine';

fprintf("Loaded frames:\n");
fprintf("video1_low:  %d frames, size %dx%d\n", ...
    numel(data.video1.low.frames), ...
    size(data.video1.low.frames{1},1), ...
    size(data.video1.low.frames{1},2));

fprintf("video1_high: %d frames, size %dx%d\n", ...
    numel(data.video1.high.frames), ...
    size(data.video1.high.frames{1},1), ...
    size(data.video1.high.frames{1},2));

fprintf("video2_low:  %d frames, size %dx%d\n", ...
    numel(data.video2.low.frames), ...
    size(data.video2.low.frames{1},1), ...
    size(data.video2.low.frames{1},2));

fprintf("video2_high: %d frames, size %dx%d\n", ...
    numel(data.video2.high.frames), ...
    size(data.video2.high.frames{1},1), ...
    size(data.video2.high.frames{1},2));


doVisualCheck = true;   % set false to disable
if doVisualCheck
    figure("Name","Sanity check: first frame of each sequence");
    subplot(2,2,1); imshow(data.video1.low.frames{1},[]);  title("video1 low - frame 1");
    subplot(2,2,2); imshow(data.video1.high.frames{1},[]); title("video1 high - frame 1");
    subplot(2,2,3); imshow(data.video2.low.frames{1},[]);  title("video2 low - frame 1");
    subplot(2,2,4); imshow(data.video2.high.frames{1},[]); title("video2 high - frame 1");
end

save(fullfile("results", "A0_data.mat"), "data", "files");
fprintf("Saved workspace to results/A0_data.mat\n");



