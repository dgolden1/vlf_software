function varargout = vlfSettingsGui(varargin)
% VLFSETTINGSGUI M-file for vlfSettingsGui.fig
%      VLFSETTINGSGUI, by itself, creates a new VLFSETTINGSGUI or raises the existing
%      singleton*.
%
%      H = VLFSETTINGSGUI returns the handle to a new VLFSETTINGSGUI or the handle to
%      the existing singleton*.
%
%      VLFSETTINGSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VLFSETTINGSGUI.M with the given input arguments.
%
%      VLFSETTINGSGUI('Property','Value',...) creates a new VLFSETTINGSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vlfSettingsGui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vlfSettingsGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help vlfSettingsGui

% Last Modified by GUIDE v2.5 24-Feb-2005 13:22:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vlfSettingsGui_OpeningFcn, ...
                   'gui_OutputFcn',  @vlfSettingsGui_OutputFcn, ...
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

% --- Executes just before vlfSettingsGui is made visible.
function vlfSettingsGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vlfSettingsGui (see VARARGIN)

% Choose default command line output for vlfSettingsGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes vlfSettingsGui wait for user response (see UIRESUME)
% uiwait(handles.settings);

if length(varargin) == 0
	error('vlfSettingsGui is not a stand-alone GUI application. Please run vlfTool instead.');
end



row = varargin{1};

global DF;

h = findobj('Tag', 'channel');
set( h, 'Value', DF.channel(row, 1) );

h = findobj('Tag', 'maxFreq');
set( h, 'String', num2str(DF.maxFreq(row, 1)/1e3) );

h = findobj('Tag', 'nfft');
set( h, 'String', num2str(DF.nfft(row, 1)) );
h = findobj('Tag', 'window');
set( h, 'String', num2str(DF.window(row, 1)) );
h = findobj('Tag', 'noverlap');
set( h, 'String', num2str(DF.noverlap(row, 1)) );

h = findobj('Tag', 'dbMin');
set( h, 'String', num2str(DF.dbScale(row, 1)) );
h = findobj('Tag', 'dbMax');
set( h, 'String', num2str(DF.dbScale(row, 2)) );

set( gcf, 'Name', num2str(row) );


% --- Outputs from this function are returned to the command line.
function varargout = vlfSettingsGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function nfft_Callback(hObject, eventdata, handles)
% hObject    handle to nfft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nfft as text
%        str2double(get(hObject,'String')) returns contents of nfft as a double


% --- Executes during object creation, after setting all properties.
function nfft_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nfft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function noverlap_Callback(hObject, eventdata, handles)
% hObject    handle to noverlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noverlap as text
%        str2double(get(hObject,'String')) returns contents of noverlap as a double


% --- Executes during object creation, after setting all properties.
function noverlap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noverlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function window_Callback(hObject, eventdata, handles)
% hObject    handle to window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of window as text
%        str2double(get(hObject,'String')) returns contents of window as a double


% --- Executes during object creation, after setting all properties.
function window_CreateFcn(hObject, eventdata, handles)
% hObject    handle to window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dbMax_Callback(hObject, eventdata, handles)
% hObject    handle to dbMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dbMax as text
%        str2double(get(hObject,'String')) returns contents of dbMax as a double


% --- Executes during object creation, after setting all properties.
function dbMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dbMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dbMin_Callback(hObject, eventdata, handles)
% hObject    handle to dbMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dbMin as text
%        str2double(get(hObject,'String')) returns contents of dbMin as a double


% --- Executes during object creation, after setting all properties.
function dbMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dbMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel.
function channel_Callback(hObject, eventdata, handles)
% hObject    handle to channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns channel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel


% --- Executes during object creation, after setting all properties.
function channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxFreq_Callback(hObject, eventdata, handles)
% hObject    handle to maxFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxFreq as text
%        str2double(get(hObject,'String')) returns contents of maxFreq as a double


% --- Executes during object creation, after setting all properties.
function maxFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function endSec_Callback(hObject, eventdata, handles)
% hObject    handle to endSec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endSec as text
%        str2double(get(hObject,'String')) returns contents of endSec as a double


% --- Executes during object creation, after setting all properties.
function endSec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endSec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in settingsCancel.
function settingsCancel_Callback(hObject, eventdata, handles)
% hObject    handle to settingsCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

closereq;


% --- Executes on button press in settingsOK.
function settingsOK_Callback(hObject, eventdata, handles)
% hObject    handle to settingsOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

row = str2num( get(gcf, 'Name') );

global DF;

h = findobj('Tag', 'channel');
DF.channel(row, 1) = get(h, 'Value');

h = findobj('Tag', 'maxFreq');
DF.maxFreq(row, 1) = str2num(get(h, 'String'))*1e3;

h = findobj('Tag', 'nfft');
DF.nfft(row, 1) = str2num(get(h, 'String'));
h = findobj('Tag', 'window');
DF.window(row, 1) = str2num(get(h, 'String'));
h = findobj('Tag', 'noverlap');
DF.noverlap(row, 1) = str2num(get(h, 'String'));

h = findobj('Tag', 'dbMin');
DF.dbScale(row, 1) = str2num(get(h, 'String'));
h = findobj('Tag', 'dbMax');
DF.dbScale(row, 2) = str2num(get(h, 'String'));

closereq;

