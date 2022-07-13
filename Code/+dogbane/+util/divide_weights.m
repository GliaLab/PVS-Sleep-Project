function I = divide_weights(w,N)
% Allocates the groups 

if N > length(w)
    I = [];
    return;
end

if N == 1
    I = ones(1,length(w));
    return;
end

C = combnk(1:length(w)-1,N-1);

I = zeros(size(C,1),length(w));
for i = 1:size(C,1)
    ii = 1;
    for j = 1:size(C,2)
        jj = C(i,j);
        I(i,ii:jj) = j;
        ii = jj + 1;
    end
end
I(I==0) = N;

W = w(I);

sums = zeros(size(I,1),N);

for i = 1:size(sums,1)
    for j = 1:size(sums,2)
        sums(i,j) = sum(w(I(i,:) == j));
    end
end

sums = abs(sums - sum(w)/N);

sums = sum(sums,2);

[~,i_min] = min(sums);

I = I(i_min,:);


end

