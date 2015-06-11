function varargout = notate_emission_gui(varargin)
% NOTATE_EMISSION_GUI M-file for notate_emission_gui.fig
%      NOTATE_EMISSION_GUI, by itself, creates a new NOTATE_EMISSION_GUI or raises the existing
%      singleton*.
%
%      H = NOTATE_EMISSION_GUI returns the handle to a new NOTATE_EMISSION_GUI or the handle to
%      the existing singleton*.
%
%      NOTATE_EMISSION_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NOTATE_EMISSION_GUI.M with the given input arguments.
%
%      NOTATE_EMISSION_GUI('Property','Value',...) creates a new NOTATE_EMISSION_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before notate_emission_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to notate_emission_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help notate_emission_gui

% Last Modified by GUIDE v2.5 02-Jun-2009 16:27:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @notate_emission_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @notate_emission_gui_OutputFcn, ...
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


% --- Executes just before notate_emission_gui is made visible.
function notate_emission_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to notate_emission_gui (see VARARGIN)

% Choose default command line output for notate_emission_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes notate_emission_gui wait for user response (see UIRESUME)
% uiwait(handles.notate_emission_gui);


% --- Outputs from this function are returned to the command line.
function varargout = notate_emission_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_remove_emission.
function pushbutton_remove_emission_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_remove_emission (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Load global data
UD = get(handles.notate_emission_gui, 'UserData');

% Delete emission from database
filename = get(handles.edit_input_file, 'string');
emission_no = get(handles.popupmenu_em_list, 'value');
emission_list = neg_access_emission_list(filename);
emission_list = neg_access_emission_list(filename, emission_list(emission_no), 'rem');

% Redraw emission boxes
UD.boxes = neg_draw_emission_boxes(UD.h_ax, emission_list, UD.boxes);

% Update emission dropdown
neg_update_emission_dropdown(handles.popupmenu_em_list, emission_list);

% Save global data
set(handles.notate_emission_gui, 'UserData', UD);

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_get_emission.
function pushbutton_get_emission_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_get_emission (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure(1);

h_text = neg_write_big_letters('Select lower left', gca);
[x, y] = ginput(1);
x = max(min(x, 20), 0);
y = max(min(y, 10), 0);
set(handles.edit_time_start, 'String', num2str(x));
set(handles.edit_f_lc, 'String', num2str(y));
delete(h_text);

h_text = neg_write_big_letters('Select upper right', gca);
[x, y] = ginput(1);
x = max(min(x, 20), 0);
y = max(min(y, 10), 0);
set(handles.edit_time_end, 'String', num2str(x));
set(handles.edit_f_uc, 'String', num2str(y));
delete(h_text);

% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



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



function edit_time_start_Callback(hObject, eventdata, handles)
% hObject    handle to edit_time_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_time_start as text
%        str2double(get(hObject,'String')) returns contents of edit_time_start as a double


% --- Executes during object creation, after setting all properties.
function edit_time_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_time_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_time_end_Callback(hObject, eventdata, handles)
% hObject    handle to edit_time_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_time_end as text
%        str2double(get(hObject,'String')) returns contents of edit_time_end as a double


% --- Executes during object creation, after setting all properties.
function edit_time_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_time_end (see GCBO)
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


% --- Executes on button press in checkbox_chorus.
function checkbox_chorus_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_chorus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_chorus


% --- Executes on button press in checkbox_hiss.
function checkbox_hiss_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_hiss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_hiss


% --- Executes on button press in checkbox_corruption.
function checkbox_corruption_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_corruption (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_corruption


% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Load global data
UD = get(handles.notate_emission_gui, 'UserData');

em.em_type.chorus = get(handles.checkbox_chorus, 'Value');
em.em_type.hiss = get(handles.checkbox_hiss, 'Value');
em.em_type.corruption = get(handles.checkbox_corruption, 'Value');

conf_str = get(handles.listbox_confidence, 'String');
conf_str = conf_str{get(handles.listbox_confidence, 'Value')};
em.confidence = str2double(strtok(conf_str, '%'));

em.t_start = str2double(get(handles.edit_time_start, 'String'));
em.t_end = str2double(get(handles.edit_time_end, 'String'));
em.f_lc = str2double(get(handles.edit_f_lc, 'String'));
em.f_uc = str2double(get(handles.edit_f_uc, 'String'));

% Error checking
if isnan(em.t_start), error('Indicate start time'); end
if isnan(em.t_end), error('Indicate end time'); end
if isnan(em.f_lc), error('Indicate f_lc'); end
if isnan(em.f_uc), error('Indicate f_uc'); end
if em.t_end <= em.t_start, error('End time must be after start time'); end
if em.f_uc <= em.f_lc, error('f_uc must be greater than f_lc'); end

data_filename = get(handles.edit_input_file, 'string');

emission_list = neg_access_emission_list(data_filename, em, 'add');

% Draw boxes
UD.boxes = neg_draw_emission_boxes(UD.h_ax, emission_list, UD.boxes, 1);

% Update emission dropdown
neg_update_emission_dropdown(handles.popupmenu_em_list, emission_list);

% Save global data
set(handles.notate_emission_gui, 'UserData', UD);


function edit_input_file_Callback(hObject, eventdata, handles)
% hObject    handle to edit_input_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_input_file as text
%        str2double(get(hObject,'String')) returns contents of edit_input_file as a double


% --- Executes during object creation, after setting all properties.
function edit_input_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_input_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_load.
function pushbutton_load_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Load global data
UD = get(handles.notate_emission_gui, 'UserData');

set(handles.text_msgs, 'String', '');

filename = get(handles.edit_input_file, 'String');

% Make spectrogram
[h_ax, file_datenum] = neg_make_spectrogram(filename);
UD.h_ax = h_ax;

% Write date field
set(handles.edit_date, 'String', datestr(file_datenum, 'yyyy/mm/dd'));

% Load emissions
emission_list = neg_access_emission_list(filename);

[pathstr, name, ext] = fileparts(filename);
disp(sprintf('Loaded %s', [name ext]));

% Plot boxes around emissions
if ~isfield(UD, 'boxes')
	UD.boxes = [];
end

% Draw boxes
UD.boxes = neg_draw_emission_boxes(UD.h_ax, emission_list, UD.boxes, 1);

% Update emission dropdown
neg_update_emission_dropdown(handles.popupmenu_em_list, emission_list);

% Save global data
set(handles.notate_emission_gui, 'UserData', UD);


% --- Executes on button press in pushbutton_browse.
function pushbutton_browse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('*.mat', 'Select input file', get(handles.edit_input_file, 'String'));

if ischar(filename)
	set(handles.edit_input_file, 'String', fullfile(pathname, filename));
	pushbutton_load_Callback(handles.pushbutton_load, eventdata, handles);
end

% --- Executes on button press in pushbutton_next.
function pushbutton_next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
	next_image_str = neg_find_next_image(get(handles.edit_input_file, 'String'), 1);
	set(handles.edit_input_file, 'String', next_image_str);
	% Load the image
	pushbutton_load_Callback(handles.pushbutton_load, eventdata, handles);
catch er
	if strcmp(er.identifier, 'neg_find_next_image:NoMoreImages')
% 		disp(sprintf('At end of image listings'));
		set(handles.text_msgs, 'String', 'No more images');
	else
		rethrow(er);
	end
end

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_prev.
function pushbutton_prev_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
	next_image_str = neg_find_next_image(get(handles.edit_input_file, 'String'), -1);
	set(handles.edit_input_file, 'String', next_image_str);
	% Load the image
	pushbutton_load_Callback(handles.pushbutton_load, eventdata, handles);
catch er
	if strcmp(er.identifier, 'ecg_find_next_image:NoMoreImages')
% 		disp(sprintf('At end of image listings'));
		set(handles.text_msgs, 'String', 'No more images');
	end
end

% --- Executes on selection change in listbox_confidence.
function listbox_confidence_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_confidence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_confidence contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_confidence


% --- Executes during object creation, after setting all properties.
function listbox_confidence_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_confidence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function pushbutton_load_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in popupmenu_em_list.
function popupmenu_em_list_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_em_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_em_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_em_list

% Load global data
UD = get(handles.notate_emission_gui, 'UserData');

filename = get(handles.edit_input_file, 'string');
emission_list = neg_access_emission_list(filename);
emission_no = get(hObject, 'value');

UD.boxes = neg_draw_emission_boxes(UD.h_ax, emission_list, UD.boxes, emission_no);

% Save global data
set(handles.notate_emission_gui, 'UserData', UD);

% --- Executes during object creation, after setting all properties.
function popupmenu_em_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_em_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


