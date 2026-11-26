function [note, cents, status, action, frequencyError] = ...
    checkTuning(detectedFreq, selectedString)
%checkTuning - Compare detected pitch to standard guitar tuning
%Inputs:
%  detectedFreq   - Fundamental frequency in Hz
%  selectedString - Optional string name, e.g. "A2"
%Outputs:
%  note           - Identified guitar string
%  cents          - Tuning error in cents
%  status         - Flat, Sharp, In Tune, or No Signal
%  action         - Tighten, Loosen, or None
%  frequencyError - Difference from target in Hz

%shared reference notes (also used by report graphs)
notes = ["E2", "A2", "D3", "G3", "B3", "E4"];
referenceFreqs = ...
    [82.41, 110, 146.83, 196, 246.94, 329.63];

%handle invalid pitch input
if ~isscalar(detectedFreq) || ...
        ~isfinite(detectedFreq) || detectedFreq <= 0

    note = "Unknown";
    cents = NaN;
    status = "No Signal";
    action = "None";
    frequencyError = NaN;
    return;
end

%select the reference string
if nargin >= 2 && ~isempty(selectedString)
    index = find(notes == string(selectedString), 1);
    if isempty(index)
        error("Invalid guitar string selected.");
    end
else
    %identify the closest reference in musical pitch
    differences = abs( ...
        1200 * log2(detectedFreq ./ referenceFreqs));
    [~, index] = min(differences);
end
note = notes(index);
targetFreq = referenceFreqs(index);

%calculate frequency error in Hz
frequencyError = detectedFreq - targetFreq;

%calculate pitch error in cents
cents = 1200 * log2(detectedFreq / targetFreq);

%determine tuning status
tolerance = 5;
if abs(cents) <= tolerance
    status = "In Tune";
    action = "None";
elseif cents < -tolerance
    status = "Flat";
    action = "Tighten";
else
    status = "Sharp";
    action = "Loosen";
end
end