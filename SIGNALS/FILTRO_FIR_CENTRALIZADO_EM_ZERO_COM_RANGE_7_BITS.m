L = 257; % tamanho do filtro
halfFilt = floor(L/2);
n = -halfFilt:halfFilt;

w = (0.5*(1+cos(2*pi.*n/(L-1)))).^0.6; % janela de hanning
tiledlayout(1,3);nexttile;plot(w);grid on;
pbaspect([1 1 1]);
title("janela para truncamento do sinc");


t = linspace(-4,4,L);
hh = sinc(t);
nexttile;plot(hh);grid on;pbaspect([1 1 1]);
title("funcao sinc");

filter = (hh.*w)/sum(hh.*w);

RANGE_N = -256;
RANGE_P = 255;

% sequencia de normalizacoes no intervalo e mediana em zero,
% de forma que os coeficientes fiquem, ao mesmo tempo, entre
% RANGE_N e RANGE_P e com mediana zero.

% sequencia de normalizacoes no intervalo e mediana em zero,
% de forma que os coeficientes fiquem, ao mesmo tempo, entre
% RANGE_N e RANGE_P e com mediana zero.

f1 = normalize(filter,'range',[RANGE_N,RANGE_P]);
f1 = normalize(f1,'center','median');

<<<<<<< HEAD
for v = 1:1:3
=======
for v = 1:1:5
>>>>>>> db988fa996cff1a3fadd5d26d08dfdf12fa26a99
    f1 = normalize(f1,'range',[min(f1),RANGE_P]);
    f1 = normalize(f1,'center','median');
end

filtro = round(f1);
nexttile;plot(filtro);grid on;pbaspect([1 1 1]);
title("funcao sinc-janelada");

<<<<<<< HEAD
writematrix(filtro,'filtro');
=======
writematrix(filtro,'filtro');
>>>>>>> db988fa996cff1a3fadd5d26d08dfdf12fa26a99
