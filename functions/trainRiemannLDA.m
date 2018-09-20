function [mdl,CovMean] = trainRiemannLDA(winSeg)
% size(winSeg) = [60    11    20]
[nSegment,nFE,nSess ] = size(winSeg);
% Compute Covariances
xTrainCov = getCovFromWinSeg(winSeg);

% Tangent space mapping
method_mean = 'riemann';
CovMean = mean_covariances(xTrainCov,method_mean);

STrain = Tangent_space(xTrainCov,CovMean)';
yTrain = get_labels(nSegment,nFE,nSess);

% LDA training of Expert User
mdl = fitLDA('X',STrain,'Y',yTrain);
end