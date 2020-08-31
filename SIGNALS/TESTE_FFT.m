Fs = 900;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = 257;             % Length of signal
t = (0:L-1)*T;        % Time vector
halfFilt = floor(L/2);
n = -halfFilt:halfFilt;

S = 0.7*sin(2*pi*50*t) + sin(2*pi*120*t);
X = S + randn(size(t));
plot(1000*t(1:50),X(1:50));
title('Signal Corrupted with Zero-Mean Random Noise');
xlabel('t (milliseconds)');
ylabel('X(t)');

%Y = fft(X);
%P2 = abs(Y/L);
%P1 = P2(1:L/2+1);
%P1(2:end-1) = 2*P1(2:end-1);
%f = Fs*(0:(L/2))/L;
%plot(f,P1) ;
%title('Single-Sided Amplitude Spectrum of X(t)');
%xlabel('f (Hz)');
%ylabel('|P1(f)|');

w = hamming(L)';
hh = 0.4*sinc(0.15*n);
filterr = hh.*w;
Y = fft(filterr);
P2 = abs(Y/L);
P1 = P2(1:floor(L/2)+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
plot(f,P1) ;
plot(f,P1) ;
title('Single-Sided Amplitude Spectrum of X(t)');
xlabel('f (Hz)');
ylabel('|P1(f)|');

RANGE_N = -512;
RANGE_P = 511;

filter = X;

% sequencia de normalizacoes no intervalo e mediana em zero,
% de forma que os coeficientes fiquem, ao mesmo tempo, entre
% RANGE_N e RANGE_P e com mediana zero.

f1 = normalize(filter,'range',[RANGE_N,RANGE_P]);
f1 = normalize(f1,'center','median');

for v = 1:1:5
    f1 = normalize(f1,'range',[min(f1),RANGE_P]);
    f1 = normalize(f1,'center','median');
end

filtro = round(f1);
writematrix(filtro,'sinal_ruidoso');
