notes = ["E2", "A2", "D3", "G3", "B3", "E4"];
offsets = [-50, -25, 25, 50];

for i = 1:length(notes)

    filename = notes(i) + "_Standard.wav";
    [audio, Fs] = audioread(filename);

    for cents = offsets

        ratio = 2^(cents / 1200);

        [p, q] = rat(1 / ratio, 1e-6);

        shiftedAudio = resample(audio, p, q);

        outputName = sprintf("%s_%+d_cents.wav", ...
            char(notes(i)), cents);

        audiowrite(outputName, shiftedAudio, Fs);

    end
end