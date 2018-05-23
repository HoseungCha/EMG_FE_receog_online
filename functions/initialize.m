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
% clear GUItimer_obj timer_obj exp_inform path File cq p;

% global info; % info,  함수간 공용으로 필요한 변수로 사용
% global pd; % pd, circlequq의 형태로 공용으로 필요한 변수로 사용
global GUI;
global timer_obj
global exp_inform;
global path;
global File;
global cq;
global p;
%-------------------------------------------------------------------------%
%============================PROGRM MODE==================================%
% choose GUI mode file_bdf, file_mat, online_biosemi, online_biosemi_eprime
% In thre train mode,
% except file_mat, other GUI modes needs to initialize parameters
% the meaning you need to initialzie parameters is that you should save
% those parameters with data as file_mat format.
% File_mat is the final output and will be just used for replaying
% experiment

% check program mdoe
id_check_strinput = contains({'file_bdf','file_mat','online_biosemi','online_biosemi_eprime'},...
    get(handles.edit_program_mode,'String'));
if any(id_check_strinput) && ~isempty(get(handles.edit_program_mode,'String'))
    GUI.prog_mode = get(handles.edit_program_mode,'String');
else
   tmp_str = 'PLEASE INPUT PROGRAM MODE';
   handles.edit_insturction.String = tmp_str;
   disp(tmp_str);
   disp('PROG MODE: file_bdf,file_mat,online_biosemi,online_biosemi_eprime');
   error('ERROR OCCURS')
end
%=========================================================================%


%+++++++++++++++++++++++++++++FILE MODE+++++++++++++++++++++++++++++++++++%
if strfind(GUI.prog_mode,'file')
% set file extension with pram mode
if strfind(GUI.prog_mode,'bdf')
    file_extension = '*.bdf';
elseif strfind(GUI.prog_mode,'mat')
    file_extension = '*.mat';
end
%--------------------temp code for load bdf------------------------------_%
[FileName,PathName,~] = uigetfile(...
    fullfile(path.code,'DB','DB_online',file_extension));
if FileName==0
    return;
end

% make path by information of uigetfile
filepath = [PathName,FileName];

% get file extension
[~,File.name,ext] = fileparts(FileName);

