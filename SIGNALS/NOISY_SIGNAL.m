t = (0:0.1:10)';
x = sawtooth(t);

% Apply white Gaussian noise and plot the results.
y = awgn(x,10,'measured');
plot(t,[x y]);
legend('Original Signal','Signal with AWGN');

% sequencia de normalizacoes no intervalo e mediana em zero,
% de forma que os coeficientes fiquem, ao mesmo tempo, entre
% RANGE_N e RANGE_P e com mediana zero.

RANGE_N = -256;
RANGE_P = 255;

f1 = normalize(y,'range',[RANGE_N,RANGE_P]);
f1 = normalize(f1,'center','median');

for v = 1:1:5
    f1 = normalize(f1,'range',[min(f1),RANGE_P]);
    f1 = normalize(f1,'center','median');
end

noise = round(f1);
plot(noise);
writematrix(noise,'noisy_7bits');

