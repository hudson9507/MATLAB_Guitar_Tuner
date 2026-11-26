function [detectedFreq, pitchEstimates, startTimes] = measurePitch(audio, Fs)
% Shared sampling method for individual tests and report graphs.
startTimes = [0.1, 0.2, 0.3, 0.4, 0.5];
duration = 0.5;
pitchEstimates = NaN(size(startTimes));

for s = 1:length(startTimes)
    startSample = round(startTimes(s) * Fs) + 1;
    endSample = round((startTimes(s) + duration) * Fs);
    if endSample > size(audio, 1) || endSample < startSample
        continue;
    end
    segment = audio(startSample:endSample, :);
    f = detectPitch(segment, Fs);
    if isscalar(f) && isreal(f) && isfinite(f) && f > 0
        pitchEstimates(s) = f;
    end
end

detectedFreq = median(pitchEstimates, 'omitnan');
end
