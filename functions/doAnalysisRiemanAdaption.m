%-------------------------------------------------------------------------%
% This Code is about adaption with user's data with classfier which is
% constructed by other database using Riemannian Adaption
%-------------------------------------------------------------------------%
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%-------------------------------------------------------------------------%
function [mdlNewList,mdlExpertUser,CovMeanExpertUser,...
    mdlCali,CovMeanCali,accuracy] = doAnalysisRiemanAdaption(varargin)
try
% option
opt = struct(...
    'iEMGpair',1,...,...
    'winSize',0.1,...
    'pathDB',cd,...
    'ParameterOption',[],...
    'winSegTest',[],...
    'idxSegment', 21:60,...
    'idxExpertUser',1,...
    'idxExpertSession',1:20,...
    'idxTestUserList',2:42,...
    'idxTestSession',2:20,...
    'alphaList', 0:0.1:1,...
    'betaList', 0:0.1:1,...
    'nFE',11,...
    'TestMode','both',...
    'accuracy',[]);

% set argument
opt = chaSetArgument(opt,varargin);

% dispatch argument
temp = structvars(opt); for i=1:size(temp,1), eval(temp(i,:));end

% 데이터를 직접 Train할 경우
if ~isempty(winSegTest) 
    idxTestUserList=1;
    idxCaliSession = 1:size(winSegTest,3);
    idxTestSession = 1; % 필요없으나 코드 확인떄문에 해봄
end

% read parameters of Database

% memory allocation
% mdlNew = cell(length(alphaList),length(betaList),length(idxTestUserList));
acc = zeros(length(alphaList),length(betaList),length(idxTestUserList));
% acc_cali = zeros(length(alphaList),length(betaList),length(idxTestUserList));
% acc_train = zeros(length(alphaList),length(betaList),length(idxTestUserList));
u = 0;
for idxTestUser= idxTestUserList
% train mode일 경우 분류기 return
if strcmp(TestMode,'train') || strcmp(TestMode,'both')
u = u + 1;
%========== Prepare training data ============%
% Read File
fileName = sprintf('winSeg-sub-%02d',idxExpertUser);
load(fullfile(pathDB,fileName));

% Train for Expert User
[mdlExpertUser,CovMeanExpertUser] = ...
    trainRiemannLDA(winSeg(idxSegment,:,idxExpertSession));

%==============================================%

%========== Prepare Calibratoin Session ============%
% Read Calibration/Test File
if isempty(winSegTest) %
    fileName = sprintf('winSeg-sub-%02d',idxTestUser);
    temp = load(fullfile(pathDB,fileName));
    winSegTest = temp.winSeg;
end

mdlCali = cell(length(idxCaliSession),1);
for iSes = idxCaliSession
    [mdlCali{iSes},CovMeanCali{iSes}] = ...
        trainRiemannLDA(winSegTest(idxSegment,:,iSes));
end
%==============================================%

%========= Adaption with models ============%
mdlNewList = adapMultiLdaModel(mdlExpertUser,mdlCali,alphaList,betaList);
%==============================================%


%========== Prepare Test Session ============%
if strcmp(TestMode,'test') || strcmp(TestMode,'both')
    
winSegTest = winSeg(idxSegment,:,idxTestSession);

STest = riemanFeatureExtraction(mean(cat(3,CovMeanCali{:}),3),winSegTest);

yTest = get_labels(length(idxSegment),nFE,...
    length(idxTestSession)*length(idxTestUser));

[nAlphaList,nBetaList] = size(mdlNewList);
for i = 1: nAlphaList
for j = 1 : nBetaList
    yPd = predLDA(mdlNewList{i,j,u},STest);
    acc(i,j,u) = length(find(yTest==yPd))/length(yTest);

%     yPdCali = predLDA(mdlNewList{i,j,u},SCali);
%     acc_cali(i,j,u)  = length(find(yCali==yPdCali))/length(yCali);
% 
%     yPdTrain= predLDA(mdlNewList{i,j,u},STrain);
%     acc_train(i,j,u)  = length(find(yTrain==yPdTrain))/length(yTrain);
end
end

accuracy = cat(4,acc,acc_cali,acc_train);
end% test mode 끝
end% both train/test mode 끝

fprintf('idxTestUser:%d\n',idxTestUser); 
end% 테스트할 피험자

catch ex
    keyboard;
end
end

