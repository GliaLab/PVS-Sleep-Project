function analyse(tss)
    for ts = tss
        tic;
        disp(ts.name);
        xylobium.vesseltool2.measurement.analyse_tseries(ts);
        toc;
    end
end

