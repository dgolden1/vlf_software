function varargout = emission_char_gui(varargin)
% EMISSION_CHAR_GUI M-file for emission_char_gui.fig
%      EMISSION_CHAR_GUI, by itself, creates a new EMISSION_CHAR_GUI or raises the existing
%      singleton*.
%
%      H = EMISSION_CHAR_GUI returns the handle to a new EMISSION_CHAR_GUI or the handle to
%      the existing singleton*.
%
%      EMISSION_CHAR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EMISSION_CHAR_GUI.M with the given input arguments.
%
%      EMISSION_CHAR_GUI('Property','Value',...) creates a new EMISSION_CHAR_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before emission_char_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to emission_char_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help emission_char_gui

% Last Modified by GUIDE v2.5 22-Dec-2008 13:51:15

% $Id$

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @emission_char_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @emission_char_gui_OutputFcn, ...
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


% --- Executes just before emission_char_gui is made visible.
function emission_char_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to emission_char_gui (see VARARGIN)

% Choose default command line output for emission_char_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes emission_char_gui wait for user response (see UIRESUME)
% uiwait(handles.emission_char_gui);

% Load settings
try
	ecg_load_settings(handles);
catch
	er = lasterror;

	% If the error is that the settings file doesn't exist, ignore it
	% Otherwise, rethrow the error
	if ~strcmp(er.identifier, 'ecg_load_settings:SettingsNotFound')
		rethrow(er);
	end
end


% --- Outputs from this function are returned to the command line.
function varargout = emission_char_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_input_jpeg_Callback(hObject, eventdata, handles)
% hObject    handle to edit_input_jpeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_input_jpeg as text
%        str2double(get(hObject,'String')) returns contents of edit_input_jpeg as a double


