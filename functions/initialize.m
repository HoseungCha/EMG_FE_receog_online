%-------------------------------------------------------------------------%
% Variable button_initialization of EMG GUI Online
%-------------------------------------------------------------------------%
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%-------------------------------------------------------------------------%
function initialize(handles)
clc; 

%-------------------------Define globale variables------------------------%
clear GUI timer_obj exp_inform path DB_backup cq p;

% global info; % info,  함수간 공용으로 필요한 변수로 사용
% global pd; % pd, circlequq의 형태로 공용으로 필요한 변수로 사용
global GUI;
global timer_obj
global exp_inform;
global path;
global DB_backup;
global cq;
global p;
%-------------------------------------------------------------------------%

% check if we are doing train or test session before initialization
if handles.radiobutton_train.Value
%------------------------code analysis parameter--------------------------%

% choose version of list of facial expression

% 8 facial expression list
% exp_inform.name_FE = {'angry','contemptuous(right)','disgusted','fearfull',...
%     'happy','neutral','sad','surprised'};

% 11 facial expression list
exp_inform.name_FE = {'angry';'clench';'contemtuous(left)';...
    'contemptuous(right)';'close eyes strongly(frown)';'fear';...
    'happy';'kiss';'neutral';'sad';'surprised'};

exp_inform.name_FE = {'angry';'neutral';'kiss'};

% num of channel of rawdata (Note: ch1 of adbox was broken)
exp_inform.n_ch_rawdata = 10; 

% instuction period of facial expression
exp_inform.period_inst = 6; % the time period should be longer than exp_inform.period_fe (3-sec)
exp_inform.period_fe = 3;
exp_inform.period_delay_inst_fe = exp_inform.period_inst - exp_inform.period_fe;

% sampling peroriod for data acquasition
exp_inform.period_sampling_of_timer = 0.1;

% time period of memory allocation of raw-data back up
exp_inform.time_for_experiment = 10; % unit: minutes

% time period for final decision using majority-voting
exp_inform.period_mv = 1.5;

% name of folder in resource to be used in GUI
exp_inform.name_img = 'img_fe_11'; % 'img_fe_8'; 'img_fe_11';

% name of machine learning 
exp_inform.name_ml = 'lda';

%-------------------------------------------------------------------------%



%-------------------------experiemnt information--------------------------%

% number of expression
exp_inform.n_fe = length(exp_inform.name_FE);

% random order of facial expression, which can be used in training session
exp_inform.order_fe = randperm(exp_inform.n_fe); % for backup
exp_inform.order_fe4GUI = exp_inform.order_fe; % order_fe4GUI (사용)

% num channel of bipolar channel for EMG acquisition
exp_inform.n_bip_ch = 4; 

% sampling rate of BIOSEMI
exp_inform.sf = 2048; 

% time for make facial expression in training sessoin
exp_inform.period_fe = 3; 

exp_inform.idx_fe = 1 : exp_inform.n_fe;

% number of window for majority voting
exp_inform.n_win_mv = floor(exp_inform.period_mv/exp_inform.period_sampling_of_timer);
exp_inform.n_win = exp_inform.period_fe/exp_inform.period_sampling_of_timer; % num windows for train

% circlequeue variable button_initialzie setup
exp_inform.period_buff = 10;  % set length as long as 10 sec
exp_inform.length_buff = exp_inform.period_buff*exp_inform.sf; % set circlue buffer length
%-------------------------------------------------------------------------%
end

% check if we are doing train or test session before initialization
if handles.radiobutton_test.Value
    
    % if it is test session, get information of experiment 
    [FileName,PathName,~] = uigetfile({'*.mat'},...
    'mytitle',fullfile(path.code,'DB','DB_online'));
    if FileName==0
        error('you must choose model in training session');
    end
    
    % get path of the training set that we are using now
    path.model_n_DB_from_train = [PathName,FileName];
    
    % display of models on GUI
    set(handles.edit_model_input,'String',FileName);
        
    % get machine learning model
    load(fullfile(path.model_n_DB_from_train),'exp_inform');
    
    % get machine learning model
    load(fullfile(path.model_n_DB_from_train),...
        'model');
    exp_inform.model = model;
    
    %---------------Serial communication(computer by computer)------------%
    % you should set those parameter at the same with settings of com&port
    % in device manager
    
    exp_inform.PC_serial = serial('COM6'); % 장치관리자에서 serial port 확인해서 설정 (실험실 오른쪽 컴퓨터)
    set(exp_inform.PC_serial, 'BaudRate', 9600, 'DataBits', 8, 'StopBits', 1,...
        'Parity', 'none', 'FlowControl', 'none', 'TimeOut', 0.01)
    fopen(exp_inform.PC_serial);
    %---------------------------------------------------------------------%
end


%-----------------GUI instruction presentation (Train/Test mode)----------%
GUI_mode_presentation(handles) 
%-------------------------------------------------------------------------%

%-----------------------GUI control parameters----------------------------%
GUI.button_init = 1; % identifier if button_initialzie button was pushed
GUI.handles = handles; % saving GUI hanels
GUI.id_end_fe = 0; 
GUI.id_start_fe = 0;
%-------------------------------------------------------------------------%



%----------------------------resource set-up------------------------------%
[beep, Beep_Fs] = audioread(fullfile(path.code,'rsc','beep.wav')); 

% GUI image handles setup
% image handles of gui should be intially saved, to show the images as fast
% as possible in online data acquasition 

% get index of default image(non-expression)
GUI.idx_defalt_img = find(cellfun(@isempty,strfind(exp_inform.name_FE,'neutral'))==0);

% memory allocations
GUI.h_image = gobjects(exp_inform.n_fe,1); % graphics button_init

