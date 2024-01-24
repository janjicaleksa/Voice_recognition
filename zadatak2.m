close all;
clear all;
clc;

%% mi-kompanding kvantizator

[x, Fs] = audioread('Recording_19.wav');

b = [4 8 12]; % broj bita
mi = [100 500]; 
Xmax = max(abs(x));
M = 2.^b; % broj kvantizacionih nivoa
d = 2*Xmax./M; % korak kvantizacije

t = 1/Fs:1/Fs:length(x)/Fs;

for i = 1:length(mi)
    for j = 1:length(b)
        x_comp = Xmax*log10(1 + mi(i)*abs(x)/Xmax)/(log10(1+mi(i))).*sign(x);
        xq_mi = round(x_comp/d(j))*d(j); % uniformna kvantizacija kompresovanog signala
        xq_mi(x_comp > (M(j) - 1)/2*d(j)) = (M(j)/2 - 1)*d(j);
    
        x_decomp = 1/mi(i)*sign(xq_mi).*((1+mi(i)).^(abs(xq_mi)/Xmax)-1)*Xmax;

        figure()
        plot(x, xq_mi, '*');
        xlabel('$x$','Interpreter','Latex');
        ylabel('$\hat{x}$','Interpreter','Latex')
        title('Kvantizaciona karakteristika','Interpreter','latex')

        figure()
        hold all
        plot(t,x, 'b');
        plot(t,x_decomp, 'r')
        xlabel('t[s]','Interpreter','latex')
        title('Vremenski oblik signala','Interpreter','latex')
        legend('originalni','kvantizovani','Interpreter','latex')

    end
end

%% mi-kompanding kvantizator - SNR karakteristike

B = [4,8,12];

for j =1:3
    b = B(j);
    for mi = [100, 500]
        aten = 0.1:0.01:1; %utisavanje
        M = 2^b; %broj nivoa
        d = 2*Xmax/M; %korak
        SNR1 = [];
        xvar1 = [];
        for i=1:length(aten)
            x1 = aten(i)*x;
            xvar1 = [xvar1 var(x1)];
            x_comp = Xmax*log10(1+mi*abs(x1)/Xmax)/(log10(1+mi)).*(sign(x1));
            xq_mi = round(x_comp/d)*d; %kvantizovan signal
            x_mi_decomp = 1/mi*sign(xq_mi).*((1+mi).^(abs(xq_mi)/Xmax)-1)*Xmax;
            SNR1 = [SNR1 10*log10(var(x1)/var(x1-x_mi_decomp))];
        end
        
        figure(100*j);
        if mi == 100
            semilogx(Xmax./(sqrt(xvar1)),SNR1,'b');
        else
            semilogx(Xmax./(sqrt(xvar1)),SNR1,'g');
        end
        hold on;
        if mi == 100
            semilogx(Xmax./(sqrt(xvar1)),4.77+6*b-20*log10(log(1+mi))-10*log10(1+(Xmax./mi)^2./xvar1+sqrt(2)*Xmax./mi./sqrt(xvar1)),'r--')
        else
            semilogx(Xmax./(sqrt(xvar1)),4.77+6*b-20*log10(log(1+mi))-10*log10(1+(Xmax./mi)^2./xvar1+sqrt(2)*Xmax./mi./sqrt(xvar1)),'k--')
        end
        xlabel('f[Hz]','Interpreter','latex');
        ylabel('$X_{max}/\sigma_{x}$','Interpreter','latex');
        legend('$\mu = 100$ eksperimentalno', '$\mu = 100$ teorijski', '$\mu = 500$ eksperimentalno', '$\mu = 500$ teorijski','Interpreter','latex','Location','Best')
    end
end

%% Delta-kvantizator

clear;
[x, Fs] = audioread('Recording_19.wav');
Xmax = max(abs(x));
N = length(x);
figure()
plot(1:N, x);

Wn = [60 2500]/(Fs/2);
[B,A] = butter(6,Wn,'bandpass');
xf = filter(B, A, x);
X = fft(xf, N);
Xf = abs(X(1:N/2+1));
G = [10, 50, 150, 500];
a = G/5000*(max(x) - min(x));

for j = 1:length(a)
    x_hat = zeros(1, N+1);
    d = zeros(1, N);
    minus = 0;
    plus = 0;
    for i =1:N
        d(i) = xf(i) - x_hat(i);
        x_hat(i+1) = x_hat(i) + sign(d(i))*a(j);
        if sign(d(i)) < 0
            minus = minus + 1;
        else
            plus = plus + 1;
        end
    end
    
    figure()
    plot(1:N, x);
    hold all;
    Wn = [60 2500]/(Fs/2);
    [B,A] = butter(6, Wn, 'bandpass');
    x_hat = filter(B, A, x_hat);
    plot(1:N, x_hat(2:end))
    str = "korak kvantizacije: " + a(j);
    title(str,'Interpreter','latex');
    hold off;
    figure, histogram('Categories',{'negativno','pozitivno',},'BinCounts',[minus plus])
    %sound(x_hat);
    %display(A(j))
    %pause();
end