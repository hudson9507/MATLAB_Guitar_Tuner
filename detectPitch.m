function fundamentalFreq = detectPitch(audio, Fs)
% detectPitch - Estimate guitar fundamental frequency using FFT
%
% Inputs:
%   audio - Audio samples from a WAV file or microphone
%   Fs    - Sampling frequency in Hz
%
% Output:
%   fundamentalFreq - Estimated fundamental frequency (Hz)
%                     NaN if no usable signal is detected

% STEP 1: Convert stereo to mono if necessary
if size(audio, 2) > 1
    audio = mean(audio, 2);
end

audio = double(audio(:));

% STEP 2: Check the input
if isempty(audio) || Fs <= 0
    fundamentalFreq = NaN;
    return;
end

% Limit analysis to the first 0.5 seconds
maxSamples = round(0.5 * Fs);
audio = audio(1:min(length(audio), maxSamples));

N = length(audio);

if N < 3 || max(abs(audio)) < 0.001
    fundamentalFreq = NaN;
    return;
end

% STEP 3: Remove DC offset
audio = audio - mean(audio);

% STEP 4: Apply a Hann window
n = (0:N-1)';
window = 0.5 * (1 - cos(2*pi*n/(N-1)));
windowedAudio = audio .* window;

% STEP 5: Compute FFT with zero-padding
NFFT = 2^nextpow2(4*N);
Y = fft(windowedAudio, NFFT);

% STEP 6: Positive-frequency magnitude spectrum
halfN = floor(NFFT/2) + 1;

magnitude = abs(Y(1:halfN));
frequencies = (0:halfN-1)' * Fs/NFFT;

% Normalize magnitude
magnitude = magnitude / (max(magnitude) + eps);

% STEP 7: Search for the guitar fundamental
% Covers standard E2 through E4, with some detuning
candidates = (75:0.05:360)';
scores = zeros(size(candidates));

% STEP 8: Harmonic summation
numHarmonics = 5;

for h = 1:numHarmonics

    harmonicFreq = candidates * h;

    % Check near the expected harmonic frequency
    peakStrength = zeros(size(candidates));

    for offset = -2:1:2
        strengths = interp1( ...
            frequencies, magnitude, ...
            harmonicFreq + offset, 'linear', 0);

        peakStrength = max(peakStrength, strengths);
    end

    % Give lower harmonics more weight
    scores = scores + peakStrength / sqrt(h);
end

% STEP 9: Select the best fundamental candidate
% Find the best frequency using harmonic summation
[~, bestIndex] = max(scores);
estimatedFreq = candidates(bestIndex);

% Refine using the strongest FFT peak near that estimate
searchRange = frequencies >= estimatedFreq - 3 & ...
              frequencies <= estimatedFreq + 3;

localFreqs = frequencies(searchRange);
localMags = magnitude(searchRange);

[~, peakIndex] = max(localMags);

fundamentalFreq = localFreqs(peakIndex);

end