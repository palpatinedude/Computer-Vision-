% Function to compare two videos frame by frame using MSE and PSNR
function compareVideo(originalVideoPath, generatedVideoPath)

    originalVideo = VideoReader(originalVideoPath);
    generatedVideo = VideoReader(generatedVideoPath);

    % Initialize arrays to store MSE and PSNR values for each frame
    numFrames = originalVideo.NumFrames;
    mseValues = zeros(1, numFrames);
    psnrValues = zeros(1, numFrames);

    % Loop through each frame to compute MSE and PSNR
    for frameIdx = 1:numFrames
        % Read the frames from both videos
        origFrame = read(originalVideo, frameIdx);
        genFrame = read(generatedVideo, frameIdx);

        % Resize the generated frame to match the original video's size
        genFrameResized = imresize(genFrame, [originalVideo.Height, originalVideo.Width]);

        % Convert to grayscale if frames are in color
        if size(origFrame, 3) == 3
            origFrame = rgb2gray(origFrame);
        end
        if size(genFrameResized, 3) == 3
            genFrameResized = rgb2gray(genFrameResized);
        end

        % Ensure both frames have the same dimensions
        if ~isequal(size(origFrame), size(genFrameResized))
            error('Frame dimensions do not match between videos.');
        end

        % Compute MSE
        diff = double(origFrame) - double(genFrameResized);
        mseValues(frameIdx) = mean(diff(:).^2);

        % Compute PSNR if MSE is non-zero
        if mseValues(frameIdx) > 0
            psnrValues(frameIdx) = 10 * log10(255^2 / mseValues(frameIdx));
        else
            psnrValues(frameIdx) = Inf; % Perfect match
        end
    end

    % Display results
    fprintf('Average MSE: %.4f\n', mean(mseValues));
    fprintf('Average PSNR: %.2f dB\n', mean(psnrValues));

    % Plot MSE and PSNR values across frames
    figure;
    subplot(2, 1, 1);
    plot(mseValues, '-o');
    title('MSE Across Frames');
    xlabel('Frame Index');
    ylabel('MSE');

    subplot(2, 1, 2);
    plot(psnrValues, '-o');
    title('PSNR Across Frames');
    xlabel('Frame Index');
    ylabel('PSNR (dB)');
end
