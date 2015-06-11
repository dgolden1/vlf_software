function varargout = convert_interleaved_to_twochannel_gui(varargin)
% CONVERT_INTERLEAVED_TO_TWOCHANNEL_GUI M-file for convert_interleaved_to_twochannel_gui.fig
%      CONVERT_INTERLEAVED_TO_TWOCHANNEL_GUI, by itself, creates a new CONVERT_INTERLEAVED_TO_TWOCHANNEL_GUI or raises the existing
%      singleton*.
%
%      H = CONVERT_INTERLEAVED_TO_TWOCHANNEL_GUI returns the handle to a new CONVERT_INTERLEAVED_TO_TWOCHANNEL_GUI or the handle to
%      the existing singleton*.
%
%      CONVERT_INTERLEAVED_TO_TWOCHANNEL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONVERT_INTERLEAVED_TO_TWOCHANNEL_GUI.M with the given input arguments.
%
%      CONVERT_INTERLEAVED_TO_TWOCHANNEL_GUI('Property','Value',...) creates a new CONVERT_INTERLEAVED_TO_TWOCHANNEL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before convert_interleaved_to_twochannel_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to convert_interleaved_to_twochannel_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help convert_interleaved_to_twochannel_gui

% Last Modified by GUIDE v2.5 27-May-2009 13:59:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @convert_interleaved_to_twochannel_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @convert_interleaved_to_twochannel_gui_OutputFcn, ...
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


% --- Executes just before convert_interleaved_to_twochannel_gui is made visible.
function convert_interleaved_to_twochannel_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to convert_interleaved_to_twochannel_gui (see VARARGIN)

% Choose default command line output for convert_interleaved_to_twochannel_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes convert_interleaved_to_twochannel_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = convert_interleaved_to_twochannel_gui_OutputFcn(hObject, eventdata, handles) 
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
station_code = get(handles.edit_station_code, 'String');
if ~(length(station_code) == 2 && all(isstrprop(station_code, 'upper')))
	error('Station code (''%s'') should be two uppercase letters', station_code);
end

if get(handles.checkbox_ns_only, 'Value')
	num_channels = 1;
else
	num_channels = 2;
end

[filename, pathname] = uigetfile(fullfile(get(handles.edit_source, 'String'), '*.mat'), ...
	'Select interleaved files to convert', 'MultiSelect', 'on');
if ~iscell(filename)
	filename = {filename};
end

if ischar(pathname)
	disp(sprintf('Writing to %s', destin_path));
	t_start = now;
	for kk = 1:length(filename)
		new_filenames = convert_interleaved_to_twochannel(fullfile(pathname, filename{kk}), ...
			destin_path, station_code, num_channels);
		for ll = 1:length(new_filenames)
			[pathstr, name, ext] = fileparts(new_filenames{ll});
			disp(sprintf('Wrote %s', [name ext]));
		end
	end
	t_end = now;
	total_time = (t_end - t_start)*1440; % Minutes
	disp(sprintf('Finished conversion in %d minutes, %0.0f seconds', ...
		floor(total_time), fpart(total_time)*60));
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


