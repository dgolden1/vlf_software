function varargout = whAnalysisGUI(varargin)
% WHANALYSISGUI M-file for whAnalysisGUI.fig
%      WHANALYSISGUI, by itself, creates a new WHANALYSISGUI or raises the existing
%      singleton*.
%
%      H = WHANALYSISGUI returns the handle to a new WHANALYSISGUI or the handle to
%      the existing singleton*.
%
%      WHANALYSISGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WHANALYSISGUI.M with the given input arguments.
%
%      WHANALYSISGUI('Property','Value',...) creates a new WHANALYSISGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before whAnalysisGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to whAnalysisGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help whAnalysisGUI

% Last Modified by GUIDE v2.5 28-Sep-2007 12:44:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @whAnalysisGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @whAnalysisGUI_OutputFcn, ...
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


% --- Executes just before whAnalysisGUI is made visible.
function whAnalysisGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to whAnalysisGUI (see VARARGIN)

% Choose default command line output for whAnalysisGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes whAnalysisGUI wait for user response (see UIRESUME)
% uiwait(handles.getpointsgui);

global DF;

% Set the default path of the "destination" field to be the same as the destination on
% the main VLF GUI
destination = findobj(hObject, 'Tag', 'destination');
set(destination, 'String', DF.destinPath);

% Set up the spectrogram to have points drawn on it
set(findobj('Tag','spec_axis'),'DrawMode','fast','NextPlot','add');
set(findobj('Tag','spec_axis'),'XColor','RED','YColor','RED');

% run whGetClicks whenever there is a mouse click on the spectrogram
set(findobj('Tag', 'spec_image'), 'ButtonDownFcn', 'whGetClicks');

set(DF.fig, 'Pointer', 'crosshair'); % Change cursor to crosshair.



% --- Outputs from this function are returned to the command line.
function varargout = whAnalysisGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in done_button.
function done_button_Callback(hObject, eventdata, handles)
% hObject    handle to done_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
whDone;

% --- Executes on button press in delpt_button.
function delpt_button_Callback(hObject, eventdata, handles)
% hObject    handle to delpt_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
whDeletePoint;

% --- Executes on button press in savepts_button.
function savepts_button_Callback(hObject, eventdata, handles)
% hObject    handle to savepts_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
whSavePoints;

% --- Executes on button press in selsf_button.
function selsf_button_Callback(hObject, eventdata, handles)
% hObject    handle to selsf_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
whGetSferic;

% --- Executes on button press in overlay_button.
function overlay_button_Callback(hObject, eventdata, handles)
% hObject    handle to overlay_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
whOverlayGUI;

% --- Executes on button press in capsf_button.
function capsf_button_Callback(hObject, eventdata, handles)
% hObject    handle to capsf_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
whCaptureOverlaySferic;

% --- Executes on button press in delsf_button.
function delsf_button_Callback(hObject, eventdata, handles)
% hObject    handle to delsf_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
whDeleteSferic;

% --- Executes on button press in tarcsai_button.
function tarcsai_button_Callback(hObject, eventdata, handles)
% hObject    handle to tarcsai_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
whTarcsai;


function destination_Callback(hObject, eventdata, handles)
% hObject    handle to destination (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of destination as text
%        str2double(get(hObject,'String')) returns contents of destination as a double


% --- Executes during object creation, after setting all properties.
function destination_CreateFcn(hObject, eventdata, handles)
% hObject    handle to destination (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse_button.
function browse_button_Callback(hObject, eventdata, handles)
% hObject    handle to browse_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
whGetPointsDestinBrowse;


% --- Executes during object creation, after setting all properties.
function timev_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function freqv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freqv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function intensityv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intensityv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numpointsv_Callback(hObject, eventdata, handles)
% hObject    handle to numpointsv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numpointsv as text
%        str2double(get(hObject,'String')) returns contents of numpointsv as a double


% --- Executes during object creation, after setting all properties.
function sferic_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sferic_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function numpointsv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numpointsv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function sfericv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sfericv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


