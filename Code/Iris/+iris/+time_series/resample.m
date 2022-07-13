function ts = resample(ts,fs)
for i = 1:height(ts)
    [y,x] = resample(double(ts.y{i}), ts.x{i}, fs);
    ts.y{i} = y;
    ts.x{i} = x;
    ts.fs(i) = fs;
end
end

