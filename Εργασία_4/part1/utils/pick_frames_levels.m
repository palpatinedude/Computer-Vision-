%% Select frames and pyramid levels by resolution
function [frames, levels, resTag] = pick_frames_levels(S, vid, res)
    switch lower(res)
        case 'low'
            frames = S.data.(vid).low.frames;
            levels = 2;
            resTag = 'low';

        case 'high'
            frames = S.data.(vid).high.frames;
            levels = 3;
            resTag = 'high';

    end
end
