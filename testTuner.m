clear;
clc;

% STEP 1: Load A2 recording
[audio, Fs] = audioread( ...
    fullfile("GuitarNotes", "StandardTuning", "D3_Standard.wav"));

% STEP 2: Select a section just after the first pluck
% Test several sections of the G3 recording
startTimes = [0.1, 0.2, 0.3, 0.4, 0.5];

for t = startTimes

    startSample = round(t * Fs) + 1;
    endSample = round((t + 0.5) * Fs);

    segment = audio(startSample:endSample, :);

    detectedFreq = detectPitch(segment, Fs);

    [note, cents, status] = checkTuning(detectedFreq);

    fprintf("Start: %.1f s | %.2f Hz | %+.2f cents | %s\n", ...
        t, detectedFreq, cents, status);

end

segment = audio(startSample:endSample, :);

% STEP 3: Detect fundamental frequency
detectedFreq = detectPitch(segment, Fs);

% STEP 4: Check tuning
[note, cents, status, action, frequencyError] = ...
    checkTuning(detectedFreq);

% STEP 5: Display results
fprintf("Detected Frequency: %.2f Hz\n", detectedFreq);
fprintf("Detected Note: %s\n", note);
fprintf("Frequency Error: %+.2f Hz\n", frequencyError);
fprintf("Tuning Error: %+.2f cents\n", cents);
fprintf("Tuning Status: %s\n", status);
fprintf("Recommended Action: %s\n", action);

% Independent FFT peak analysis

% Use a 0.5-second segment of the recording
startSample = round(0.1 * Fs) + 1;
endSample = round(0.6 * Fs);

x = audio(startSample:endSample, :);

% Convert to mono
x = mean(x, 2);

% Remove DC offset
x = x - mean(x);

% Apply Hann window
N = length(x);
n = (0:N-1)';
window = 0.5 * (1 - cos(2*pi*n/(N-1)));

% Calculate FFT
NFFT = 2^nextpow2(4*N);
Y = fft(x .* window, NFFT);

% Generate frequency axis
halfN = floor(NFFT/2) + 1;
f = (0:halfN-1)' * Fs/NFFT;

magnitude = abs(Y(1:halfN));

% Search specifically around D3
searchRange = f >= 140 & f <= 155;

freqRange = f(searchRange);
magRange = magnitude(searchRange);

% Find strongest FFT peak
[~, index] = max(magRange);

peakFrequency = freqRange(index);

fprintf("\nDirect FFT Peak: %.3f Hz\n", peakFrequency);

% Plot frequency spectrum
figure;
plot(freqRange, magRange);
xlabel("Frequency (Hz)");
ylabel("Magnitude");
title("D3 Frequency Spectrum");
grid on;