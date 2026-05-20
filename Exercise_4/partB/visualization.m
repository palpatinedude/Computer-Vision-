%% B1 - Visualization in simulink

clear; close all; clc;

% Dataset path
datasetDir = "../CV_4-ALIGNMENT_mdl";

% Load image and videos
load(fullfile(datasetDir,"img.mat"));
load(fullfile(datasetDir,"vid1.mat"));
load(fullfile(datasetDir,"vid2.mat"));

% Results folder
outputDir = fullfile("results","visualization");

if ~exist(outputDir,"dir")
    mkdir(outputDir);
end

% Inspect variables
whos
