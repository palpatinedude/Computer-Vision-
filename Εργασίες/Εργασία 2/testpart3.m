addpath('transformations/');
addpath('helpers/');
addpath('parts/');

% Input video paths
originalPuddVideo = 'CV_2-TRANSFORMATIONS/photos/pudding.avi';
createdPuddVideo = 'CV_2-TRANSFORMATIONS/photos/sheared_pudding.avi';

% Extract frames from both videos
original_frames = extract_frames(originalPuddVideo, 'original_frames');
distorted_frames = extract_frames(createdPuddVideo, 'pudding_frames');

% Initialize storage for results
num_frames = min(length(original_frames), length(distorted_frames));
horizontal_distortion = zeros(1, num_frames);
base_changes = zeros(1, num_frames);

% Process each frame
for i = 1:num_frames
    original_frame = original_frames{i};
    distorted_frame = distorted_frames{i};
    
    % Align distorted frame with the original frame
    aligned_frame = align_frames(original_frame, distorted_frame);
    
    % Measure horizontal distortion
    horizontal_distortion(i) = measure_horizontal_distortion(original_frame, aligned_frame);
    
    % Assess changes in the base
    base_changes(i) = assess_base_change(original_frame, aligned_frame);
end

% Visualize the results
visualize_results(horizontal_distortion, base_changes);

%% Functions

function [frames] = extract_frames(video_path, output_folder)
    % Read the video and save frames as images
    vid = VideoReader(video_path);
    if ~isfolder(output_folder)
        mkdir(output_folder);
    end
    
    num_frames = floor(vid.Duration * vid.FrameRate);
    frames = cell(1, num_frames);
    
    frame_idx = 1;
    while hasFrame(vid)
        frame = readFrame(vid);
        imwrite(frame, fullfile(output_folder, sprintf('frame_%04d.png', frame_idx - 1)));
        frames{frame_idx} = frame;
        frame_idx = frame_idx + 1;
    end
end

function aligned_frame = align_frames(original_frame, distorted_frame)
    % Convert to grayscale
    gray_original = rgb2gray(original_frame);
    gray_distorted = rgb2gray(distorted_frame);
    
    % Detect and extract SIFT features
    points1 = detectSIFTFeatures(gray_original);
    points2 = detectSIFTFeatures(gray_distorted);
    [features1, valid_points1] = extractFeatures(gray_original, points1);
    [features2, valid_points2] = extractFeatures(gray_distorted, points2);
    
    % Match features
    index_pairs = matchFeatures(features1, features2, 'MatchThreshold', 1.5, 'MaxRatio', 0.8);
    matched_points1 = valid_points1(index_pairs(:, 1));
    matched_points2 = valid_points2(index_pairs(:, 2));
    
    % Check if enough points are available
    if length(matched_points1) < 4 || length(matched_points2) < 4
        warning('Not enough matched points to compute a projective transformation. Returning the distorted frame as is.');
        aligned_frame = distorted_frame; % Return the original distorted frame if alignment fails
        return;
    end
    
    % Estimate transformation matrix
    tform = estimateGeometricTransform2D(matched_points2, matched_points1, 'projective');
    
    % Warp the distorted frame to align it
    aligned_frame = imwarp(distorted_frame, tform, 'OutputView', imref2d(size(original_frame)));
    
    % Display the results
    figure;
    subplot(1, 2, 1);
    imshowpair(original_frame, distorted_frame, 'montage');
    title('Original vs Distorted');
    
    subplot(1, 2, 2);
    imshowpair(original_frame, aligned_frame, 'montage');
    title('Original vs Aligned');
end


function distortion = measure_horizontal_distortion(original_frame, aligned_frame)
    % Measure horizontal distortion by comparing pixel displacements
    gray_original = rgb2gray(original_frame);
    gray_aligned = rgb2gray(aligned_frame);
    
    % Find edge boundaries
    edges_original = edge(gray_original, 'Canny');
    edges_aligned = edge(gray_aligned, 'Canny');
    
    % Calculate the horizontal centroid for both frames
    [rows, cols] = find(edges_original);
    original_centroid = mean(cols);
    [rows, cols] = find(edges_aligned);
    aligned_centroid = mean(cols);
    
    % Compute horizontal distortion as the displacement
    distortion = abs(aligned_centroid - original_centroid);
end

function base_change = assess_base_change(original_frame, aligned_frame)
    % Assess changes in the base width (horizontal line at the bottom)
    gray_original = rgb2gray(original_frame);
    gray_aligned = rgb2gray(aligned_frame);
    
    % Select the bottom region of both frames
    base_region_original = gray_original(end-10:end, :);
    base_region_aligned = gray_aligned(end-10:end, :);
    
    % Compute the width of non-zero intensity (base width)
    base_width_original = sum(any(base_region_original, 1));
    base_width_aligned = sum(any(base_region_aligned, 1));
    
    % Measure the change in base width
    base_change = abs(base_width_aligned - base_width_original);
end

function visualize_results(horizontal_distortion, base_changes)
    % Visualize the results with plots
    figure;
    
    subplot(2, 1, 1);
    plot(horizontal_distortion, 'r-', 'LineWidth', 2);
    title('Horizontal Distortion Over Frames');
    xlabel('Frame Number');
    ylabel('Distortion (pixels)');
    
    subplot(2, 1, 2);
    plot(base_changes, 'b-', 'LineWidth', 2);
    title('Base Changes Over Frames');
    xlabel('Frame Number');
    ylabel('Base Change (pixels)');
end