switch ext
    case '.bdf'
        %load bdf
        out = pop_biosig(filepath);
        
        % get raw data and triggers of EMG
        [lat_trg,idx_seq_FE] = get_trg_bdf(out.event);
        
        File.raw_data = double(out.data');
        
        % if channel size is , get rid of channel for EOG (2)
        if size(File.raw_data,2) == 12
            File.raw_data(:,[4,9]) = [];
        end
            
        File.n_raw_ch = size(File.raw_data,2);
        File.lat_trg_onset  = lat_trg;
        File.idx_seq_FE = idx_seq_FE;
        File.curr_pos = 1;
    case '.mat'
        % load mat
        out = load(filepath);
        
        % get paramter from mat file
        exp_inform = out.exp_inform;

        % get raw data
        File.raw_data = out.DB_backup.rawdata;
        File.n_raw_ch = size(File.raw_data,2);
        File.curr_pos = 1;
end
end

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%



%+++++++IN ALL TEST MODE, YOU SHOULD USE PARAMETER FROM TRAIN+++++++++++++%
if ~strcmp(GUI.prog_mode,'file_mat')
if handles.radiobutton_test.Value


% if it is test session, get information of experiment 
[FileName,PathName,~] = uigetfile({'*.mat'},...
'SELECT TRAIN MAT FILE',fullfile(path.code,'DB','DB_online'));
if FileName==0
    error('YOU MUST SELECT TRAIN MAT');
end

% get path of the training set that we are using now
path.model_n_DB_from_train = [PathName,FileName];

% display of models on GUI
set(handles.edit_model_input,'String',FileName);

% get paramters and machine learning model
load(fullfile(path.model_n_DB_from_train),'exp_inform');

% save model by training set
exp_inform.model_FE = exp_inform.model.FE;
exp_inform.model_FE_emotion = exp_inform.model.FE_emotion;

exp_inform.exp_mode = 'test_mode';

end
end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%


%++++++++++IN TRAIN MODE, YOU MUST INITIALIZE PARAMETERS++++++++++++++++++%
%+++++++++++++++ONLY EXCEPT PRGRAM MODE of file_mat+++++++++++++++++++++++%
if ~strcmp(GUI.prog_mode,'file_mat')
if handles.radiobutton_train.Value
exp_inform.exp_mode = 'train_mode';

% choose version of list of facial expression
% 8 facial expression list
% exp_inform.name_FE = {'angry','contemptuous(right)','disgusted','fearfull',...
%     'happy','neutral','sad','surprised'};

% 11 facial expression list
exp_inform.name_FE = {'ANGRY';'CLENCH';'CONTEMPT_LEFT';...
    'CONTEMPT_RIGHT';'FROWN';'FEAR';...
    'HAPPY';'KISS';'NEUTRAL';'SAD';'SURPRISED'};

% exp_inform.name_FE = {'angry';'neutral';'kiss'};

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

% name of machine learning moel for FE expression reocognition
exp_inform.name_ml = 'lda';

% name of machine learning model for EMG onset detection
exp_inform.name_EMG_onset = 'model_tree_emg_onset';

% emg pair list
exp_inform.idx_pair_right = [1,2;1,3;2,3]; %% 오른쪽 전극 조합
exp_inform.idx_pair_left = [10,9;10,8;9,8]; %% 왼쪽 전극 조합

% DEICISION PARAMERS
exp_inform.i_emg_pair = 1;


%--------------FACIAL UNIT RELATED
exp_inform.name_classifier = {'cf_eyebrow','cf_lipshapes'};
exp_inform.n_cf = length(exp_inform.name_classifier);
exp_inform.idx_FE2classfy = {[1,6,7,9,10,11],[1,2,3,4,6,7,8,11]};

name_FE2classfy = cell(exp_inform.n_cf,1);
for i_cf = 1 : exp_inform.n_cf
    name_FE2classfy{i_cf} = ...
        exp_inform.name_FE(exp_inform.idx_FE2classfy{i_cf});
end


exp_inform.name_gesture_clfr{1} = {'eye_brow_down','none','none','none','none','eye_brow_sad',...
    'none', 'none','neutral','eye_brow_sad','eye_brow_up'};
% name_gesture_clfr{2} = {'neutral','nose_wrinkle'};
exp_inform.name_gesture_clfr{2} = {'lip_tighten','clench','lip_corner_up_left',...
    'lip_corner_up_right','none', 'lip_stretch_down',...
    'lip_corner_up_both','kiss','neutral', 'none','lip_open'};


% get features of determined emotions that you want to classify
exp_inform.model.FE = cell(exp_inform.n_cf,1);
exp_inform.idx_ch_FE2classfy{1} = ...
    [2,6,10,14,18,22,26,3,7,11,15,19,23,27];
exp_inform.idx_ch_FE2classfy{2} = ...
    [1,5,9,13,17,21,25,4,8,12,16,20,24,28];

%-------------------------------------------------------------------------%

%-------------------------experiemnt information--------------------------%
% number of expression
exp_inform.n_fe = length(exp_inform.name_FE);

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

% load model EMG onset 
exp_inform.model = load(fullfile(path.code,'rsc','model_tree_emg_onset'));

exp_inform.idx_emg_onest = [0,1];
%-------------------------------------------------------------------------%
end
end

%------------------GUI FACIAL EPXRESSION SEQUENCE SETTING-----------------%
if strfind(GUI.prog_mode,'file')
exp_inform.order_fe = File.idx_seq_FE'; % for backup
exp_inform.order_fe4GUI = File.idx_seq_FE'; % order_fe4GUI (사용)
else
% random order of facial expression, which can be used in training session
exp_inform.order_fe = randperm(exp_inform.n_fe); % for backup
exp_inform.order_fe4GUI = exp_inform.order_fe; % order_fe4GUI (사용)
end
%-------------------------------------------------------------------------%

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
GUI.idx_defalt_img = find(cellfun(@isempty,strfind(exp_inform.name_FE,'NEUTRAL'))==0);

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
% IF PROGAM MODE IS NOT FILE_MAT, YOU SHOULD SAVE DATA AS FILE_MAT
if ~strcmp(GUI.prog_mode,'file_mat')
%minutes to seconds
exp_inform.time_for_experiment_sec = exp_inform.time_for_experiment * 60; 

% set up 10 minutes for raw data backup
exp_inform.raw_data = zeros(exp_inform.sf*exp_inform.time_for_experiment_sec,exp_inform.n_ch_rawdata+1);
exp_inform.raw_pos = 1;

% raw data of in online
exp_inform.FeatSet = cell(exp_inform.n_fe,1);
end
%-------------------------------------------------------------------------%



%------------------------circlequeue buffer set-up------------------------%
% set circlequeue
cq.emg_procc = circlequeue(exp_inform.length_buff,exp_inform.n_bip_ch); %10*64, 2채널+Trigger
cq.trg_GUI = circlequeue(exp_inform.length_buff,1); % for GUI trigger buffer

%--------------EMOIOTN TRAIN
cq.output_emotion = circlequeue(exp_inform.n_win_mv,1);


% set online buffer of ouput (classfied)
cq.output_score{1} = circlequeue(exp_inform.n_win_mv,...
    length(exp_inform.idx_FE2classfy{1}));
cq.output_score{2} = circlequeue(exp_inform.n_win_mv,...
    length(exp_inform.idx_FE2classfy{2}));

cq.output_test{1} = circlequeue(exp_inform.n_win_mv,1);
cq.output_test{2} = circlequeue(exp_inform.n_win_mv,1);

% set online buffer feature set for train/test
cq.featset = circlequeue(exp_inform.n_win,exp_inform.n_bip_ch*3+exp_inform.n_bip_ch*4);

% set online
cq.test_result = circlequeue(exp_inform.n_win,1);%초기화

% set emg onset
cq.emg_onset = circlequeue(exp_inform.length_buff,exp_inform.n_bip_ch);%초기화

% 
cq.emg_onset4mv = circlequeue(exp_inform.n_win_mv,exp_inform.n_bip_ch);
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

exp_inform.i_trl=1;
%---------------Serial communication(computer by computer)----------------%
% you should set those parameter at the same with settings of com&port
% in device manager

%     exp_inform.PC_serial = serial('COM6'); % 장치관리자에서 serial port 확인해서 설정 (실험실 오른쪽 컴퓨터)
%     set(exp_inform.PC_serial, 'BaudRate', 9600, 'DataBits', 8, 'StopBits', 1,...
%         'Parity', 'none', 'FlowControl', 'none', 'TimeOut', 0.01)
%     fopen(exp_inform.PC_serial);
%-------------------------------------------------------------------------%

end
