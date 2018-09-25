function varargout = emgTestGUI(varargin)
% EMGTESTGUI MATLAB code for emgTestGUI.fig
%      EMGTESTGUI, by itself, creates a new EMGTESTGUI or raises the existing
%      singleton*.
%
%      H = EMGTESTGUI returns the handle to a new EMGTESTGUI or the handle to
%      the existing singleton*.
%
%      EMGTESTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EMGTESTGUI.M with the given input arguments.
%
%      EMGTESTGUI('Property','Value',...) creates a new EMGTESTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before emgTestGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to emgTestGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help emgTestGUI

% Last Modified by GUIDE v2.5 22-Sep-2018 14:57:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @emgTestGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @emgTestGUI_OutputFcn, ...
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


% --- Executes just before emgTestGUI is made visible.
function emgTestGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to emgTestGUI (see VARARGIN)

% Choose default command line output for emgTestGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% clear

% UIWAIT makes emgTestGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = emgTestGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonStart.
function pushbuttonStart_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global path analysisParameters mdl CovMeanCali 
global EditHandle
EditHandle = handles.edit1;

tf = 0.05;
load(path.selpath)

%========== 임시코드
% prepare timer for replay BDF
[myTimer,analysisParameters] = getTimerRePlayBDFTest(tf);
start(myTimer);
%============================

% 분류결과 표시

% [myTimer,analysisParameters] = getTimerRePlayBDF(tf);



% --- Executes on button press in pushbuttonLoad.
function pushbuttonLoad_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global path;
[FileName,PathName,FilterIndex] = uigetfile(['*.','mat']);
if FilterIndex==0
    path = [];
    handles.pushbuttonTrain.Enable = 'off';
    return;
else
    selpath = fullfile(PathName,FileName);
    path.selpath = selpath;
    handles.pushbuttonTrain.Enable = 'on';
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonPause.
function pushbuttonPause_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
myStop;


% --- Executes on button press in pushbuttonNewSession.
function pushbuttonNewSession_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNewSession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rawBackup rawPos % raw data 백업에 사용
rawBackup =[]; % 30분
rawPos = [];


% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rawBackup rawPos % raw data 백업에 사용
rawData = rawBackup(1:rawPos,:);
savePath = fullfile(cd,'DB','mat');
ReportCodeExe = reportCodeExecution;
uisave({'rawData'},fullfile(savePath,string(ReportCodeExe.ExecuteTime)));

