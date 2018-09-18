function [max_v,max_idx] = get_max_and_idx(tmp)
[~,idx] = max(tmp);

% check multiple max values occur
idx_max_v = find(tmp(idx)==tmp==1);
if length(idx_max_v)>1
    idx = randi(length(idx_max_v));
    idx = idx_max_v(idx);
end
max_v = tmp(idx);
max_idx = idx;
end