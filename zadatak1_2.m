clear
close all
clc

%% Ucitavanje snimljene govorne sekvence

[x, fs] = audioread('Recording_4.wav');

%% Filtriranje govornog signala i graficki prikaz

Wn = [60 3500]/(fs/2); % fs/2 zbog digitalnog filtra
[B,A] = butter(6,Wn,'bandpass'); 

xf = filter(B,A,x); % filtrirani signal

figure(1)
plot(1/fs:1/fs:length(x)/fs,x)
hold on
plot(1/fs:1/fs:length(x)/fs,xf)
hold off
title('Vremenski oblik signala','Interpreter','latex')
legend('pre filtriranja','posle filtriranja','Interpreter','latex')
xlabel('t[s]','Interpreter','latex')

N = 2048;

X = fft(x,N);
Xa = abs(X(1:N/2+1));
Xf = fft(xf,N);
Xaf = abs(Xf(1:N/2+1));
figure(2)
plot(0:fs/N:fs/2,Xa)
hold on
plot(0:fs/N:fs/2,Xaf)
hold off
xlabel('f[Hz]','Interpreter','latex')
ylabel('|X(jf)|','Interpreter','latex')
title('Amplitudska karakteristika signala','Interpreter','latex')
legend('pre filtriranja','posle filtriranja','Interpreter','latex')

%% Kratkovremenske karakteristike signala

wl = 20*10^(-3)*fs; % duzina prozora u odbircima

STE = zeros(size(xf)); % kratkovremenska energija
ZCR = zeros(size(xf)); % zero crossing rate

for i = wl:length(xf)
    rng = (i - wl + 1):i-1;
    STE(i) = sum(xf(rng).^2);
    ZCR(i) = sum(abs(sign(xf(rng + 1)) - sign(xf(rng))));
end
ZCR = ZCR/wl/2;

t = 1/fs:1/fs:length(STE)/fs;

figure(3)
plotyy(t,xf,t,STE)
title('Kratkovremenska Energija','Interpreter','latex')
xlabel('t[s]','Interpreter','latex')
legend('signal','energija','Interpreter','latex')

figure(4)
plotyy(t,xf,t,ZCR)
title('Kratkovremenski Zero Crossing Rate','Interpreter','latex')
xlabel('t[s]','Interpreter','latex')
legend('signal','ZCR','Interpreter','latex')

%% Segmentacija govorne sekvence pomocu kratkovremenske energije

ITU = 0.1*max(STE);
ITL = 5*0.00001*max(STE);

pocetak = [];
kraj = [];

% poredjenje sa vecim pragom ITU
for i = 2:length(STE)
    if STE(i) > ITU && STE(i-1) < ITU
        pocetak = [pocetak i];
    end
    if STE(i) < ITU && STE(i-1) > ITU
        kraj = [kraj i];
    end
end

rec = zeros(1,length(STE));

for i = 1:length(pocetak)
    rec(pocetak(i):kraj(i)) = max(STE);
end

% Detekcija nakon poredjenja sa vecim pragom
figure(5)
plot(t,STE,t,rec)
xlabel('t[s]','Interpreter','latex')
title('Inicijalna segmentacija','Interpreter','latex') 

% Poredjenje sa nizim pragom
for i = 1:length(pocetak)
    pomeraj = pocetak(i);
    while STE(pomeraj)>ITL
        pomeraj = pomeraj - 1;
    end
    pocetak(i) = pomeraj; 
end

for i = 1:length(kraj)
    pomeraj = kraj(i);
    while STE(pomeraj)>ITL
        pomeraj = pomeraj + 1;
    end
    kraj(i) = pomeraj; 
end

% uklanjanje duplikata
pocetak = unique(pocetak);
kraj = unique(kraj);

rec = zeros(1,length(STE));

for i = 1:length(pocetak)
    rec(pocetak(i):kraj(i)) = max(STE);
end

% Detekcija nakon poredjenja sa nizim pragom
figure(6)
plot(t,STE,t,rec)
xlabel('t[s]','Interpreter','latex')
title('Segmentacija - kratkovremenska energija','Interpreter','latex')

%% Preslusavanje reci segmentiranih pomocu kratkovremenske energije

% for i = 1:length(pocetak)
%     sound(xf(pocetak(i):kraj(i)),fs);
%     pause()   
% end 

%% ZCR histogram

% figure(7)
% histogram(ZCR,40)
% title('Histogram ZCR','Interpreter','latex')
% xlim([0 0.5])

%% Segmentacija govornog signala - ZCR
IZCT = 0.2;

% Azuriranje pocetka reci
for i = 1:length(pocetak)
    if sum((ZCR(pocetak(i)-25:pocetak(i)-1)>IZCT)>3)
        pocetak(i) = pocetak(i) - find(ZCR(pocetak(i)-25:pocetak(i)-1)>IZCT,'first')*wl;
    end
end

% Azuriranje kraja reci
for i = 1:length(kraj)
    if sum((ZCR(kraj(i)+1:kraj(i)+25)>IZCT)>3)
        kraj(i) = kraj(i) + find(ZCR(kraj(i)+1:kraj(i)+25)>IZCT,'last')*wl;
    end
end

rec=zeros(length(xf),1);
for i=1:length(pocetak)
    rec(pocetak(i):kraj(i),1)=max(STE)*ones(kraj(i)-pocetak(i)+1,1);
end

% Detekcija reci pomocu ZCR
figure(8)
plot(t,STE,t,rec);
xlabel('t[s]','Interpreter','latex')
title('Segmentacija - ZCR','Interpreter','latex')
 
%% Preslusavanje segmentiranih reci pomocu ZCR

% for i = 1:length(pocetak)
%     sound(xf(pocetak(i):kraj(i)),fs);
%     pause()   
% end 