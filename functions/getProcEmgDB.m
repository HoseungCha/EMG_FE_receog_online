%--------------------------------------------------------------------------
% do preprocessing and feature extraction from raw data
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
function [pathSaveDB,analysisParameters,rawDB,winSeg,winSeq,featSeg,featSeq] = getProcEmgDB(varargin)
try
% define defaults
analysisParameters = struct(...
    'pathDB',cd,...,...
    'fileExtension','bdf',...
    'SubDirectoryBDF',[],...
    'saveFolderName', ['_proc_',datestr(now,'yyddmm_HHMM')],...
    'winIncSize',0.05,...
    'sampRate',2048,...
    'winSize',0.128,...
    'emgPair',1,...
    'emgChannelPair',cat(3,[1,2;1,3;2,3],[10,9;10,8;9,8]),...
    'lenFacailExpression',3,...
    'filterParams',struct('butterworthOrder',4,...
    'freqNotch',[58 62],'freqBPF',[20 450]),...
    'pathToolbox',[],...
    'labelNames',{{'angry','clench','lipCornerUp(L)','lipCornerUp(R)',...
    'lipCornerUp(B)','fear','happy','kiss','neutral','sad','surprised'}},...
    'nSes',20,...
    'pathOut',cd,...
    'ListSubject',1:42,...
    'ListSession',1:20,...
    'TriggerFunction',str2func('get_trg_myoexp2'),...
    'idSaveDB',true,...
    'idBipolarConfigure',true,...
    'idWinExtraction',true,...
    'idFeatExtraction',true,...
    'idPlot', false,...
    'idReturnPath',false,...
    'featSeg',[],'featSeq',[],...
    'windSeg',[],'winSeq',[],...
    'featList', []...
    );

% set argument
analysisParameters = chaSetArgument(analysisParameters,varargin);

% dispatch argument
temp = structvars(analysisParameters); for i=1:size(temp,1), eval(temp(i,:));end
 
% add toolbox ro read BDF
if ~isempty(pathToolbox)
addpath(genpath(fullfile(pathToolbox)));
end

% set experiment paramters
nFE = length(labelNames);% Number of facial expression
analysisParameters.nFE = nFE;
% read file path of subjects
[~,name,ext] = fileparts(pathDB);
if strcmp(ext,'.bdf') || strcmp(ext,'.mat') % 파일 자체를 선택할 경우
    pathSubject = {pathDB};
    nameSubject = {name};
else
    [nameSubject,pathSubject] = read_names_of_file_in_folder(pathDB);
end
nSub= length(ListSubject);
nSes = length(ListSession);
nSeg = floor((lenFacailExpression)/winIncSize);
analysisParameters.nSeg = nSeg;
nWinInc = floor(winIncSize*sampRate);
nWinSize = floor(winSize*sampRate); 

% filter parameters
[bNotch,aNotch] = butter(filterParams.butterworthOrder,...
    filterParams.freqNotch/(sampRate/2),'stop');
[bBPF,aBPF] = butter(filterParams.butterworthOrder,...
    filterParams.freqBPF/(sampRate/2),'bandpass');
analysisParameters.bNotch = bNotch;
analysisParameters.aNotch = aNotch;
analysisParameters.bBPF = bBPF;
analysisParameters.aBPF = aBPF;

if idSaveDB
% set saving folder
[~,folderDBname] = fileparts(pathDB);
nameProcessDB = [folderDBname,'_',saveFolderName];
pathSaveDB = make_path_n_retrun_the_path(pathOut,nameProcessDB);
else
    pathSaveDB = [];
end

% memory alloation
idxFEseq = cell(nSes,nSub);
for iSub= ListSubject
    
% memory alloation
winSeq = cell(nSes,1);
winSeg = cell(nSeg,nFE,nSes);
featSeg = NaN(nSeg,300,nFE,nSes);
featSeq = cell(nSes);


if idReturnPath % just return path (you can use it when finished obataining DB)
    return;
end

% read subjects folder
if strcmp(ext,'.bdf')||strcmp(ext,'.mat') % 파일 자체를 선택할 경우
    path_file{1} = pathDB;
