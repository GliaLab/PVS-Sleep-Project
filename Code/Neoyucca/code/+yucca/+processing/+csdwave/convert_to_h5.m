function convert_to_h5(fldr, outfldr)

%fldr = '/Users/runeenger/Desktop/CSD/';
%outfldr = "/Users/runeenger/Desktop/testh5/";

if ~isfolder(outfldr)
    mkdir(outfldr)
    
end

tss = begonia.scantype.find_scans(fldr);

for i = 1:length(tss)
    nm = strrep(tss(i).name, 'tif', 'h5');
    nm = [outfldr, nm];
    begonia.scantype.h5.tseries_to_h5(tss(i), nm)
    
    
end
