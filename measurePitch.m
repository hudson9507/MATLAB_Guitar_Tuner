function [detectedFreq, pitchEstimates, startTimes] = measurePitch(audio, Fs)
% measurePitch - Measure pitch across multiple audio sampling windows
% Inputs:
%   audio          - Audio signal containing guitar string recording
%   Fs             - Sampling frequency in Hz
% Outputs:
%   detectedFreq   - Median fundamental frequency in Hz
%   pitchEstimates - Detected frequency from each sampling window
%   startTimes     - Starting time of each sampling window in seconds

%define the sampling windows
startTimes = [0.1, 0.2, 0.3, 0.4, 0.5];
duration = 0.5;
pitchEstimates = NaN(size(startTimes));

%iterate through sampling windows
for s = 1:length(startTimes)
    startSample = round(startTimes(s) * Fs) + 1;
    endSample = round((startTimes(s) + duration) * Fs);
    %validate sampling window
    if endSample > size(audio, 1) || endSample < startSample
        continue;
    end
    %extract audio segment
    segment = audio(startSample:endSample, :);
    %detect fundamental frequency
    f = detectPitch(segment, Fs);
    if isscalar(f) && isreal(f) && isfinite(f) && f > 0
        pitchEstimates(s) = f;
    end
end

%return median pitch estimate
detectedFreq = median(pitchEstimates, 'omitnan');
end