else
    if isempty(SubDirectoryBDF)
    % 피험자 내 폴더에 bdf파일이 바로 있을 경우
    [~,path_file] = read_names_of_file_in_folder(fullfile(pathSubject{iSub},SubDirectoryBDF),['*',fileExtension]);
    else
    % 피험자 내 폴더에 bdf파일이 없고, 하위 폴더에 있을 경우
    [~,path_file] = read_names_of_file_in_folder(fullfile(pathSubject{iSub}),['*',fileExtension]);
    end
end

for iSes = ListSession
fprintf('emgPair-%d sub-%d session-%d\n',emgPair,iSub,iSes);

% read bdf file
if strcmp(fileExtension,'bdf')
out = pop_biosig(path_file{iSes});
rawDB = out; % rawDB 저장

% load trigger
tmp_trg = cell2mat(permute(struct2cell(out.event),[1 3 2]))';
end

% check which DB type you are working on
% total number of trigger 33: Myoexpression1 실험
% total number of trigger 23: Myoexpression2 실험
% total number of trigger 그때 그때 다름: Myoexpression3 실험
[lat_trg,idxSeqFE] = TriggerFunction(tmp_trg);
analysisParameters.triggerBDF = [lat_trg,idxSeqFE];
if exist('latSyncOtherEquip','var')
    % convert data into double type
    DB = double(out.data(:,latSyncOtherEquip:end))';
else
    % convert data into double type
    DB = double(out.data(:,1:end))';
end
idx_right = 1:3;
idx_left = 8:10;
idx_rej = [idx_right(~ismember(idx_right,[emgChannelPair(emgPair,1,1),emgChannelPair(emgPair,2,1)])),...
idx_left(~ismember(idx_left,[emgChannelPair(emgPair,1,2),emgChannelPair(emgPair,2,2)]))];
DB(:,idx_rej) = [];
analysisParameters.idx_rej = idx_rej;
analysisParameters.chUsed = 8;

% get raw data and bipolar configuration        
if idBipolarConfigure
    clear temp;
    temp.RZ= DB(:,1) - DB(:,2);%Right_Zygomaticus
    temp.RF= DB(:,3) - DB(:,4); %Right_Frontalis
    temp.LF= DB(:,5) - DB(:,6); %Left_Corrugator
    temp.LZ= DB(:,7) - DB(:,8); %Left_Zygomaticus
    temp = struct2cell(temp);
    DB = double(cat(2,temp{:}));
    clear temp;
end

% notch and band-pass filtering
temp = filter(bNotch,aNotch, DB,[],1);
filteredDB = filter(bBPF,aBPF, temp, [],1);
clear temp;

% get windowed DB
[windowDB,idxWindow] = getWindows(filteredDB,nWinSize,nWinInc);%%%%%

% get Trigger with respect of windows
idxTrgWin = getIdxTrgWin (lat_trg,idxWindow,nFE);
idxFEseq{iSes,iSub} = [idxSeqFE,idxTrgWin];%%%%%%%%%%%%%%%%%%%%%

% if ~isempty(rawDB)
%     return;
% end

if idWinExtraction == true
    % save window sequences
    winSeq{iSes} = windowDB;

    % save window segment
    for i = 1 : nFE
        winSeg(:,idxSeqFE(i),iSes) = windowDB(idxTrgWin(i):idxTrgWin(i)+nSeg-1);
    end
end

if idFeatExtraction == true
    % get features
    tic
    if isempty(featList) == [] % do default features
        windowFeat = getFeatures(windowDB);
    else
        windowFeat = getFeatures(windowDB,'featList',featList);
    end
    toc;
    nFeat = size(windowFeat,2); analysisParameters.nFeat = nFeat;
    % save feature sequences
    featSeq{iSes}  = windowFeat; 

    % Save feature segments 
    for i = 1 : nFE
        featSeg(:,1:nFeat,idxSeqFE(i),iSes) = ...
            windowFeat(idxTrgWin(i):idxTrgWin(i)+nSeg-1,:);
    end

    % To confirm extracted features
    if idPlot
        hf =figure(iSub);
        hf.Position = [1921 41 1920 962];
        subplot(nSes,1,iSes);
        tmp_plot = windowFeat(1:end,1:4);
        plot(tmp_plot)
        v_min = min(min(tmp_plot(100:end,:)));
        v_max = max(max(tmp_plot(100:end,:)));
        hold on;
        stem(idxTrgWin,repmat(v_min,[nFE,1]),'k');
        stem(idxTrgWin,repmat(v_max,[nFE,1]),'k');
        ylim([v_min v_max]);
        drawnow;
    end
