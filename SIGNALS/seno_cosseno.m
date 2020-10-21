
L = 2048;

t = linspace(0,pi,L);
filter = sin(t);

%x=[(1:8)*20,zeros(1,L-8)];
%plot(x);
%writematrix(x,'seno_cosseno');
 
%RANGE_N = -16379; %cosseno
RANGE_N = 0;     %seno
RANGE_P = 16384;

% sequencia de normalizacoes no intervalo e mediana em zero,
% de forma que os coeficientes fiquem, ao mesmo tempo, entre
% RANGE_N e RANGE_P e com mediana zero.

f1 = normalize(filter,'range',[RANGE_N,RANGE_P]);

filtro = round(f1);
writematrix(filtro,'seno_cosseno');
plot(filtro);



