%% This script loads all video frames and constants into memory

clear; close all; clc;

%% Paths
projectDir = fullfile(pwd, "../CV_4-ALIGNMENT_mdl");
outputDir  = fullfile(pwd, "results");
utilsDir   = fullfile(pwd, "utils");

addpath(projectDir);
addpath(utilsDir);

if ~exist(outputDir, "dir")
    mkdir(outputDir);
end

%% Video files
files.video1_low  = fullfile(projectDir, "video1_low.avi");
files.video1_high = fullfile(projectDir, "video1_high.avi");
files.video2_low  = fullfile(projectDir, "video2_low.avi");
files.video2_high = fullfile(projectDir, "video2_high.avi");

%% Load frames
data.video1.low.frames  = load_video_frames(files.video1_low);
data.video1.high.frames = load_video_frames(files.video1_high);
data.video2.low.frames  = load_video_frames(files.video2_low);
data.video2.high.frames = load_video_frames(files.video2_high);

%% Parameters
data.params = struct();

data.params.noi          = 30;
data.params.transform    = 'affine';
data.params.delta_p_init = zeros(2,3);

data.params.projectDir = projectDir;
data.params.outputDir  = outputDir;
data.params.utilsDir   = utilsDir;

%% Print info
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

%% Visual check
doVisualCheck = true;

if doVisualCheck
    figure("Name","Sanity check: first frame of each sequence");

    subplot(2,2,1);
    imshow(data.video1.low.frames{1},[]);
    title("video1 low - frame 1");

    subplot(2,2,2);
    imshow(data.video1.high.frames{1},[]);
    title("video1 high - frame 1");

    subplot(2,2,3);
    imshow(data.video2.low.frames{1},[]);
    title("video2 low - frame 1");

    subplot(2,2,4);
    imshow(data.video2.high.frames{1},[]);
    title("video2 high - frame 1");
end

%% Save workspace
save(fullfile(outputDir, "A0_data.mat"), "data", "files");

fprintf("Saved workspace to %s\n", fullfile(outputDir, "A0_data.mat"));