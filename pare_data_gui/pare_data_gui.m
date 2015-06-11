function varargout = pare_data_gui(varargin)
% PARE_DATA_GUI M-file for pare_data_gui.fig
%      PARE_DATA_GUI, by itself, creates a new PARE_DATA_GUI or raises the existing
%      singleton*.
%
%      H = PARE_DATA_GUI returns the handle to a new PARE_DATA_GUI or the handle to
%      the existing singleton*.
%
%      PARE_DATA_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PARE_DATA_GUI.M with the given input arguments.
%
%      PARE_DATA_GUI('Property','Value',...) creates a new PARE_DATA_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pare_data_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pare_data_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pare_data_gui

% Last Modified by GUIDE v2.5 27-Aug-2010 14:02:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pare_data_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @pare_data_gui_OutputFcn, ...
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


% --- Executes just before pare_data_gui is made visible.
function pare_data_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pare_data_gui (see VARARGIN)

% Choose default command line output for pare_data_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pare_data_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pare_data_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_source_Callback(hObject, eventdata, handles)
% hObject    handle to edit_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_source as text
%        str2double(get(hObject,'String')) returns contents of edit_source as a double


% --- Executes during object creation, after setting all properties.
function edit_source_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_dest_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dest as text
%        str2double(get(hObject,'String')) returns contents of edit_dest as a double


% --- Executes during object creation, after setting all properties.
function edit_dest_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_source_browse.
function pushbutton_source_browse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_source_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dirname = uigetdir(get(handles.edit_source, 'String'), 'Choose source directory');
if ischar(dirname)
	set(handles.edit_source, 'String', dirname);
end

% --- Executes on button press in pushbutton_dest_browse.
function pushbutton_dest_browse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_dest_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dirname = uigetdir(get(handles.edit_dest, 'String'), 'Choose destination directory');
if ischar(dirname)
	set(handles.edit_dest, 'String', dirname);
end

% --- Executes on button press in pushbutton_select_files.
function pushbutton_select_files_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_select_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

destin_path = get(handles.edit_dest, 'String');
start_sec = str2double(get(handles.edit_start_sec, 'String'));
duration = str2double(get(handles.edit_duration, 'String'));
new_suffix = get(handles.edit_new_suffix, 'String');
b_use_newdate = logical(get(handles.checkbox_new_date, 'Value'));
b_interleaved = logical(get(handles.checkbox_interleaved, 'Value'));

[filename, pathname] = uigetfile(fullfile(get(handles.edit_source, 'String'), '*.mat;*.MAT'), ...
	'Select files to pare', 'MultiSelect', 'on');
if ~iscell(filename)
	filename = {filename};
end

if ischar(pathname)
	disp(sprintf('Writing to %s', destin_path));
	t_start = now;
	for kk = 1:length(filename)
		new_filenames = copy_pared_data(fullfile(pathname, filename{kk}), destin_path, ...
			start_sec, duration, new_suffix, b_use_newdate, b_interleaved);
		if ~iscell(new_filenames), new_filenames = {new_filenames}; end
    
    % Convert interleaved data to 2-channel data; delete pared interleaved
    % files
    if get(handles.checkbox_convert_2ch, 'Value')
      for ll = 1:length(new_filenames)
        filenames_2ch = convert_interleaved_to_twochannel(new_filenames{ll}, ...
          destin_path, get(handles.edit_station_code, 'String'), 2);
        delete(new_filenames{ll});
      end
      
      new_filenames = filenames_2ch;
    end
    
		for ll = 1:length(new_filenames)
			[pathstr, name, ext] = fileparts(new_filenames{ll});
			disp(sprintf('Wrote %s', [name ext]));
		end
	end
	t_end = now;
	total_time = (t_end - t_start)*1440; % Minutes
	fprintf('Finished paring in %s\n', time_elapsed(t_start, t_end));
end


function edit_station_code_Callback(hObject, eventdata, handles)
% hObject    handle to edit_station_code (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_station_code as text
%        str2double(get(hObject,'String')) returns contents of edit_station_code as a double


% --- Executes during object creation, after setting all properties.
function edit_station_code_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_station_code (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_ns_only.
function checkbox_ns_only_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_ns_only (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_ns_only



function edit_start_sec_Callback(hObject, eventdata, handles)
% hObject    handle to edit_start_sec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_start_sec as text
%        str2double(get(hObject,'String')) returns contents of edit_start_sec as a double


% --- Executes during object creation, after setting all properties.
function edit_start_sec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_start_sec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_duration_Callback(hObject, eventdata, handles)
% hObject    handle to edit_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_duration as text
%        str2double(get(hObject,'String')) returns contents of edit_duration as a double


% --- Executes during object creation, after setting all properties.
function edit_duration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_new_suffix_Callback(hObject, eventdata, handles)
% hObject    handle to edit_new_suffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_new_suffix as text
%        str2double(get(hObject,'String')) returns contents of edit_new_suffix as a double


% --- Executes during object creation, after setting all properties.
function edit_new_suffix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_new_suffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_new_date.
function checkbox_new_date_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_new_date (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_new_date


% --- Executes on button press in checkbox_interleaved.
function checkbox_interleaved_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_interleaved (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_interleaved

% Only enable the convert to 2ch checkbox if this is interleaved data
if get(hObject,'Value')
  set(handles.checkbox_convert_2ch, 'Enable', 'On');
  set(handles.edit_station_code, 'Enable', 'On');
else
  set(handles.checkbox_convert_2ch, 'Value', 0, 'Enable', 'Off');
  set(handles.edit_station_code, 'Enable', 'Off');
end

% --- Executes on button press in checkbox_convert_2ch.
function checkbox_convert_2ch_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_convert_2ch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_convert_2ch



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit_station_code (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_station_code as text
%        str2double(get(hObject,'String')) returns contents of edit_station_code as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_station_code (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
