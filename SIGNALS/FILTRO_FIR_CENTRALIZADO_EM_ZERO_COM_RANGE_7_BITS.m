%GERAR FILTRO DE TAMANHO L
L = 513; %tamanho do filtro
halfFilt = floor(L/2);
n = -halfFilt:halfFilt;
w = (0.5*(1+cos(2*pi.*n/(L-1)))).^0.6; %janela

t = linspace(-4,4,L);
hh = sinc(t);
filter = (hh.*w)/sum(hh.*w);

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
writematrix(filtro,'filtro_length_513');
