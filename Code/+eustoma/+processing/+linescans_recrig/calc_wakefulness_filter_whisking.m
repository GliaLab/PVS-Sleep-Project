function [whisking,t,fs] = calc_wakefulness_filter_whisking(whisking,t)
fs = 30;
whisking = medfilt1(whisking,10);
whisking = whisking - mode(whisking);
[whisking, t] = resample(whisking, t, 30);

end

