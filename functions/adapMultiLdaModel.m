function mdlNewList = adapMultiLdaModel(mdlExpertUser,mdlCali,alphaList,betaList)
nEachParams = length(mdlCali);
nMdl =  length(mdlCali)+1;

% prepare LDA model
mdlList = cell(nMdl,1);
mdlList{1} = mdlExpertUser;
mdlList(2:3) = mdlCali;

nFeat = mdlExpertUser.nFeat;
nClass = mdlExpertUser.nClass;
Label = mdlExpertUser.Label;


% prepare Hyper parameters
[A,B]= meshgrid(alphaList,alphaList);
alpahGrid = [A(:),B(:)];
nAlphaGrid = size(alpahGrid,1);

[A,B]= meshgrid(betaList,betaList);
betaGrid = [A(:),B(:)];
nBetaGrid = size(betaGrid,1);

% memory allocation
mdlNewList = cell(nAlphaGrid,nBetaGrid);

for iAlpha = 1:nAlphaGrid
% hyper parameters
alpha = alpahGrid(iAlpha,:);
      
% Mean adaption
newMean = zeros(nClass,nFeat);
for i = 1:nMdl
    if i==nMdl
        newMean = newMean + (1-sum(alpha))*mdlList{i}.GroupMean;
    else
        newMean = newMean + alpha(i)*mdlList{i}.GroupMean;
    end
end


% covaiance adaption
for iBeta = 1:nBetaGrid
% hyper parameters
beta = betaGrid(iBeta,:);
newCov = zeros(nFeat,nFeat);
for i = 1:nMdl
    if i==nMdl
        newCov = newCov + (1-sum(beta))*mdlList{i}.PooledCov;
    else
        newCov = newCov + beta(i)*mdlList{i}.PooledCov;
    end
end

% mdlUpdate
mdlNew.Priors = repmat(1/nClass,nClass,1);
mdlNew.GroupMean = newMean;
mdlNew.PooledCov = newCov;
mdlNew.nClass = nClass;
mdlNew.nFeat = nFeat;
mdlNew.Label = Label;

mdlNew = fitLDA('MDL',mdlNew);


mdlNewList{iAlpha,iBeta} = mdlNew;

end
end

end