for i_fe=1:exp_inform.n_fe
    path.image = fullfile(path.code,'rsc',exp_inform.name_img,'train',...
        [exp_inform.name_FE{i_fe},'.jpg']);
    temp_img= imread(path.image);
    eval(sprintf('GUI.h_image(i_fe) = imshow(temp_img,''Parent'',handles.axes_img%d);',...
        i_fe));
end
for i_fe=1:exp_inform.n_fe
    GUI.h_image(i_fe).Visible='off';
end
GUI.h_image(GUI.idx_defalt_img).Visible = 'on'; % defualt image

%-------------------------------------------------------------------------%

%----------------------------timer set-up---------------------------------%

% button_initialization of timer
if ~isempty(timerfind)
    stop(timerfind);delete(timerfind);
end

% instruction-related timer set-up
% GUI Facial expression instruction timer
timer_obj.inst_make_fe = timer('StartDelay', exp_inform.period_delay_inst_fe,...
    'TimerFcn','GUI_FE_inst','Period', exp_inform.period_inst,...
    'ExecutionMode', 'fixedRate'); 

% GUI rest instructaion timer
timer_obj.inst_rest = timer('TimerFcn','GUI_rest_inst',...
    'Period', exp_inform.period_inst, 'ExecutionMode', 'fixedRate'); 

% timer vairable button_initialize
exp_inform.sf_of_timer = floor(exp_inform.sf*exp_inform.period_sampling_of_timer); % timer sampling frequency

% timer set-up of data acquasition 
timer_obj.data_acq_n_preprocessing = timer('TimerFcn','data_acq_n_preprocessing',...
    'Period',exp_inform.period_sampling_of_timer, 'ExecutionMode', 'fixedRate');

% timer set-up of data presentation (plot) 
timer_obj.onPaint = timer('TimerFcn','onPaint',...
    'StartDelay',exp_inform.period_sampling_of_timer,...
    'Period', exp_inform.period_sampling_of_timer,...
    'ExecutionMode', 'fixedRate');
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%

%------------------------raw data back-up buffer--------------------------%

%minutes to seconds
exp_inform.time_for_experiment_sec = exp_inform.time_for_experiment * 60; 

% set up 10 minutes for raw data backup
DB_backup.raw_data = zeros(exp_inform.sf*exp_inform.time_for_experiment_sec,exp_inform.n_ch_rawdata+1);
DB_backup.raw_pos = 1;

% raw data of in offline
DB_backup.curr_pos=1;

% 
DB_backup.FeatSet = cell(exp_inform.n_fe,1);
DB_backup.FeatSet_test = cell(exp_inform.n_fe,1);
DB_backup.test_result = cell(exp_inform.n_fe,1);
%-------------------------------------------------------------------------%



%------------------------circlequeue buffer set-up------------------------%

% set circlequeue
% cq.TCP = circlequeue(exp_inform.length_buff,exp_inform.n_ch_rawdata); %10*64, 2채널+Trigger
cq.emg_procc = circlequeue(exp_inform.length_buff,exp_inform.n_bip_ch); %10*64, 2채널+Trigger
cq.trg_GUI = circlequeue(exp_inform.length_buff,1); % for GUI trigger buffer
% cq.featset = circlequeue(exp_inform.length_buff,1); % for GUI trigger buffer



% set online buffer of ouput (classfied)
cq.output = circlequeue(exp_inform.n_win_mv,1);

% set online buffer feature set for train/test
cq.featset = circlequeue(exp_inform.n_win,exp_inform.n_bip_ch*3+exp_inform.n_bip_ch*4);

% % set online
cq.test_result = circlequeue(exp_inform.n_win,1);%초기화
%-------------------------------------------------------------------------%


%----------------------preprocessing parameters---------------------------%
p.filter_order = 4; Fn = exp_inform.sf/2;
p.freq_bandpass = [20 450];
p.freq_stop = [58 62];
[p.f.bB,p.f.bA] = butter(p.filter_order,p.freq_bandpass/Fn,'bandpass');
[p.f.nB,p.f.nA] = butter(p.filter_order,p.freq_stop/Fn,'stop');
p.f.bZn = [];
p.f.nZn = [];
%-------------------------------------------------------------------------%
end

%---------------------------------back-up---------------------------------%
% if ~isfield(info,'cam')
%     cam = webcam(1);
% end
% h1 = preview(cam);
% CData = h1.CData;
% closePreview(cam);
% hcam = image(zeros(size(CData)),'Parent', handles.axes_timg1); 
% currp = preview(cam,hcam);

% TCP 연결
%configure% the folowing 4 values should match with your setings in Actiview and your network settings 
% port = 8888;                %the port that is configured in Actiview , delault = 8888
% ipadress = 'localhost';     %the ip adress of the pc that is TCP_running Actiview
% tcp.Channels = 16;             %set to the same value as in Actiview "tcp.Channels sent by TCP"
% tcp.Samples = 16;               %set to the same value as in Actiview "TCP tcp.Samples/channel"
% %!configure%
% 
% %variable%
% words = tcp.Channels*tcp.Samples;
% % loop = 1000;
% %open tcp connection%
% 
% tcpipClient = tcpip(ipadress,port,'NetworkRole','Client');
% set(tcpipClient,'InputBufferSize',words*9); %input buffersize is 3 times the tcp block size %1 word = 3 bytes
% set(tcpipClient,'Timeout',5);
% % TCP 
% period4TCP = round(tcp.Samples/exp_inform.sf,3);
% TCP = timer('Timersfn','TcpIpClientMatlabV1', 'Period',0.055, 'ExecutionMode', 'fixedRate');
%-------------------------------------------------------------------------%
