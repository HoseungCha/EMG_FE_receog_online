function STest = riemanFeatureExtraction(CAdap,winSegTest)
% Compute Covariances
xTestCov = getCovFromWinSeg(winSegTest);

% Tangent space mapping
STest= Tangent_space(xTestCov,CAdap)';
end