clc, clear, close all
%% Ucitavanje sekvence

[y, fs] = audioread('Recording_2.wav');
figure()
plot(0:1/fs:(length(y) - 1)/fs,y);
title('Vremenski oblik govornog signala','Interpreter','latex')
xlabel('t[s]','Interpreter','latex')

%% Grubo odsecanje tisine

x=[y(1.75*fs:2.35*fs);y(2.9*fs:3.35*fs);y(4.15*fs:4.65*fs)]; 

figure()
plot(0:1/fs:(length(x) - 1)/fs,x);
title('Govorna sekvenca sa otklanjanjem bezvucnih delova','Interpreter','latex')
xlabel('t[s]','Interpreter','latex')

%% Filtriranje 

Wn = [50 450]/(fs/2);
[B, A] = butter(6, Wn, 'bandpass');
x = filter(B, A, x);

%% Pravljenje sekvenci (m1,..., m6)

[m1, m2, m3, m4, m5, m6] = sekvence(x);

figure()
subplot(611)
stem(m1(1:1000));
subplot(612)
stem(m2(1:1000));
subplot(613)
stem(m3(1:1000));
subplot(614)
stem(m4(1:1000));
subplot(615)
stem(m5(1:1000));
subplot(616)
stem(m6(1:1000));

%% Procena pitch frekvencije - metoda paralelnog procesiranja

N = length(x);
[pt1, pt2, pt3, pt4, pt5, pt6, pt] = procena_periode(fs, N, m1, m2, m3, m4, m5, m6);
p_freq=1./pt;
figure, plot(p_freq)
pitch_frequency_paralelno_procesiranje = median(p_freq)
%nanmedian(1./pt)

%% Autokorelaciona metoda

autocorr=xcorr(x);
autocorr=autocorr/max(autocorr);
lags = -(length(autocorr)-1)/2:(length(autocorr)-1)/2;

figure()
plot(lags, autocorr);
xlabel('k','Interpreter','latex');
ylabel('$R_{xx}[k]$','Interpreter','latex');
title('Autokorelaciona funkcija','Interpreter','latex');

[~, locs] = findpeaks(autocorr);
    
% Razliciti treshold prvog bitnog peaka u zavisnosti od kvaliteta snimka/reci
threshold = 0.3; 

% Nalazimo sve pikove iznad thresholda i racunamo srednju udaljenost izmedju njih
significant_peaks = locs(autocorr(locs) > threshold);
sum=0;
for i=1:length(significant_peaks)-1
   sum=sum+significant_peaks(i+1)-significant_peaks(i);
end
dist=sum/(length(significant_peaks)-1);
    
pitch_frequency_autocorr = fs / dist