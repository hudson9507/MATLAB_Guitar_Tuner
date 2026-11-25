function [y, isSilent, state] = processAudio(x, fs, state); %state is memory
    fLow      = 70;
    fHigh     = 1500;
    order     = 2;
    threshold = -32;

    wN = [fLow fHigh] / (fs/2);              %fraction of Nyquist
    [b, a] = butter(order, wN, 'bandpass');
    
    if nargin < 3 || isempty(state)          %Number of arguments
        state = zeros(length(a) - 1, 1);
    end

    [y, state] = filter(b, a, x, state);

    level = 20*log10(sqrt(mean(y.^2)));      %RMS of the filtered audio
    isSilent = level < threshold;            %true if quieter than given threshold
end


%fs must be 44100
%