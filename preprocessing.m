function rec = preprocessing(x, fs)
    
    % filtriranje
    Wn = [60 3500]/(fs/2); 
    [B,A] = butter(6,Wn,'bandpass'); 

    xf = filter(B,A,x);
    
    % segmentacija (uklanjanje tisine)
    wl = 20e-3*fs; % duzina prozora u odbircima

    STE = zeros(size(xf)); % kratkovremenska energija
    ZCR = zeros(size(xf)); % zero crossing rate
    
    for i = wl:length(xf)
        rng = (i - wl + 1):i-1;
        STE(i) = sum(xf(rng).^2);
        ZCR(i) = sum(abs(sign(xf(rng + 1)) - sign(xf(rng))));
    end
    
    ZCR = ZCR/wl/2;

    ITU = 0.1*max(STE);
    ITL = 3*0.0001*max(STE);
    
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
    
    % Poredjenje sa nizim pragom
    for i = 1:length(pocetak)
        pomeraj = pocetak(i);
        while STE(pomeraj)>ITL
            pomeraj = pomeraj - 1;
            if(pomeraj == 0)
                break;
            end
        end
        pocetak(i) = pomeraj; 
    end
    
    for i = 1:length(kraj)
        pomeraj = kraj(i);
        while STE(pomeraj)>ITL
            pomeraj = pomeraj + 1;
            if(pomeraj == length(STE))
                break;
            end
        end
        kraj(i) = pomeraj; 
    end
    
    % uklanjanje duplikata
    pocetak = unique(pocetak);
    kraj = unique(kraj);
    
    IF = 0.32;
    zavg=mean(ZCR(150000:end));
    zstd=std(ZCR(150000:end));
    IZCT = max(IF,zavg+3*zstd);
    
    
    for i = 1:length(pocetak)
        if sum((ZCR(pocetak(i)-25:pocetak(i)-1)>IZCT)>3)
            pocetak(i) = pocetak(i) - find(ZCR(pocetak(i)-25:pocetak(i)-1)>IZCT,'first');
        end
    end
    
    for i = 1:length(kraj)
        s = kraj(i) + 1;
        e = kraj(i) + 25;
        if s > length(ZCR) 
            break
        end
        if e > length(ZCR)
            break
        end
        if sum((ZCR(kraj(i)+1:kraj(i)+25)>IZCT)>3)
            kraj(i) = kraj(i) + find(ZCR(kraj(i)+1:kraj(i)+25)>IZCT,'last');
        end
    end
    
    rec = xf(pocetak(1):kraj(1));
end