clear;
clc;

% Select the recording and its intended guitar string.
selectedString = "B3";
folder = "StandardTuning";
fileName = "B3_Standard.wav";
rootFolder = fullfile(fileparts(mfilename('fullpath')), 'GuitarNotes');
[audio, Fs] = audioread(fullfile(rootFolder, folder, fileName));

% Use the identical sampling method as generateErrorGraphs.m.
[detectedFreq, pitchEstimates, startTimes] = measurePitch(audio, Fs);

% Display individual window measurements.
for s = 1:length(startTimes)
    [~, cents, status] = checkTuning(pitchEstimates(s), selectedString);
    fprintf('Start: %.1f s | %.2f Hz | %+.2f cents | %s\n', ...
        startTimes(s), pitchEstimates(s), cents, status);
end

% Evaluate the median, not the last window.
[note, cents, status, action, frequencyError] = ...
    checkTuning(detectedFreq, selectedString);
[identifiedNote, ~, ~] = checkTuning(detectedFreq);

fprintf('\nDetected Frequency: %.2f Hz\n', detectedFreq);
fprintf('Detected Note: %s\n', identifiedNote);
fprintf('Target Note: %s\n', note);
fprintf('Frequency Error: %+.2f Hz\n', frequencyError);
fprintf('Tuning Error: %+.2f cents\n', cents);
fprintf('Tuning Status: %s\n', status);
fprintf('Recommended Action: %s\n', action);
