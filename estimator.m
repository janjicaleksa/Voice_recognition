function Tp = estimator(x, lambda, tau, win, fs)

idx = find(x, 1);
A = x(idx);
pocetak = idx + tau;
kraj = 0;

for i = pocetak:win
    
    if (x(i) >= A*exp(-lambda*(i - pocetak))) % prvi stubic koji preseca eksp fju
        kraj = i;
        break;
    end
end

if(kraj == 0)
    Tp = win/fs;
else
    Tp = (kraj - idx)/fs;
end

end