function acqRealTimeDB(varargin)
% �Լ� ���ο����� ���ϴ� ������ persistent
persistent winLengthBDF 

% �ٸ� �Լ��� ���ϴ� ������ global 
global rawBackup % raw data ����� ���
global rawPos % raw data ����� ���
global winBackup% train data 
global winCount % ǥ�� ���� �ð� GUI�� �Ѹ� �� ���
global trgGetSignal % �ܺ� ǥ������ ���� ��ſ� ���


try
% define defaults
% myStop;
opt = struct(...
    'analysisParameters',[],...
    'rawDB',[],...
    'winSize',0.128,...
    'BackUpMinutes', 30);

% set argument
opt = chaSetArgument(opt,varargin);

% dispatch argument
temp = structvars(opt); for i=1:size(temp,1), eval(temp(i,:));end

%==================�ʱ�ȭ=============================%
if isempty(trgGetSignal)
    % �ܺ�(Ȥ�� BDF�� trigger ���)�� ���� ����ȭ ��ȣ
    % �� ��ȣ�� ���� ���� ǥ���� ���� ������ �����̹Ƿ�, 
    % ��ȣ ���� ���� ���ķ� 3�ʸ�ŭ�� �����츦 ��ƾ���
    trgGetSignal = false;
end
if isempty(winCount) % 3�� ġ�� Window �����͸� ��� ���� count ���� �ʱ�ȭ
    winCount = 1; 
end
if isempty(rawBackup) % rawdata ��� ������ �ʱ�ȭ
    rawBackup = zeros(analysisParameters.sampRate*60*BackUpMinutes, 10+1); % 30��
end
if isempty(rawPos) % rawdata ���� ��ġ �ʱ�ȭ
    rawPos = 1;
end
if isempty(winBackup)% window backup Data �ʱ�ȭ
    winBackup = zeros(winLengthBDF,8,analysisParameters.nSeg); % 3��
end

%=========================================================%

if ~isempty(rawDB)
    if isempty(winLengthBDF) % winlength �ʱ�ȭ
        winLengthBDF = floor(analysisParameters.sampRate*winSize);
    end
    % �ӽ��ڵ� (�¶��� ������ ���� ���̱� �����Ƽ� bdf���Ϸ� �ǽð� �м�
    d = double(rawDB.data(:,rawPos:rawPos+winLengthBDF-1)');
end
% ���� data ���� �ľ�
dataLength = size(d,1);

% raw data ���
rawBackup(rawPos:rawPos+winLengthBDF-1,1:10) = d;
rawBackup(rawPos:rawPos+winLengthBDF-1,end) = trgGetSignal;
% disp(rawPos);

if trgGetSignal %����ȭ ���� ���
% Do analysis Code here
d(:,analysisParameters.idx_rej) = []; % set EMG pair

% filtering
out = filterOnline(d,analysisParameters);

% collected windowed data
winBackup(:,:,winCount) = out;

% 3�ʰ� ������ �� ���� ���
if winCount == analysisParameters.nSeg
    trgGetSignal=false;
    winCount = 1;
    myStop; % timer ���߱�!
    a=1;
end    
winCount = winCount +1;
end

%---- test
% covariance
% CovTest = covariances(out','shcovft');
% STest= Tangent_space(CovTest,CAdap)';
% yPd = predLDA(mdlNew,STest);


rawPos = rawPos + dataLength;
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
%     % Offline data replay�� ���Ǵ� ������ �ʱ�ȭ
%     if isempty(trgCheckCount) % trgCheckCount ����ȭ
%         trgCheckCount = 1;
%     end
% 
%     % Trigger Check
%     if analysisParameters.triggerBDF(trgCheckCount)<rawPos&& trgCheckCount<=11
%         trgCheckCount = trgCheckCount + 1;
%         disp(trgCheckCount);
%         
%         % ���� ����
%         if trgCheckCount==12
%             myStop;
%             return;
%         end
%         trgGetSignal = true;
%     end
%     % data
%     d = double(rawDB.data(:,rawPos:rawPos+winLength-1)');
% end