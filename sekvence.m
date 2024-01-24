function [m1, m2, m3, m4, m5, m6] = sekvence(x)

N = length(x);
m1 = zeros(1, N);
m2 = zeros(1, N);
m3 = zeros(1, N);
m4 = zeros(1, N);
m5 = zeros(1, N);
m6 = zeros(1, N);

maxs = zeros(1, N); % nule na mestima gde nema lok max
mins = zeros(1, N); % isto kao gornje samo za min

[peaks, max_inds] = findpeaks(x);
maxs(max_inds) = peaks;
max_inds = max_inds';

[peaks, min_inds] = findpeaks(-x);
mins(min_inds) = -peaks;
min_inds = min_inds';

m1 = maxs;
m1(m1 < 0) = 0;
m4 = -mins;
m4(m4 < 0) = 0;

maxp = 0; %vrednost pret max
for i = max_inds
    
    if(isempty(find(min_inds < i, 1, 'last')))
        minp = 0;
    else
        idx = find(min_inds < i, 1, 'last');
        minp = mins(min_inds(idx));
    end
    
    m2(i) = max(0, maxs(i) - minp);
    m3(i) = max(0, maxs(i) - maxp);
    maxp = maxs(i);
    
end

minp = 0; %vrednost pret max
for i = min_inds
    
    if(isempty(find(max_inds < i, 1, 'last')))
        maxp = 0;
    else
        idx = find(max_inds < i, 1, 'last');
        maxp = maxs(min_inds(idx));
    end
    
    m5(i) = max(0, -(mins(i) - maxp));
    m6(i) = max(0, -(mins(i) - minp));
    minp = mins(i);
    
end