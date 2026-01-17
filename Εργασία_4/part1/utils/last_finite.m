%% This script return the last finite, positive value in an array
function v = last_finite(x)
    v = NaN;

    if isempty(x)
        return;
    end

    idx = find(isfinite(x) & x > 0, 1, 'last');

    if ~isempty(idx)
        v = x(idx);
    end
end
