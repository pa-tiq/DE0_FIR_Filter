Ts = 0.01; N=2000; t=-20:Ts:(N-1)*Ts;
T = 1;
fs=1/Ts;
f=0:fs/N:(N-1)/N*fs;
x1 = rectpuls(t, T);
xk=fft(x1);
figure(1); plot(t,x1);
figure(3); plot(f, 1/N*abs(xk(1:length(f))));