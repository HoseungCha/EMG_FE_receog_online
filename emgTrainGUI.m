function varargout = emgTrainGUI(varargin)
% EMGTRAINGUI MATLAB code for emgTrainGUI.fig
%      EMGTRAINGUI, by itself, creates a new EMGTRAINGUI or raises the existing
%      singleton*.
%
%      H = EMGTRAINGUI returns the handle to a new EMGTRAINGUI or the handle to
%      the existing singleton*.
%
%      EMGTRAINGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EMGTRAINGUI.M with the given input arguments.
%
%      EMGTRAINGUI('Property','Value',...) creates a new EMGTRAINGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before emgTrainGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to emgTrainGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help emgTrainGUI

% Last Modified by GUIDE v2.5 20-Sep-2018 02:08:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @emgTrainGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @emgTrainGUI_OutputFcn, ...
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


% --- Executes just before emgTrainGUI is made visible.
function emgTrainGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to emgTrainGUI (see VARARGIN)
global h_image;
global h_list;
global xTrain;

% addpath toolbox
addpath(genpath(fullfile(cd,'Toolbox')));

name_emo = {'Angry','Clench',...
'LipUp(L)','LipUp(R)',...
'LipUp(B)','Fear',...
'Happy','Kiss','Neutral',...
'Sad','Surprised'};
handles.listbox2.String = name_emo;
h_list = handles.listbox2;
h_list.String = name_emo;
% Choose default command line output for emgTrainGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

addpath(genpath(fullfile(cd,'functions')))
% perpare figure
% memory allocations
nFE =11;
h_image = gobjects(nFE,1); % graphics button_init
name_FE = {'ANGRY';'CLENCH';'CONTEMPT_LEFT';...
    'CONTEMPT_RIGHT';'FROWN';'FEAR';...
    'HAPPY';'KISS';'NEUTRAL';'SAD';'SURPRISED'};

for i=1:nFE
    pathImage = fullfile(cd,'rsc','img_fe_11','train',...
        [name_FE{i},'.jpg']);
    temp_img= imread(pathImage);
    eval(sprintf('h_image(i) = imshow(temp_img,''Parent'',handles.axes%d);',i));
end
idxFE =1:11;
idxFE(9) = [];
showFEimg(9,nFE);
% permute(1:nFE)
OrderFE = [];
for i = 1 : 3
    temp = randperm(11)';
    temp(temp==9) = [];
    temp = [9;temp];
    OrderFE = [OrderFE;temp];
end
feOrderSession = reshape(name_emo(OrderFE),11,3);
handles.uitable1.Data = feOrderSession;
handles.uitable1.UserData = reshape(OrderFE,11,3);
xTrain = cell(11,3);


% UIWAIT makes emgTrainGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = emgTrainGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_start.
function pushbutton_start_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a=1;


% --- Executes on button press in pushbutton_back.
function pushbutton_back_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_up.
function pushbutton_up_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a=1;
newValue = handles.listbox2.Value-1;
if newValue<1
    disp('Cannot select emotion');
    return;
end
handles.listbox2.Value = newValue;


% --- Executes on button press in pushbutton_down.
function pushbutton_down_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a=1;
newValue = handles.listbox2.Value+1;

if length(handles.listbox2.String) <newValue
    disp('Cannot select emotion');
    return;
end
handles.listbox2.Value = newValue;

% --- Executes on selection change in popupmenu_mode.
function popupmenu_mode_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% disp(handles.popupmenu_mode.String{handles.popupmenu_mode.Value});
modeType = handles.popupmenu_mode.String{handles.popupmenu_mode.Value};
% dataType = handles.popupmenu_dataType.String{handles.popupmenu_dataType.Value};

% check data type
% disp(handles.popupmenu_dataType.String{handles.popupmenu_dataType.Value});

if strcmp(modeType,'Online')
    handles.popupmenu_dataType.Enable='off';
    handles.pushbutton_loadFile.Enable= 'off';
    handles.pushbutton_Init.Enable= 'on';
    handles.pushbuttonTrain.Enable = 'off';
    fprintf('do %s anlaysis\n',modeType);
    % Code here
    
    return;
elseif strcmp(modeType,'OneTouch')
    handles.popupmenu_dataType.Enable='on';
    handles.pushbutton_loadFile.Enable= 'on';
    handles.pushbuttonTrain.Enable = 'off';
    handles.pushbutton_Init.Enable= 'off';
    
    fprintf('do %s anlaysis\n',modeType);

end


% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_mode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_mode


% --- Executes during object creation, after setting all properties.
function popupmenu_mode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_dataType.
function popupmenu_dataType_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_dataType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_dataType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_dataType
fprintf('load %s file\n',eventdata.Source.String{eventdata.Source.Value});

% --- Executes during object creation, after setting all properties.
function popupmenu_dataType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_dataType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_loadFile.
function pushbutton_loadFile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loadFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global path
modeType = handles.popupmenu_mode.String{handles.popupmenu_mode.Value};
dataType = handles.popupmenu_dataType.String{handles.popupmenu_dataType.Value}; 

[FileName,PathName,FilterIndex] = uigetfile(['*.',dataType]);
if FilterIndex==0
    path = [];
    handles.pushbuttonTrain.Enable = 'off';
    return;
