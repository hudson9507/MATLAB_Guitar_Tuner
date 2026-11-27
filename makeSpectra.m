N = length(x);
f = (0:N-1)' * fs / N;
half = 1:floor(N/2);
X = abs(fft(x));
S = abs(fft(s(1:N)));                     

figure;
plot(f(half), X(half), 'LineWidth', 1);
xlim([0 2000]);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;
theme(gcf, "light")
exportgraphics(gcf, 'fig_spectrum_A.png', 'Resolution', 300)

figure;
plot(f(half), S(half), 'LineWidth', 1);
xlim([0 1000]);
xlabel('Frequency (Hz)'); ylabel('Magnitude');
grid on;
