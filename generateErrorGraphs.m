
clear;
clc;
close all;

%% 1. Define guitar notes and tuning conditions

notes = ["E2", "A2", "D3", "G3", "B3", "E4"];

folders = ["FlatTuning", ...
           "SlightFlatTuning", ...
           "StandardTuning", ...
           "SlightSharpTuning", ...
           "SharpTuning"];

labels = ["Flat", "Slightly Flat", "Standard", ...
          "Slightly Sharp", "Sharp"];

rootFolder = fullfile(fileparts(mfilename('fullpath')), ...
                      'GuitarNotes');

%% 2. Initialize result matrices

detectedFreq = NaN(length(notes), length(folders));
frequencyError = NaN(length(notes), length(folders));
tuningError = NaN(length(notes), length(folders));

%% 3. Analyze each recording

for i = 1:length(notes)

    for j = 1:length(folders)

        folderPath = fullfile(rootFolder, folders(j));

        % Find the WAV file corresponding to the note
        if j == 2 && ~isfolder(folderPath)
            folderPath = fullfile(rootFolder, "SlightlyFlatTuning");
        end
        files = dir(fullfile(folderPath, notes(i) + "_*.wav"));

        if isempty(files)
            warning('Missing file: %s in %s', ...
                    notes(i), folders(j));
            continue;
        end

        % Analyze each matching recording
        estimates = NaN(length(files), 1);

        for k = 1:length(files)

            filePath = fullfile(files(k).folder, files(k).name);

            % Read audio recording
            [audio, Fs] = audioread(filePath);

            % Use the same sampling method as testTuner.m
            estimates(k) = measurePitch(audio, Fs);
            fprintf('%s | %.5f Hz\n', files(k).name, estimates(k));

        end

        % Average multiple recordings if present
        detectedFreq(i,j) = mean(estimates, 'omitnan');

        % Use the same reference frequencies and error formulas as the tuner
        [~, tuningError(i,j), ~, ~, frequencyError(i,j)] = ...
            checkTuning(detectedFreq(i,j), notes(i));

    end

end

%% 4. Generate frequency error graph

figure('Color', 'w');

bar(frequencyError, 'grouped');

set(gca, 'XTick', 1:length(notes), ...
         'XTickLabel', notes, ...
         'FontSize', 12);

title('Frequency Error by Guitar String');
xlabel('Guitar String');
ylabel('Frequency Error (Hz)');

lgd = legend(labels, 'Location', 'bestoutside', 'AutoUpdate', 'off');

yline(0, 'k-', 'LineWidth', 1, 'HandleVisibility', 'off');

grid on;
box on;

% Set background and text colors

set(gcf, 'Color', 'white');

ax = gca;
ax.Color = 'white';
ax.XColor = 'black';
ax.YColor = 'black';
ax.Title.Color = 'black';
ax.XLabel.Color = 'black';
ax.YLabel.Color = 'black';
ax.GridColor = [0.5 0.5 0.5];

% Set legend colors

lgd.TextColor = 'black';
lgd.Color = 'white';
lgd.EdgeColor = 'black';

exportgraphics(gcf, 'FrequencyError.png', ...
               'Resolution', 300);

%% 5. Generate tuning error graph

figure('Color', 'w');

bar(tuningError, 'grouped');

set(gca, 'XTick', 1:length(notes), ...
         'XTickLabel', notes, ...
         'FontSize', 12);

title('Tuning Error by Guitar String');
xlabel('Guitar String');
ylabel('Tuning Error (Cents)');

lgd = legend(labels, 'Location', 'bestoutside', 'AutoUpdate', 'off');

yline(0, 'k-', 'LineWidth', 1, 'HandleVisibility', 'off');

% Example tuning tolerance
yline(5, 'k--', '+5 Cent Tolerance', ...
      'HandleVisibility', 'off');

yline(-5, 'k--', '-5 Cent Tolerance', ...
      'HandleVisibility', 'off');

grid on;
box on;

% Set background and text colors

set(gcf, 'Color', 'white');

ax = gca;
ax.Color = 'white';
ax.XColor = 'black';
ax.YColor = 'black';
ax.Title.Color = 'black';
ax.XLabel.Color = 'black';
ax.YLabel.Color = 'black';
ax.GridColor = [0.5 0.5 0.5];

% Set legend colors

lgd.TextColor = 'black';
lgd.Color = 'white';
lgd.EdgeColor = 'black';

exportgraphics(gcf, 'TuningError.png', ...
               'Resolution', 300);

%% 6. Display numerical results

disp('Detected Frequencies (Hz):');

disp(array2table(detectedFreq, ...
    'RowNames', cellstr(notes), ...
    'VariableNames', cellstr(folders)));

disp('Frequency Error (Hz):');

disp(array2table(frequencyError, ...
    'RowNames', cellstr(notes), ...
    'VariableNames', cellstr(folders)));

disp('Tuning Error (Cents):');

disp(array2table(tuningError, ...
    'RowNames', cellstr(notes), ...
    'VariableNames', cellstr(folders)));

