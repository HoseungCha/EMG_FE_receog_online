% this code was written by Hoseung Cha
% contact: hoseungcha@gmail.com
function mdlNew = adapLDA(mdlOld,mdlNew,alpha,beta);
% define defaults
% opt = struct('alpha',0.5,'beta',0.5);

% set argument
% opt = chaSetArgument(opt,varargin);
m = size(mdlOld.GroupMean,1);
% adapt
mdlNew.GroupMean =  (1-alpha)*mdlOld.GroupMean...
    +alpha*mdlNew.GroupMean;
mdlNew.PooledCov = (1-beta)*mdlOld.PooledCov + ...
    beta*mdlNew.PooledCov;

mdlNew.Priors = repmat(1/m,m,1);

mdlNew = fitLDA('MDL',mdlNew);
    

end