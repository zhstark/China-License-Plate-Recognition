function [ B, split_index] = SplitArray( A )
label = bwlabel(A);
n = max(label);
B = cell(n,1);
split_index = [];
for k=1:n
B{k} = A(label==k);
index = find(label == k);
pos1 = index(1);
pos2 = index(end);
split_index = [split_index pos1 pos2];
end
end

