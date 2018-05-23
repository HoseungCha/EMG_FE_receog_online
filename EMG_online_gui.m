%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
function varargout = EMG_online_gui(varargin)
% EMG_ONLINE_GUI MATLAB code for EMG_online_gui.fig
%      EMG_ONLINE_GUI, by itself, creates a new EMG_ONLINE_GUI or raises the existing
%      singleton*.
%
%      H = EMG_ONLINE_GUI returns the handle to a new EMG_ONLINE_GUI or the handle to
%      the existing singleton*.
%
%      EMG_ONLINE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EMG_ONLINE_GUI.M with the given input arguments.
%
%      EMG_ONLINE_GUI('Property','Value',...) creates a new EMG_ONLINE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EMG_online_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EMG_online_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EMG_online_gui

% Last Modified by GUIDE v2.5 17-May-2018 10:41:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EMG_online_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @EMG_online_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before EMG_online_gui is made visible.
function EMG_online_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EMG_online_gui (see VARARGIN)
clear global;

global GUI;
global path
% Choose default command line output for EMG_online_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%-------------set paths in compliance with Cha's code structure-----------%

% path of research, which contains toolbox
path.research = fileparts(fileparts(fileparts(fullfile(cd))));

% path of code, which 
path.code = fileparts(fullfile(cd));

%-------------------------------------------------------------------------%

% add path
addpath(fullfile(cd,'functions'));
addpath(genpath(fullfile(path.research,'_toolbox')));
GUI_mode_presentation(handles); % GUI presentation
GUI.button_init = 0;


% UIWAIT makes EMG_online_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EMG_online_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_insturction_Callback(hObject, eventdata, handles)
% hObject    handle to edit_insturction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_insturction as text
%        str2double(get(hObject,'String')) returns contents of edit_insturction as a double


% --- Executes during object creation, after setting all properties.
function edit_insturction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_insturction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_ize.
function pushbutton_initialize_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_initialize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
initialize(handles);



% --- Executes on button press in pushbutton_start.
function pushbutton_start_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global GUI
global timer_obj

% intializing check
if GUI.button_init == 0
   errordlg('Initialize 버튼을 눌러주세요');
    return;
end

% online 모드로 작동할 경우 use_biosemix 켜줌
if GUI.prog_mode == 1
    GUI.use_biosmix = 1;
end

%-------------------------------train mode--------------------------------%
if handles.radiobutton_train.Value
    % train session    
    % 실시간 데이터 처리 타이머 실행
    timer_obj.data_acq_n_preprocessing.UserData = tic;
    timer_obj.onPaint.UserData = tic;
    timer_obj.inst_make_fe.UserData = tic;
    timer_obj.inst_rest.UserData = tic;
    
    % 표정 인스트럭션 GUI 시작
    if ~strfind(GUI.prog_mode,'file')
        start(timer_obj.inst_make_fe); 
        start(timer_obj.inst_rest);
    end
    start(timer_obj.data_acq_n_preprocessing);
    start(timer_obj.onPaint);
end
%-------------------------------------------------------------------------%

%--------------------------------test-------------------------------------%
if handles.radiobutton_test.Value
    % train session    
    % 실시간 데이터 처리 타이머 실행
    timer_obj.data_acq_n_preprocessing.UserData = tic;
    timer_obj.onPaint.UserData = tic;
    timer_obj.inst_make_fe.UserData = tic;
    timer_obj.inst_rest.UserData = tic;
    
    % 표정 인스트럭션 GUI 시작
    if ~strfind(GUI.prog_mode,'file')
    start(timer_obj.inst_make_fe); 
    start(timer_obj.inst_rest);
    end
    start(timer_obj.data_acq_n_preprocessing);
    start(timer_obj.onPaint);
end
%-------------------------------------------------------------------------%

%--------------------temp code for load bdf------------------------------_%



% % 실시간 데이터 처리 타이머 실행
% timer_obj.data_acq_n_preprocessing.UserData = tic;
% timer_obj.onPaint.UserData = tic;
% timer_obj.inst_make_fe.UserData = tic;
% timer_obj.inst_rest.UserData = tic;
% % 표정 인스트럭션 GUI 시작
% 
% % start(timer_obj.FE_train); 
% % start(timer_obj.RestInst);
% start(timer_obj.data_acq_n_preprocessing);
% start(timer_obj.onPaint);





% --- Executes on button press in pushbutton_stop.
function pushbutton_stop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GUI;

myStop();
clear biosemix;
% if GUI.use_biosmix == 0
%     fclose(tcpipClient);
%     delete(tcpipClient);
% end
GUI.button_init  = 0;
% closePreview(cam);
% info = rmfield(info, 'cam');



% --- Executes on button press in pushbutton_open.
function pushbutton_open_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% global GUI
% global File
% global path
% global exp_inform
% %--------------------temp code for load bdf------------------------------_%
% [FileName,PathName,~] = uigetfile({'*.bdf';'*.mat'},'LOAD BDF or MAT',...
%     fullfile(path.code,'DB','DB_online'));
% if FileName==0
%     return;
% end
% 
% % make path by information of uigetfile
% filepath = [PathName,FileName];
% 
% % get file extension
% [~,~,ext] = fileparts(FileName);
% 
% switch ext
%     case '.bdf'
%         %load bdf
%         out = pop_biosig(filepath);
%         
%         % get raw data and triggers of EMG
%         [lat_trg,idx_seq_FE] = get_trg_bdf(out.event);
%         
%         File.raw_data = out.data;
%         File.lat_trg_onset  = lat_trg;
%         File.idx_seq_FE = idx_seq_FE;
%         
%         % set GUI program mode
%         GUI.prog_mode = 'file_bdf'; 
%     case '.mat'
%         % load mat
%         out = load(filepath);
%         
%         % get paramter from mat file
%         exp_inform = out.exp_inform;
% 
%         % get raw data
%         File.raw_data = out.raw_data(1:raw_pos,:);
%         
%         % set GUI program mode
%         GUI.prog_mode = 'file_mat'; 
% end


% --- Executes on button press in pushbutton_open.
function radiobutton_train_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in pushbutton_open.
GUI_mode_presentation(handles)

function radiobutton_test_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUI_mode_presentation(handles)




function edit_model_input_Callback(hObject, eventdata, handles)
% hObject    handle to edit_model_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_model_input as text
%        str2double(get(hObject,'String')) returns contents of edit_model_input as a double


% --- Executes during object creation, after setting all properties.
function edit_model_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_model_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_classification_Callback(hObject, eventdata, handles)
% hObject    handle to edit_classification (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_classification as text
%        str2double(get(hObject,'String')) returns contents of edit_classification as a double


% --- Executes during object creation, after setting all properties.
function edit_classification_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_classification (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
% close all force
delete(hObject);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(hObject);


% --- Executes on button press in pushbutton_exit.
function pushbutton_exit_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all force;
clear global;



function edit_program_mode_Callback(hObject, eventdata, handles)
% hObject    handle to edit_program_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_program_mode as text
%        str2double(get(hObject,'String')) returns contents of edit_program_mode as a double


% --- Executes during object creation, after setting all properties.
function edit_program_mode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_program_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
