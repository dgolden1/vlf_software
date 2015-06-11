function varargout = lanl_sat_gui(varargin)
% LANL_SAT_GUI M-file for lanl_sat_gui.fig
%      LANL_SAT_GUI, by itself, creates a new LANL_SAT_GUI or raises the existing
%      singleton*.
%
%      H = LANL_SAT_GUI returns the handle to a new LANL_SAT_GUI or the handle to
%      the existing singleton*.
%
%      LANL_SAT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LANL_SAT_GUI.M with the given input arguments.
%
%      LANL_SAT_GUI('Property','Value',...) creates a new LANL_SAT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lanl_sat_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lanl_sat_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lanl_sat_gui

% Last Modified by GUIDE v2.5 28-May-2008 12:18:49

% $Id$

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lanl_sat_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @lanl_sat_gui_OutputFcn, ...
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


% --- Executes just before lanl_sat_gui is made visible.
function lanl_sat_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lanl_sat_gui (see VARARGIN)

% Choose default command line output for lanl_sat_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes lanl_sat_gui wait for user response (see UIRESUME)
% uiwait(handles.lanl_sat_gui);


% --- Outputs from this function are returned to the command line.
function varargout = lanl_sat_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_makemap.
function pushbutton_makemap_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_makemap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.checkbox_show_sats, 'Value') == 1
	bShowSats = true;
else
	bShowSats = false;
end

global MD % map data
utc_str = get(handles.edit_utc, 'String');
utc = datenum([str_to_datevec(utc_str) 0]);
MD.az_0 = get_longitude_from_utc(utc);
[MD.map_ax, MD.fig] = create_map(MD.az_0, bShowSats);

if bShowSats
	center_earth(MD.map_ax);
end
% MD.term_surf = plot_terminator(-MD.az_0 - 90);

utc_vec = datevec(utc);
wd = pwd;
cd('/home/dgolden/vlf/scripts/newMapTool');
plotDayNight(utc_vec, [-90 0], [0 360], 1e4, 0, MD.map_ax);
cd(wd);


palmer_lt_str = get(handles.edit_palmerlt, 'String');

utc_str = datestr(utc, 'mmm dd, yyyy HH:MM');
palmer_lt_str = datestr([str_to_datevec(palmer_lt_str) 0], 'mmm dd, yyyy HH:MM');

if bShowSats
	title(MD.map_ax, sprintf('%s UTC\n(%s Palmer LT)', utc_str, palmer_lt_str), ...
		'FontSize', 14, 'FontWeight', 'bold');
else
	title(MD.map_ax, sprintf('%s UTC (%s Palmer LT)', utc_str, palmer_lt_str), ...
		'FontSize', 12, 'FontWeight', 'bold');
end

function edit_utc_Callback(hObject, eventdata, handles)
% hObject    handle to edit_utc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_utc as text
%        str2double(get(hObject,'String')) returns contents of edit_utc as a double

% Error checking on entered time
% Error checking on entered time
try
	utc = datenum([str_to_datevec(get(hObject, 'String')) 0]);
catch
	uiwait(errordlg('Invalid date vector'));
	utc = datenum([2003 1 1 0 0 0]);
end

user_update_all_times(utc, handles, hObject);

% --- Executes during object creation, after setting all properties.
function edit_utc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_utc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_closemap.
function pushbutton_closemap_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_closemap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global MD
close(MD.fig);


% --- Executes on button press in pushbutton_closeall.
function pushbutton_closeall_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_closeall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(findobj('-not', 'Tag', 'lanl_sat_gui', '-and', 'Type', 'figure'));


% --- Executes on slider movement.
function slider_utc_Callback(hObject, eventdata, handles)
% hObject    handle to slider_utc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Extract time from slider
min = get(hObject,'Min');
max = get(hObject,'Max');
assert(min == 0 && max == 1);
value = get(hObject,'Value');

max_hour = 23 + 59/60;

hour = floor(value*max_hour);
minute = floor((value*max_hour - hour)*60);

utc = hour*100 + minute;
user_update_all_times(utc, handles, hObject);

% --- Executes during object creation, after setting all properties.
function slider_utc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_utc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit_palmerlt_Callback(hObject, eventdata, handles)
% hObject    handle to edit_palmerlt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_palmerlt as text
%        str2double(get(hObject,'String')) returns contents of edit_palmerlt as a double

% Error checking on entered time
try
	palmer_lt_vec = str_to_datevec(get(hObject, 'String'));
	utc = palmer_lt_to_utc([datenum(palmer_lt_vec) 0]);
catch
	uiwait(errordlg('Invalid date vector'));
	utc = datenum([2003 1 1 0 0 0]);
end

user_update_all_times(utc, handles, hObject);

% --- Executes during object creation, after setting all properties.
function edit_palmerlt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_palmerlt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_palmerlt_Callback(hObject, eventdata, handles)
% hObject    handle to slider_palmerlt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Extract time from slider
min = get(hObject,'Min');
max = get(hObject,'Max');
assert(min == 0 && max == 1);
value = get(hObject,'Value');

max_hour = 23 + 59/60;

hour = floor(value*max_hour);
minute = floor((value*max_hour - hour)*60);

utc = palmer_lt_to_utc(hour*100 + minute);

user_update_all_times(utc, handles, hObject);


% --- Executes during object creation, after setting all properties.
function slider_palmerlt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_palmerlt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%% My functions
function user_update_all_times(utc, handles, hObject)
% utc: utc time as an integer
% handles: all the handles
% hObject: handle of the calling object

lt = utc_to_palmer_lt(utc);

% utc_hour = floor(utc/100);
% utc_minute = floor(mod(utc, 100));
% lt_hour = floor(lt/100);
% lt_minute = floor(mod(lt, 100));

% % Set the UTC slider
% if ~strcmp(get(hObject, 'Tag'), 'slider_utc')
% 	utc_slider_value = utc_hour/24 + utc_minute/3600;
% 	set(handles.slider_utc, 'Value', utc_slider_value);
% end

% Set the UTC edit
if ~exist('hObject', 'var') || ~strcmp(get(hObject, 'Tag'), 'edit_utc')
% 	utcstr = sprintf('[%04d %02d %02d %02d %02d 0', utc_hour, utc_minute);
	utcstr = datestr(utc, '[yyyy mm dd HH MM]');
	set(handles.edit_utc, 'String', utcstr);
end

% % Set the LT slider
% if ~strcmp(get(hObject, 'Tag'), 'slider_palmerlt')
% 	lt_slider_value = lt_hour/24 + lt_minute/3600;
% 	set(handles.slider_palmerlt, 'Value', lt_slider_value);
% end
	
% Set the LT edit
if ~exist('hObject', 'var') || ~strcmp(get(hObject, 'Tag'), 'edit_palmerlt')
% 	ltstr = sprintf('%02d%02d', lt_hour, lt_minute);
	ltstr = datestr(lt, '[yyyy mm dd HH MM]');
	set(handles.edit_palmerlt, 'String', ltstr);
end


% --- Executes on button press in checkbox_show_sats.
function checkbox_show_sats_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_show_sats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_show_sats


