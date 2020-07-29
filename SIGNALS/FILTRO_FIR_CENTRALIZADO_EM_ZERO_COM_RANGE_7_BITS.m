numFFT = 1024;           % Number of FFT points
numRBs = 50;             % Number of resource blocks
rbSize = 12;             % Number of subcarriers per resource block

toneOffset = 2.5;        % Tone offset or excess bandwidth (in subcarriers)
L = 513;                 % Filter length (=filterOrder+1), odd

numDataCarriers = numRBs*rbSize;    % number of data subcarriers in sub-band
halfFilt = floor(L/2);
n = -halfFilt:halfFilt;
% Sinc function prototype filter
pb = sinc((numDataCarriers+2*toneOffset).*n./numFFT);
% .* é multiplicação de vetores termo a termo. tamanho dos vetores têm que
% ser iguais. Se o segundo termo for escalar, ele será combinado a todos os
% elementos do primeiro termo (vetor).
% ./ e .^ funcionam da mesma forma. divisão e power de vetores termo a termo.

% Sinc truncation window
w = (0.5*(1+cos(2*pi.*n/(L-1)))).^0.6;

% Normalized lowpass filter coefficients
filter = (pb.*w)/sum(pb.*w);

RANGE_N = -512;
RANGE_P = 511;

f1 = normalize(filter,'range',[RANGE_N,RANGE_P]);
f1 = normalize(f1,'center','median');

f2 = normalize(f1,'range',[min(f1),RANGE_P]);
f2 = normalize(f2,'center','median');

f3 = normalize(f2,'range',[min(f2),RANGE_P]);
f3 = normalize(f3,'center','median');

f4 = normalize(f3,'range',[min(f3),RANGE_P]);
f4 = normalize(f4,'center','median');
filtro = round(f4);
plot(filtro);
writematrix(filtro,'filtro_length_513')
