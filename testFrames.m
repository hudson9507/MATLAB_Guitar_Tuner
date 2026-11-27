frameLen = round(0.1 * fs);
nFrames = floor(length(x) / frameLen);
xx = x(1:nFrames*frameLen);
yWhole = processAudio(xx, fs);           

state = [];
yWith = [];
yWithout = [];
for k = 1:nFrames
    idx = (k-1)*frameLen + 1 : k*frameLen;
    [yk, ~, state] = processAudio(xx(idx), fs, state);   
    yWith = [yWith; yk];
    yWithout = [yWithout; processAudio(xx(idx), fs)];
end

errorWith    = max(abs(yWith - yWhole))
errorWithout = max(abs(yWithout - yWhole))

t = (0:length(xx)-1)' / fs;
figure;
plot(t, yWhole, t, yWithout, '--', 'LineWidth', 1.2);
xlim([0.95 1.05]);
ylim([-0.25, .2]);
legend('Whole recording', 'Frames without memory');
xlabel('Time (s)');
ylabel('Amplitude');
theme(gcf, "light")
grid on;