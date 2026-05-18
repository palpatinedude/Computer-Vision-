%% This script read an AVI into a cell array of grayscale double frames in [0,1]
function frames = load_video_frames(videoPath)
    v = VideoReader(videoPath);
    frames = {};
    k = 0;

    while hasFrame(v)
        rgb = readFrame(v);
        k = k + 1;

        % Convert to grayscale 
        if ndims(rgb) == 3
            gray = rgb2gray(rgb);
        else
            gray = rgb;
        end

        % Convert to double [0,1]
        frames{k,1} = im2double(gray);
    end

    % Basic integrity check
    if isempty(frames)
        error('No frames read from: %s', videoPath);
    end
end