else
    selpath = fullfile(PathName,FileName);
    path.selpath = selpath;
    handles.pushbuttonTrain.Enable = 'on';
end

function edit_Instruction_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Instruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Instruction as text
%        str2double(get(hObject,'String')) returns contents of edit_Instruction as a double


% --- Executes during object creation, after setting all properties.
function edit_Instruction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Instruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_Init.
function pushbutton_Init_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Init (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global myTimer
global analysisParameters

handles.uipanel1.Visible = 'on';
modeType = handles.popupmenu_mode.String{handles.popupmenu_mode.Value};
dataType = handles.popupmenu_dataType.String{handles.popupmenu_dataType.Value};

if strcmp(modeType,'Online')
% timer refresh time 설정
tf = 0.05; 
   

%=======임시코드 biosemi 연결귀찮아서 bdf 파일로 play하면서 우선 분석
if strcmp(dataType,'bdf')
       disp('replay bdf file');
    % prepare timer for replay BDF
    [myTimer,analysisParameters] = getTimerRePlayBDF(tf);
end
%======================================%

end


% --- Executes on button press in pushbuttonExit.
function pushbuttonExit_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear all;
close all force;


% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
global trgGetSignal
global winBackup 
global xTrain
global myTimer
global winCount
global idSessionTrain

if ~isempty(eventdata.Indices)
%테이블 index 반환
i=eventdata.Indices(1);
j=eventdata.Indices(2);
tableName = eventdata.Source.Data{i,j};
if strcmp(tableName(end-1:end),'TR')==1
    answer = questdlg('Do you want to register this facial expression again?', ...
	'Caution: data can be overwritten', ...
	'Yes','No','No');
    switch answer
    case 'Yes'
        tableName(end-2:end) =[];
    case 'No'
        return;
    end   
end


% 표정 그림 출력
showFEimg(hObject.UserData(i,j),11);
    
% Data acquasition 시작
start(myTimer)

% 3초간 기다리기
c = 1;
while(c>0)
    handles.edit_Instruction.String = sprintf('Please wait (%d second)',c);
    pause(1);
    c = c -1;
end
handles.edit_Instruction.String = sprintf('Make a %s face',tableName);
pause(0.001);



% 피험자가 표정을 짓는 순간!
trgGetSignal = true;
while(trgGetSignal==true)
if rem(winCount,2) ==0
    temp = winCount* 0.05;
    handles.edit_Instruction.String = ...
        sprintf('Please keep %s face (%.1f second)',tableName,temp);
else
    pause(0.05*(2-1));
end
end
pause(0.1);
xTrain{i,j} = winBackup;

% 테이블 표시 업데이트
strFlagTrained = '_TR';
eventdata.Source.Data{i,j} = [tableName,strFlagTrained];
handles.edit_Instruction.String = sprintf('Please relax your face');

% 무표정 사진 출력
showFEimg(9,11);

% Train 데이터 다 모였는지 확인
idSessionTrain = NaN(3,1);
for i_ses=1:3
    idSessionTrain(i_ses) = all(contains(eventdata.Source.Data(:,i_ses),'_TR'));
end
if any(idSessionTrain)
    handles.pushbuttonTrain.Enable = 'on';
end

end


% --- Executes on button press in pushbuttonTrain.
function pushbuttonTrain_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global xTrain idSessionTrain analysisParameters
global path
modeType = handles.popupmenu_mode.String{handles.popupmenu_mode.Value};
dataType = handles.popupmenu_dataType.String{handles.popupmenu_dataType.Value};

if  strcmp(modeType,'OneTouch')
    if strcmp(dataType,'bdf')
        doOneTouchAnalysisBDF(path);       
    elseif strcmp(dataType,'mat')
        disp('do offline anlaysis of mat file');
    end
   return; 
end

% handles.uitable1.UserData
% change data format to fit in doAnalysisRiemanAdaption
xTrainInput = cell(analysisParameters.nSeg,analysisParameters.nFE,...
    length(find(idSessionTrain)));

for iSes =find(idSessionTrain)'
temp = xTrain(:,iSes);
temp = cat(4,temp{:});

for iSeg = 1 : analysisParameters.nSeg
    for iFE = 1:analysisParameters.nFE
        xTrainInput{iSeg,iFE,iSes} = temp(:,:,iSeg,iFE);
    end
end
end
% train
[mdlNewList,mdlExpertUser,CovMeanExpertUser,...
    mdlCali,CovMeanCali,accuracy] = doAnalysisRiemanAdaption(...
   'iEMGpair',analysisParameters.emgPair,...
   'winSize',analysisParameters.winSize,...
   'winSegTest',xTrainInput,...
   'nFE',analysisParameters.nFE,...
   'TestMode','train',...
   'alphaList',0:0.2:1,...
   'betaList',0:0.2:1,...
   'pathDB','D:\research\FE_recog_offline_ver2.0\DB\DB_proc\DB_raw_demRiemannian');
% save mdl
ReportCodeExe = reportCodeExecution;
savePath = fullfile(cd,'DB','mat');
uisave({'mdlNewList','mdlExpertUser','CovMeanExpertUser',...
    'mdlCali','CovMeanCali','ReportCodeExe','analysisParameters'},...
    fullfile(savePath,string(ReportCodeExe.ExecuteTime)));

