

scans = eustoma.get_linescans(true);
scans = scans(scans.has_var('linescan_info'));

for i = 1:length(scans)
    disp(i)
    
    s = scans(i).read_metadata();
    if i == 1
        t = s.start_time;
        um_per_deg = s.um_per_deg;
    else
        t(i) = s.start_time;
        um_per_deg(i) = s.um_per_deg;
    end
end
%%
[~,I] = sort(t);

T = t(I);
Y = um_per_deg(I);

figure;
plot(T,Y);