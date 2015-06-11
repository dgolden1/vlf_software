function varargout = whOverlayGUI(varargin)
% WHOVERLAYGUI M-file for whOverlayGUI.fig
%      WHOVERLAYGUI, by itself, creates a new WHOVERLAYGUI or raises the existing
%      singleton*.
%
%      H = WHOVERLAYGUI returns the handle to a new WHOVERLAYGUI or the handle to
%      the existing singleton*.
%
%      WHOVERLAYGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WHOVERLAYGUI.M with the given input arguments.
%
%      WHOVERLAYGUI('Property','Value',...) creates a new WHOVERLAYGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before whOverlayGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to whOverlayGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help whOverlayGUI

% Last Modified by GUIDE v2.5 04-May-2007 16:31:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @whOverlayGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @whOverlayGUI_OutputFcn, ...
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


% --- Executes just before whOverlayGUI is made visible.
function whOverlayGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to whOverlayGUI (see VARARGIN)

% Choose default command line output for whOverlayGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes whOverlayGUI wait for user response (see UIRESUME)
% uiwait(handles.whoverlaygui);

% all future plots will be placed on top of the spectrogram
global DF
set(DF.fig,'DoubleBuffer','on');
h = findobj('Tag','spec_axis');
set(h,'DrawMode','fast','NextPlot','add'); % axis



% --- Outputs from this function are returned to the command line.
function varargout = whOverlayGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function overlay_d0minfield_Callback(hObject, eventdata, handles)
% hObject    handle to overlay_d0minfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of overlay_d0minfield as text
%        str2double(get(hObject,'String')) returns contents of overlay_d0minfield as a double


% --- Executes during object creation, after setting all properties.
function overlay_d0minfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to overlay_d0minfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function overlay_d0maxfield_Callback(hObject, eventdata, handles)
% hObject    handle to overlay_d0maxfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of overlay_d0maxfield as text
%        str2double(get(hObject,'String')) returns contents of overlay_d0maxfield as a double


% --- Executes during object creation, after setting all properties.
function overlay_d0maxfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to overlay_d0maxfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function overlay_stepfield_Callback(hObject, eventdata, handles)
% hObject    handle to overlay_stepfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of overlay_stepfield as text
%        str2double(get(hObject,'String')) returns contents of overlay_stepfield as a double


% --- Executes during object creation, after setting all properties.
function overlay_stepfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to overlay_stepfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function overlay_startfield_Callback(hObject, eventdata, handles)
% hObject    handle to overlay_startfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of overlay_startfield as text
%        str2double(get(hObject,'String')) returns contents of overlay_startfield as a double
whShowOverlay;

% --- Executes during object creation, after setting all properties.
function overlay_startfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to overlay_startfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

xlimits = get(findobj('Tag', 'spec_axis'), 'XLim');
set(hObject, 'String', num2str(xlimits(1)));

% --- Executes on button press in overlay_donebutton.
function overlay_donebutton_Callback(hObject, eventdata, handles)
% hObject    handle to overlay_donebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
whDoneOverlay;

% --- Executes on button press in overlay_clearbutton.
function overlay_clearbutton_Callback(hObject, eventdata, handles)
% hObject    handle to overlay_clearbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
whClearOverlayAll;

% --- Executes on button press in overlay_showbutton.
function overlay_showbutton_Callback(hObject, eventdata, handles)
% hObject    handle to overlay_showbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
whShowOverlay;

% --- Executes on slider movement.
function overlay_startslider_Callback(hObject, eventdata, handles)
% hObject    handle to overlay_startslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Make sure we didn't move the slider out of bounds, which happens sometimes
min = get(hObject, 'Min');
max = get(hObject, 'Max');
if get(hObject, 'Value') < min
	set(hObject, 'Value', min);
elseif get(hObject, 'Value') > max
	set(hObject, 'Value', max);
end

whSlider;

% --- Executes during object creation, after setting all properties.
function overlay_startslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to overlay_startslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

spec_axis = findobj('Tag','spec_axis');
if isempty(spec_axis), error('Unable to find spectrogram axis'); end

xlimits = get(spec_axis, 'XLim');
time_start = xlimits(1);
time_end = xlimits(2);

if time_start < 0
	error('time_start must be > 0');
end

set(hObject, 'Min', time_start, 'Max', time_end);
set(hObject, 'Value', time_start);


% --- Executes during object creation, after setting all properties.
function text1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


