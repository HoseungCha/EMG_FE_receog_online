function Cov = getCovFromWinSeg(winSeg)
temp = winSeg(:);
temp = cellfun(@transpose,temp,'UniformOutput',false);
Cov = covariances(cat(3,temp{:}),'shcovft');
end