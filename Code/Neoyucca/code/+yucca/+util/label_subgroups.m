function labels = label_subgroups(group1,group2)
[G,G1,G2] = findgroups(group1,group2);

% Create incrementing numbers for each group in lvl1
labels = zeros(length(G1),1);
[C,~,IC] = unique(G1);
for i = 1:length(C)
    ind = IC == i;
    labels(ind) = 1:sum(ind);
end

labels = labels(G);

end