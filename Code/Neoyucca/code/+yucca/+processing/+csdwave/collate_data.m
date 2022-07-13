
fldr = "";
tss = begonia.scantype.find_scans(fldr);

tab = table();
for i = 1:length(tss)
    tmp_tab = table();
    tmp_tab.Genotype = ts(i).load_var("Genotype");
    tmp_tab.Name = ts(i).load_var("Name");
    tmp_tab.Include = ts(i).load_var("Include");
    tmp_tab.UUID = ts(i).uuid;
    tmp_tab.Zoom = ts(i).zoom;
    
    tab = [tab;tmp_tab];

end


tab(tab.Include == false,:) = [];

