function videoParameters = checkVideo(videoPath)
    % Load the video
    video = VideoReader(videoPath);

    % Create a structure to store properties
    videoParameters = struct();
    videoParameters.Resolution = [video.Width, video.Height];
    videoParameters.FrameRate = video.FrameRate;
    videoParameters.NumFrames = video.NumFrames;
    videoParameters.Duration = video.Duration;
    videoParameters.Width = video.Width;
    videoParameters.Height = video.Height;

    % Display general video properties
    fprintf('Video File: %s\n', videoPath);
    fprintf('Resolution: %dx%d\n', video.Width, video.Height);
    fprintf('Frame Rate: %.2f fps\n', video.FrameRate);
    fprintf('Total Frames: %d\n', video.NumFrames);
    fprintf('Duration: %.2f seconds\n', video.Duration);

     % Extract and display pixel intensity statistics for the first frame
    firstFrame = read(video, 1);
    if size(firstFrame, 3) == 3
        firstFrameGray = rgb2gray(firstFrame);
        disp("Isnt grayscale . ");
    else
        firstFrameGray = firstFrame;
    end
    fprintf('First Frame - Min Intensity: %d\n', min(firstFrameGray(:)));
    fprintf('First Frame - Max Intensity: %d\n', max(firstFrameGray(:)));
    fprintf('First Frame - Mean Intensity: %.2f\n', mean(firstFrameGray(:)));
end