function tbl3 = crossjoin(tbl1, tbl2)
% Do a cross join by innerjoining on the same key.
% Make a very unlikely column name as the merging key.
tbl1.xxxxxxxxxxxxxxxxxxxx(:) = 1;
tbl2.xxxxxxxxxxxxxxxxxxxx(:) = 1;
tbl3 = innerjoin(tbl1,tbl2,'Keys','xxxxxxxxxxxxxxxxxxxx');
tbl3.xxxxxxxxxxxxxxxxxxxx = [];
end