end
end

% 그림 출력
if idPlot
    hf = tightfig(hf);
    if idSaveDB
    savefig(hf,fullfile(pathSaveDB,nameSubject{iSub}),'compact')
    end
end

if idFeatExtraction == true
%  불필요하게 memory allocation 했던 부분 지우기
featSeg(:,nFeat+1:end,:,:) = [];
end

% 데이터 저장(피험자 별로 저장)
if idSaveDB
    % save
    if idWinExtraction
        save(fullfile(pathSaveDB,sprintf('winSeg-sub-%02d',iSub)),'winSeg');
        save(fullfile(pathSaveDB,sprintf('winSeq-sub-%02d',iSub)),'winSeq');
    end
    if idFeatExtraction
        save(fullfile(pathSaveDB,sprintf('featSeg-sub-%02d',iSub)),'featSeg');
        save(fullfile(pathSaveDB,sprintf('featSeq-sub-%02d',iSub)),'featSeq');
    end
end

end %--- 모든 피험자 분석 끝

% 파라미터 저장
if idSaveDB
analysisParameters.idxFEseq = idxFEseq;
save(fullfile(pathSaveDB,'ParameterOption'),'opt');
end

catch ex
    ex.stack.line    
    keyboard;
end
end
%==========================FUNCTIONS======================================%
% cutting trigger
function idxTrgWin = getIdxTrgWin (lat_trg,idxWindow,nFE)
idxTrgWin = zeros(nFE,1);
for i_emo_orer_in_this_exp = 1 : nFE
    idxTrgWin(i_emo_orer_in_this_exp,1) = find(idxWindow >= lat_trg(i_emo_orer_in_this_exp),1);
end
end


function [lat_trg,idxSeqFE] = get_trg_myoexp1(trg)
%Trigger latency 및 FE 라벨
if ~isempty(find(trg(:,1)==16385, 1)) || ...
        ~isempty(find(trg(:,1)==16384, 1))
    trg(trg(:,1)==16384,:) = [];
    trg(trg(:,1)==16385,:) = [];
end

idxSeqFE = trg(2:3:33,1);
lat_trg = trg(2:3:33,2);

% idx2use_fe = zeros(11,1);
% for i_fe = 1 : 11
%     tmp_fe = find(trg_cell(:,1)==i_fe);
%     idx2use_fe(i_fe) = tmp_fe(2);
% end
% [~,idxSeqFE] = sort(idx2use_fe);
% lat_trg = trg_cell(idx2use_fe,2);
% lat_trg = lat_trg(idxSeqFE);
end

function [lat_trg,idxSeqFE] = get_trg_myoexp2(trg)
% get trigger latency when marker DB acquasition has started
lat_trg_onset = trg(1,2);

% check which triger is correspoing to each FE and get latency
tmp_emg_trg = trg(2:end,:);
Idx_trg_obtained = reshape(tmp_emg_trg(:,1),[2,size(tmp_emg_trg,1)/2])';
tmp_emg_trg = reshape(tmp_emg_trg(:,2),[2,size(tmp_emg_trg,1)/2])';
lat_trg = tmp_emg_trg(:,1);

% get sequnece of facial expression in this trial
[~,idx_in_order] = sortrows(Idx_trg_obtained);    
tmp_emg_trg = sortrows([idx_in_order,(1:length(idx_in_order))'],1); 
idxSeqFE = tmp_emg_trg(:,2); 
end


% 
% switch length(tmp_trg)
%     case 33
%         [lat_trg,idxSeqFE] = get_trg_myoexp1(tmp_trg);
%     case 23
%         [lat_trg,idxSeqFE] = get_trg_myoexp2(tmp_trg);
%     case 24 % which happens of subject 10 and trial 10
%     otherwise
%         keyboard;
%         error('unexpected triggers from E-prime');
%         continue;
% end