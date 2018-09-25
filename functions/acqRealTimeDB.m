function acqRealTimeDB(varargin)
% 함수 내부에서만 변하는 변수는 persistent
persistent winLengthBDF 

% 다른 함수간 변하는 변수는 global 
global rawBackup % raw data 백업에 사용
global rawPos % raw data 백업에 사용
global winBackup% train data 
global winCount % 표정 짓는 시간 GUI에 뿌릴 때 사용
global trgGetSignal % 외부 표정짓는 시점 통신에 사용

%test
global CovMeanCali;
global mdl
global EditHandle;

try
% define defaults
% myStop;
opt = struct(...
    'analysisParameters',[],...
    'rawDB',[],...
    'winSize',0.128,...
    'BackUpMinutes', 30,...
    'idDoPredict',false);

% set argument
opt = chaSetArgument(opt,varargin);

% dispatch argument
temp = structvars(opt); for i=1:size(temp,1), eval(temp(i,:));end

%==================초기화=============================%
if isempty(trgGetSignal)
    % 외부(혹은 BDF의 trigger 기록)에 따라 동기화 신호
    % 이 신호가 들어올 경우는 표정을 짓기 시작한 시점이므로, 
    % 신호 들어온 시점 이후로 3초만큼의 윈도우를 모아야함
    trgGetSignal = false;
end
if isempty(winCount) % 3초 치의 Window 데이터를 얻기 위한 count 변수 초기화
    winCount = 1; 
end
if isempty(rawBackup) % rawdata 백업 데이터 초기화
    rawBackup = zeros(analysisParameters.sampRate*60*BackUpMinutes, 10+1); % 30분
end
if isempty(rawPos) % rawdata 저장 위치 초기화
    rawPos = 1;
end
if isempty(winBackup)% window backup Data 초기화
    winBackup = zeros(winLengthBDF,8,analysisParameters.nSeg); % 3초
end

%=========================================================%

if ~isempty(rawDB)
    if isempty(winLengthBDF) % winlength 초기화
        winLengthBDF = floor(analysisParameters.sampRate*winSize);
    end
    % 임시코드 (온라인 데이터 전극 붙이기 귀찮아서 bdf파일로 실시간 분석
    if length(rawDB.data)<rawPos+winLengthBDF
        disp('you just read full offline files');
        myStop;
    end
    d = double(rawDB.data(:,rawPos:rawPos+winLengthBDF-1)');
end
% 들어온 data 갯수 파악
dataLength = size(d,1);

% raw data 백업
rawBackup(rawPos:rawPos+dataLength-1,1:10) = d;
rawBackup(rawPos:rawPos+dataLength-1,end) = trgGetSignal;

% 채널 8개만 사용
d(:,analysisParameters.idx_rej) = []; % set EMG pair



if trgGetSignal %동기화 들어올 경우
% Do analysis Code here


% filtering
out = filterOnline(d,analysisParameters);

% collected windowed data
winBackup(:,:,winCount) = out;

% 3초간 데이터 다 모을 경우
if winCount == analysisParameters.nSeg
    trgGetSignal=false;
    winCount = 1;
    myStop; % timer 멈추기!
    a=1;
end    
winCount = winCount +1;
end
rawPos = rawPos + dataLength;


if idDoPredict
%---- test
% covariance
% STest = riemanFeatureExtraction(CovCali,winSegTest);
% myStop;
CovTest = covariances(d','shcovft');
STest= Tangent_space(CovTest,CovMeanCali{1})';
yPd = predLDA(mdl{1},STest);
% myStop;
EditHandle.String=analysisParameters.labelNames{yPd};
end

% disp(rawPos);
% winCount = winCount + 1;
% myStop;
% disp(rawPos);
catch ex
   ex.stack.line
   myStop;
   keyboard;
end

end

% persistent trgCheckCount
% if idRawDBPlay 
%     % Offline data replay에 사용되는 변수들 초기화
%     if isempty(trgCheckCount) % trgCheckCount 동기화
%         trgCheckCount = 1;
%     end
% 
%     % Trigger Check
%     if analysisParameters.triggerBDF(trgCheckCount)<rawPos&& trgCheckCount<=11
%         trgCheckCount = trgCheckCount + 1;
%         disp(trgCheckCount);
%         
%         % 종료 시점
%         if trgCheckCount==12
%             myStop;
%             return;
%         end
%         trgGetSignal = true;
%     end
%     % data
%     d = double(rawDB.data(:,rawPos:rawPos+winLength-1)');
% end