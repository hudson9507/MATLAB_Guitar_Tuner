
function fundamentalFreq = detectPitch(audio, Fs)
% detectPitch - Detect the fundamental frequency of a guitar string

%% STEP 1: Convert audio to mono

audio = mean(audio, 2);

%% STEP 2: Remove DC offset

audio = audio - mean(audio);

% Check for invalid or silent audio
if isempty(audio) || max(abs(audio)) < 1e-6
    fundamentalFreq = NaN;
    return;
end

%% STEP 3: Select audio duration

N = min(length(audio), round(0.5 * Fs));
audio = audio(1:N);

%% STEP 4: Apply Hann window

window = 0.5 - 0.5*cos(2*pi*(0:N-1)'/(N-1));
audio = audio .* window;

%% STEP 5: Calculate zero-padded FFT

NFFT = 2^nextpow2(8 * N);

Y = fft(audio, NFFT);

magnitude = abs(Y(1:NFFT/2+1));

frequencies = (0:NFFT/2)' * Fs / NFFT;

%% STEP 6: Define possible fundamental frequencies

candidates = 75:0.05:360;

scores = zeros(size(candidates));

%% STEP 7: Weighted harmonic summation

numHarmonics = 5;

for h = 1:numHarmonics

    harmonicFreqs = h * candidates;

    harmonicMagnitudes = interp1( ...
        frequencies, magnitude, ...
        harmonicFreqs, 'linear', 0);

    scores = scores + harmonicMagnitudes / h;

end

%% STEP 8: Identify the fundamental frequency

[~, index] = max(scores);

fundamentalFreq = candidates(index);

end