clc
clear all

fs = 200e3; % sampling frequency
ts = 1/fs; % sampling period

% signal duration:
% 0 until the step from one sample to another sample,
% until 5 miliseconds minus one sample
dt=0:ts:5e-3-ts; 

f1=1e3;
f2=20e3;
f3=30e3;

y=5*sin(2*pi*f1*dt)+5*sin(2*pi*f2*dt)+10*sin(2*pi*f3*dt);
% plot(y);

nfft=length(y);
% I need to convert the lenght to power of 2
nfft2=2.^nextpow2(nfft);

fy = fft(y,nfft2);
% resultado será espelhado, então posso pegar só metade
fy = fy(1:nfft2/2);
 
xfft=fs.*(0:nfft2/2-1)/nfft2;
% plot(xfft,abs(fy/max(fy)));

% IMPULSE RESPONSE OF THE LOWPASS FILTER

% escolhi a freq de corte do filtro para 1.5kHz
% mas preciso normalizar para a frequência de Nyquist
% nyquist frequency = sampling frequency / 2
cutoff_frequency = 1.5e3/(fs/2);
order = 32; % order for the impulse response

h = fir1(order,cutoff_frequency);

t = linspace(-4,4,32);
hh = sinc(t);
% plot(t,hh);
% xlabel('Time (sec)');ylabel('Amplitude'); title('Sinc Function')

% TIME DOMAIN --------LEFT SIDE ON THE PLOT-----------------------
% filtering process: convolve the input signal with the filter signal
% con = conv(y,h);
con = conv(y,hh);

subplot(3,2,1);
% divido por max() para normalizar a amplitude para 1
plot(dt,y); % signal time domain
subplot(3,2,3);
plot(hh); %filter impulse response time domain
subplot(3,2,5);
plot(con); %result time domain

% FREQUENCY DOMAIN ------RIGHT SIDE ON THE PLOT---------------------
% filtering process: multiply the input signal with the filter signal

% fh = fft(h,nfft2);
fh = fft(hh,nfft2);
% resultado será espelhado, então posso pegar só metade
fh = fh(1:nfft2/2);

mul = fh.*fy;

subplot(3,2,2);
% divido por max() para normalizar a amplitude para 1
plot(xfft,abs(fy/max(fy))); %signal frequency domain
subplot(3,2,4);
plot(xfft,abs(fh/max(fh))); %filter impulse response frequency domain
subplot(3,2,6);
plot(abs(mul/max(mul))); %result frequency domain


