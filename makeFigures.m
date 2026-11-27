[b, a] = butter(2, [70 2000] / (fs/2), 'bandpass');
[H, F] = freqz(b, a, 8192, fs);           
figure;
semilogx(F, 20*log10(abs(H)));
xlim([10 20000]); ylim([-60 5]);
xlabel('Frequency (Hz)'); ylabel('Gain (dB)'); grid on;
theme(gcf, "light");
exportgraphics(gcf, 'fig_filter.png', 'Resolution', 300);

y = processAudio(xq, fs);
N = length(xq);
f = (0:N-1)' * fs / N;
Xdb = 20*log10(abs(fft(xq)));
Ydb = 20*log10(abs(fft(y)));
h = 2:floor(N/2);   

figure;
semilogx(f(h), Xdb(h), f(h), Ydb(h));
xlim([10 20000]);
legend('Before', 'After'); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); grid on;

L = round(0.1 * fs);                      
q = processAudio(xq, fs);
m = processAudio(xm, fs);
n = floor(length(q) / L);
q = reshape(q(1:n*L), L, n);               
m = reshape(m(1:n*L), L, n);
levelQ = 20*log10(sqrt(mean(q.^2)));
levelM = 20*log10(sqrt(mean(m.^2)));
t = (0:n-1) * 0.1;
figure;
plot(t, levelQ, '-o', t, levelM, '-o');
yline(-32, 'r--');
legend('Quiet room', 'Music', 'Threshold'); xlabel('Time (s)'); ylabel('Level (dBFS)'); grid on;

quietNoise = max(levelQ(1:5))              
musicNoise = max(levelM(1:5))