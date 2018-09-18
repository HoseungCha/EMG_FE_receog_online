function output = concat_leaving_dim(feat_t,dim)
% dim = 2;
idx_dim = 1 : ndims(feat_t);
change_dim = [idx_dim(~ismember(idx_dim,dim)) idx_dim(ismember(idx_dim,dim))];
output = reshape(permute(feat_t,change_dim),...
    [numel(feat_t)/size(feat_t,dim),size(feat_t,dim)]);
end