% --- Executes during object creation, after setting all properties.
function edit_input_jpeg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_input_jpeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_output_db_Callback(hObject, eventdata, handles)
% hObject    handle to edit_output_db (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_output_db as text
%        str2double(get(hObject,'String')) returns contents of edit_output_db as a double


% --- Executes during object creation, after setting all properties.
function edit_output_db_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_output_db (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_load_jpeg.
function pushbutton_load_jpeg_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_jpeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% pushbutton_close_all_Callback(handles.pushbutton_close_all, eventdata, handles);
pushbutton_load_jpeg_no_clear_Callback(handles.pushbutton_load_jpeg_no_clear, eventdata, handles);

% --- Executes on button press in pushbutton_save_db.
function pushbutton_save_db_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save_db (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ecg_save_emission(handles);

% --- Executes on button press in pushbutton_get_upper_right.
function pushbutton_get_upper_right_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_get_upper_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Make image axis current
UD = get(handles.emission_char_gui, 'UserData');
axes(UD.img_axis);

[hour, minute, freq] = ecg_pix_to_param(ginput(1));

set(handles.edit_end_time, 'String', sprintf('%02d:%02d', hour, minute));
set(handles.edit_f_uc, 'String', sprintf('%0.1f', freq/1e3));

% --- Executes on button press in pushbutton_get_emission.
function pushbutton_get_emission_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_get_emission (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

UD = get(handles.emission_char_gui, 'UserData');
h_ax = UD.img_axis;
h_img = UD.img;

h_text = ecg_write_big_letters('Get Lower Left', h_ax);
pushbutton_get_lower_left_Callback(handles.pushbutton_get_lower_left, eventdata, handles);
delete(h_text);
h_text = ecg_write_big_letters('Get Upper Right', h_ax);
pushbutton_get_upper_right_Callback(handles.pushbutton_get_upper_right, eventdata, handles);
delete(h_text);

h_text = ecg_write_big_letters('Get Intensity', h_ax);
pushbutton_get_intensity_Callback(handles.pushbutton_get_intensity, eventdata, handles);
delete(h_text);

% % Get intensity
% start_datenum = ecg_get_datenum_from_fields(get(handles.edit_date, 'String'), get(handles.edit_start_time, 'String'));
% end_datenum = ecg_get_datenum_from_fields(get(handles.edit_date, 'String'), get(handles.edit_end_time, 'String'));
% f_lc = str2double(get(handles.edit_f_lc, 'String'));
% f_uc = str2double(get(handles.edit_f_uc, 'String'));
% [x_min, y_max] = ecg_param_to_pix((start_datenum - floor(start_datenum))*24, f_lc);
% [x_max, y_min] = ecg_param_to_pix((end_datenum - floor(end_datenum))*24, f_uc);
% [intensity, x_center, y_center, radius] = ecg_get_max_emission_intensity(x_min, x_max, y_min, y_max, h_img);
% 
% set(handles.edit_intensity, 'String', num2str(intensity));
% 
% int.x_center = x_center;
% int.y_center = y_center;
% int.radius = radius;
% UD.intensity_str = int;
% 
% % TODO: Keep working on this! 207/12/12
% 
% marker_handle = ecg_add_single_emission_marker(event, h_ax, bIncludeCaption, color)
% 
% circle_handle = ecg_mark_intensity_location(x_center, y_center, radius, h_ax);

% Zoom emission if checked
if get(handles.checkbox_auto_zoom, 'Value')
	% Force snapshot duration to 2 seconds, in case the user left it on a
	% longer duration. If the user prefers a different duration, this can
	% get irritating
	set(handles.edit_sec_snapshots, 'String', '2');
	pushbutton_zoom_this_emission_Callback(handles.pushbutton_zoom_this_emission, eventdata, handles);
end

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_get_lower_left.
function pushbutton_get_lower_left_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_get_lower_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Make image axis current
UD = get(handles.emission_char_gui, 'UserData');
axes(UD.img_axis);

[hour, minute, freq] = ecg_pix_to_param(ginput(1));

set(handles.edit_start_time, 'String', sprintf('%02d:%02d', hour, minute));
set(handles.edit_f_lc, 'String', sprintf('%0.1f', freq/1e3));



% --- Executes on selection change in popupmenu_emission_type.
function popupmenu_emission_type_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_emission_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_emission_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_emission_type


% --- Executes during object creation, after setting all properties.
function popupmenu_emission_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_emission_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_date_Callback(hObject, eventdata, handles)
% hObject    handle to edit_date (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_date as text
%        str2double(get(hObject,'String')) returns contents of edit_date as a double


% --- Executes during object creation, after setting all properties.
function edit_date_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_date (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_start_time_Callback(hObject, eventdata, handles)
% hObject    handle to edit_start_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_start_time as text
%        str2double(get(hObject,'String')) returns contents of edit_start_time as a double


% --- Executes during object creation, after setting all properties.
function edit_start_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_start_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_end_time_Callback(hObject, eventdata, handles)
% hObject    handle to edit_end_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_end_time as text
%        str2double(get(hObject,'String')) returns contents of edit_end_time as a double


% --- Executes during object creation, after setting all properties.
function edit_end_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_end_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_f_lc_Callback(hObject, eventdata, handles)
% hObject    handle to edit_f_lc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_f_lc as text
%        str2double(get(hObject,'String')) returns contents of edit_f_lc as a double


% --- Executes during object creation, after setting all properties.
function edit_f_lc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_f_lc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_f_uc_Callback(hObject, eventdata, handles)
% hObject    handle to edit_f_uc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_f_uc as text
%        str2double(get(hObject,'String')) returns contents of edit_f_uc as a double


% --- Executes during object creation, after setting all properties.
function edit_f_uc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_f_uc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in popupmenu_intensity.
function popupmenu_intensity_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_intensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_intensity contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_intensity


% --- Executes during object creation, after setting all properties.
function popupmenu_intensity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_intensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_particle_event.
function popupmenu_particle_event_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_particle_event (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_particle_event contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_particle_event


% --- Executes during object creation, after setting all properties.
function popupmenu_particle_event_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_particle_event (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_notes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_notes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_notes as text
%        str2double(get(hObject,'String')) returns contents of edit_notes as a double


% --- Executes during object creation, after setting all properties.
function edit_notes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_notes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_browse_jpeg.
function pushbutton_browse_jpeg_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_browse_jpeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.jpg;*.png', 'Select 24-hour spectrogram JPEG', get(handles.edit_input_jpeg, 'String'));

if ischar(filename)
	set(handles.edit_input_jpeg, 'String', fullfile(pathname, filename));
end

% --- Executes on button press in pushbutton_browse_db.
function pushbutton_browse_db_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_browse_db (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.mat', 'Select output database file', get(handles.edit_output_db, 'String'));

if ischar(filename)
	set(handles.edit_output_db, 'String', fullfile(pathname, filename));
end


function edit_kp_Callback(hObject, eventdata, handles)
% hObject    handle to edit_kp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_kp as text
%        str2double(get(hObject,'String')) returns contents of edit_kp as a double


% --- Executes during object creation, after setting all properties.
function edit_kp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_kp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_dst_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dst as text
%        str2double(get(hObject,'String')) returns contents of edit_dst as a double


% --- Executes during object creation, after setting all properties.
function edit_dst_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_close_all.
function pushbutton_close_all_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_close_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(findobj('-not', 'Tag', 'emission_char_gui', '-and', 'Type', 'figure'));
ecg_clear_fields(handles);


% --- Executes on button press in pushbutton_write_text.
function pushbutton_write_text_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_write_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

matfilename = get(handles.edit_output_db, 'String');
[pathstr, name, ext] = fileparts(matfilename);
textfilename = fullfile(pathstr, [name '.txt']);

load(matfilename, 'events');
ecg_write_text_from_events(events, textfilename);
disp(sprintf('Wrote %s', textfilename));


% --- Executes on button press in pushbutton_get_intensity.
function pushbutton_get_intensity_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_get_intensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


UD = get(handles.emission_char_gui, 'UserData');
axes(UD.img_axis);

try
	radius = 10;
	intensity = ecg_get_intensity_from_pix(ecg_get_surrounding_pixels(ginput(1), radius), UD.img);
	set(handles.edit_intensity, 'String', sprintf('%d', round(intensity)));
catch
	er = lasterror;
	uiwait(errordlg(er.identifier, 'Unable to get intensity'));
end



function edit_intensity_Callback(hObject, eventdata, handles)
% hObject    handle to edit_intensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_intensity as text
%        str2double(get(hObject,'String')) returns contents of edit_intensity as a double


% --- Executes during object creation, after setting all properties.
function edit_intensity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_intensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_next_image.
function pushbutton_next_image_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_next_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the next image string
try
	next_image_str = ecg_find_next_image(get(handles.edit_input_jpeg, 'String'), 1);
	set(handles.edit_input_jpeg, 'String', next_image_str);
	% Load the image
	pushbutton_load_jpeg_Callback(handles.pushbutton_load_jpeg, eventdata, handles);
catch
	er = lasterror;
	if strcmp(er.identifier, 'ecg_find_next_image:NoMoreImages')
		disp(sprintf('At end of image listings'));
	end
end


% --- Executes on button press in pushbutton_load_jpeg_no_clear.
function pushbutton_load_jpeg_no_clear_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_jpeg_no_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Clear fields
ecg_clear_fields(handles);

% Parse the date from the file name and set the 'date' field
filename = get(handles.edit_input_jpeg, 'String');
[pathstr, name, ext] = fileparts(filename);
% assert(strcmp(name(1:7), 'palmer_'));
% yearstr = name(8:11);
% monthstr = name(12:13);
% daystr = name(14:15);
assert(name(end-8) == '_');
yearstr = name((end-7):(end-4));
monthstr = name((end-3):(end-2));
daystr = name((end-1):end);
set(handles.edit_date, 'String', sprintf('%s/%s/%s', monthstr, daystr, yearstr));

% Open figure
UD = get(handles.emission_char_gui, 'UserData');
if isfield(UD, 'fig_handle') && ishandle(UD.fig_handle)
	h = UD.fig_handle;
	sfigure(h);
	clf;
	clear('UD');
else
	h = figure;
end
UD.fig_handle = h;

% Load and display the image
img = imread(filename);
UD.img = img;

imshow(img, 'Border', 'Tight');
ax = gca;
hold on;
UD.img_axis = ax;

% Save image parameters
set(handles.emission_char_gui, 'UserData', UD);

disp(sprintf('Loaded file %s', filename));

% Set global variables for the edges of the spectrogram
ecg_set_spec_globals(img);

% Mark known emissions if 'mark on load' is checked
if get(handles.checkbox_mark_on_load, 'Value')
	pushbutton_mark_known_Callback(handles.pushbutton_mark_known, eventdata, handles);
end


% --- Executes on button press in pushbutton_mark_known.
function pushbutton_mark_known_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_mark_known (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

db_filename = get(handles.edit_output_db, 'String');
if ~exist(db_filename, 'file')
	disp(sprintf('%s does not yet exist', db_filename))
	return;
end

date_str = get(handles.edit_date, 'String');
start_datenum = datenum(date_str, 'mm/dd/yyyy');
end_datenum = start_datenum + 1;
UD = get(handles.emission_char_gui, 'UserData');
h_ax = UD.img_axis;
bIncludeCaption = get(handles.checkbox_incl_notes, 'Value');

marker_handles = ecg_mark_known_emissions(db_filename, start_datenum, end_datenum, h_ax, bIncludeCaption, 'bitmap');

UD.marker_handles = marker_handles;
set(handles.emission_char_gui, 'UserData', UD);


% --- Executes on button press in pushbutton_prev_image.
function pushbutton_prev_image_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_prev_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the next image string
try
	next_image_str = ecg_find_next_image(get(handles.edit_input_jpeg, 'String'), -1);
	set(handles.edit_input_jpeg, 'String', next_image_str);
	% Load the image
	pushbutton_load_jpeg_Callback(handles.pushbutton_load_jpeg, eventdata, handles);
catch
	er = lasterror;
	if strcmp(er.identifier, 'ecg_find_next_image:NoMoreImages')
		disp(sprintf('At end of image listings'));
	end
end


% --- Executes on button press in checkbox_em_chorus.
function checkbox_em_chorus_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_em_chorus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_em_chorus


% --- Executes on button press in checkbox_em_hiss.
function checkbox_em_hiss_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_em_hiss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_em_hiss


% --- Executes on button press in checkbox_em_whistlers.
function checkbox_em_whistlers_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_em_whistlers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_em_whistlers


% --- Executes on button press in checkbox_em_other.
function checkbox_em_other_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_em_other (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_em_other

if get(hObject, 'Value')
	set(handles.edit_em_other, 'Enable', 'on');
else
	set(handles.edit_em_other, 'Enable', 'off', 'String', '');
end


function edit_em_other_Callback(hObject, eventdata, handles)
% hObject    handle to edit_em_other (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_em_other as text
%        str2double(get(hObject,'String')) returns contents of edit_em_other as a double


% --- Executes during object creation, after setting all properties.
function edit_em_other_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_em_other (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_save_set_on_exit.
function checkbox_save_set_on_exit_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_save_set_on_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_save_set_on_exit


% --- Executes when user attempts to close emission_char_gui.
function emission_char_gui_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to emission_char_gui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.checkbox_save_set_on_exit, 'Value')
	try
		ecg_save_settings(handles);
	catch
		er = lasterror;
		warning(sprintf('Unable to save settings: %s', er.message));
	end
end

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in checkbox_mark_on_load.
function checkbox_mark_on_load_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_mark_on_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_mark_on_load


% --- Executes on button press in checkbox_incl_notes.
function checkbox_incl_notes_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_incl_notes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_incl_notes


% --- Executes on button press in pushbutton_mod_emission.
function pushbutton_mod_emission_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_mod_emission (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

UD = get(handles.emission_char_gui, 'UserData');
h_ax = UD.img_axis;

h_text = ecg_write_big_letters('Select Emission', h_ax);
[event, event_i, marker_handle, marker_num] = ecg_user_select_emission(handles);
delete(h_text);

% Delete marker
UD = get(handles.emission_char_gui, 'UserData');
delete([UD.marker_handles(marker_num).r UD.marker_handles(marker_num).t]);
UD.marker_handles(marker_num) = [];
set(handles.emission_char_gui, 'UserData', UD);

% Delete event from database
load(get(handles.edit_output_db, 'String'), 'events');
events(event_i) = [];
save(get(handles.edit_output_db, 'String'), 'events');

% Load the just-deleted event data into the fields
ecg_clear_fields(handles, false);
ecg_populate_fields_from_event(handles, event);


% UD = get(handles.emission_char_gui, 'UserData');
% axes(UD.img_axis);
% [x,y] = ginput(1);
% 
% % Find the marker and delete it
% bFoundMarker = false;
% for kk = 1:length(UD.marker_handles)
% 	rect_pos = get(UD.marker_handles(kk).r, 'Position');
% 	r_x = rect_pos(1);
% 	r_y = rect_pos(2);
% 	r_width = rect_pos(3);
% 	r_height = rect_pos(4);
% 	
% 	% Is this the box we clicked inside? If so, delete it.
% 	if x >= r_x && x <= (r_x + r_width) && y >= r_y && y <= (r_y + r_height)
% 		bFoundMarker = true;
% 		delete([UD.marker_handles(kk).r UD.marker_handles(kk).t]);
% 		UD.marker_handles(kk) = [];
% 		set(handles.emission_char_gui, 'UserData', UD);
% 		break;
% 	end
% end
% if ~bFoundMarker
% % 	error('ECGModEmission:NoEmissionOnClick', 'No emissions exist at that time and frequency')
% 	uiwait(errordlg('No emissions exist at that time and frequency', 'Invalid Selection'));
% 	return;
% end
% 
% % Convert x and y coordinates into time
% [hour, minute, freq] = ecg_pix_to_param([x, y]);
% date_str = get(handles.edit_date, 'String');
% date = datenum(date_str, 'mm/dd/yyyy') + hour/24 + minute/1440;
% 
% % Delete the event from the database
% load(get(handles.edit_output_db, 'String'), 'events');
% events_i = find([events.start_datenum] <= date & [events.end_datenum] >= date);
% if length(events_i) > 1
% 	error('Multiple events found for %s (database error)', datestr(date));
% elseif isempty(events_i)
% 	error('No events found for %s', datestr(date));
% end
% event = events(events_i);
% events(events_i) = [];
% save(get(handles.edit_output_db, 'String'), 'events');
% 
% % Load the just-deleted event data into the fields
% ecg_clear_fields(handles, false);
% ecg_populate_fields_from_event(handles, event);


% --- Executes on button press in pushbutton_zoom.
function pushbutton_zoom_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get start and end times for zoom
date = datenum(get(handles.edit_date, 'String'), 'mm/dd/yyyy');
UD = get(handles.emission_char_gui, 'UserData');
axes(UD.img_axis);
h_ax = UD.img_axis;
db_filename= get(handles.edit_output_db, 'String');

h_text = ecg_write_big_letters('Select Lower Left', h_ax);
[x, y] = ginput(1);
[hour, minute, f_lc] = ecg_pix_to_param(x, y);
f_lc = round(f_lc);
delete(h_text);
start_datenum = date + hour/24 + minute/1440;

h_text = ecg_write_big_letters('Select Upper Right', h_ax);
[x, y] = ginput(1);
[hour, minute, f_uc] = ecg_pix_to_param(x, y);
f_uc = round(f_uc);
delete(h_text);
end_datenum = date + hour/24 + minute/1440;

sec_per_snapshot = str2double(get(handles.edit_sec_snapshots, 'String'));

ecg_zoom_emission(handles, start_datenum, end_datenum, db_filename, f_lc, f_uc, sec_per_snapshot);


function edit_sec_snapshots_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec_snapshots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec_snapshots as text
%        str2double(get(hObject,'String')) returns contents of edit_sec_snapshots as a double


% --- Executes during object creation, after setting all properties.
function edit_sec_snapshots_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec_snapshots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_zoom_this_emission.
function pushbutton_zoom_this_emission_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_zoom_this_emission (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

db_filename = get(handles.edit_output_db, 'String');

start_datenum = ecg_get_datenum_from_fields(get(handles.edit_date, 'String'), get(handles.edit_start_time, 'String'));
end_datenum = ecg_get_datenum_from_fields(get(handles.edit_date, 'String'), get(handles.edit_end_time, 'String'), true);
f_lc = round(str2double(get(handles.edit_f_lc, 'String'))*1e3);
f_uc = round(str2double(get(handles.edit_f_uc, 'String'))*1e3);
sec_per_snapshot = 2;

ecg_zoom_emission(handles, start_datenum, end_datenum, db_filename, f_lc, min(f_uc*1.5, 10e3), sec_per_snapshot);


% --- Executes on button press in pushbutton_zoom_selected.
function pushbutton_zoom_selected_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_zoom_selected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

UD = get(handles.emission_char_gui, 'UserData');
h_ax = UD.img_axis;

db_filename = get(handles.edit_output_db, 'String');

h_text = ecg_write_big_letters('Select Emission', h_ax);
event = ecg_user_select_emission(handles);
delete(h_text);

% Zoom a little outside the emission too
f_lc = max(300, event.f_lc/2);
f_uc = min(10e3, event.f_uc*2);
sec_per_snapshot = 2;
ecg_zoom_emission(handles, event.start_datenum, event.end_datenum, db_filename, f_lc, f_uc, sec_per_snapshot);

% --- Executes on button press in checkbox_auto_zoom.
function checkbox_auto_zoom_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_auto_zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_auto_zoom



function year_edit_Callback(hObject, eventdata, handles)
% hObject    handle to year_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of year_edit as text
%        str2double(get(hObject,'String')) returns contents of year_edit as a double

year = str2double(get(hObject, 'string'));
assert(year > 1990 && year < 2020);



% --- Executes during object creation, after setting all properties.
function year_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to year_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_20seczoom.
function pushbutton_20seczoom_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_20seczoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

db_filename = get(handles.edit_output_db, 'String');

% Get start and end times for zoom
date = datenum(get(handles.edit_date, 'String'), 'mm/dd/yyyy');
UD = get(handles.emission_char_gui, 'UserData');
axes(UD.img_axis);
h_ax = UD.img_axis;

h_text = ecg_write_big_letters('Select Segment', h_ax);
[x, y] = ginput(1);
[hour, minute, f_uc] = ecg_pix_to_param(x, y);
f_uc = round(f_uc);
delete(h_text);
end_datenum = date + hour/24 + minute/1440;

start_datenum = end_datenum - 1/96; % 15 minutes earlier

f_lc = 300;
sec_per_snapshot = 20;

ecg_zoom_emission(handles, start_datenum, end_datenum, db_filename, f_lc, f_uc, sec_per_snapshot);
