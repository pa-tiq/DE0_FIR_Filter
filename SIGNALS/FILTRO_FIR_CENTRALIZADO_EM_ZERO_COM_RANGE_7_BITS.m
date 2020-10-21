BIT_WIDTH = 10;
L = 513; % tamanho do filtro tem que ser L+1
halfFilt = floor(L/2);
n = -halfFilt:halfFilt;

%w = (0.5*(1+cos(2*pi.*n/(L-1)))).^0.6; % janela de hanning
%t = linspace(-2,2,L);
%hh = sinc(t);
%filter = (hh.*w)/sum(hh.*w);

a = 1; %amplitude
b = 0.1; %quanto maior, mais fininho, geralmente está em 0.15
w = blackman(L)';
hh = a*sinc(b*n);
filter = hh.*w;
%fvtool(filter,1);

RANGE_N = -512;
RANGE_P = 511;

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
writematrix(filtro,'filtro_2048');

Y = fft(filtro);
plot(real(Y));

tiledlayout(1,3);
nexttile;
plot(w);grid on;
pbaspect([1 1 1]);
title("janela para truncamento do sinc");
nexttile;
plot(hh);grid on;
pbaspect([1 1 1]);
title("funcao sinc");
nexttile;
plot(filtro);grid on;
pbaspect([1 1 1]);
title("funcao sinc-janelada");



