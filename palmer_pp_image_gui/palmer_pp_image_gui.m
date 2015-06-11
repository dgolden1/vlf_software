function varargout = palmer_pp_image_gui(varargin)
% PALMER_PP_IMAGE_GUI M-file for palmer_pp_image_gui.fig
%      PALMER_PP_IMAGE_GUI, by itself, creates a new PALMER_PP_IMAGE_GUI or raises the existing
%      singleton*.
%
%      H = PALMER_PP_IMAGE_GUI returns the handle to a new PALMER_PP_IMAGE_GUI or the handle to
%      the existing singleton*.
%
%      PALMER_PP_IMAGE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PALMER_PP_IMAGE_GUI.M with the given input arguments.
%
%      PALMER_PP_IMAGE_GUI('Property','Value',...) creates a new PALMER_PP_IMAGE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before palmer_pp_image_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to palmer_pp_image_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help palmer_pp_image_gui

% Last Modified by GUIDE v2.5 22-Jan-2010 17:44:42

% By Daniel Golden (dgolden1 at stanford dot edu) May 2008
% $Id$

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @palmer_pp_image_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @palmer_pp_image_gui_OutputFcn, ...
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


% --- Executes just before palmer_pp_image_gui is made visible.
function palmer_pp_image_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to palmer_pp_image_gui (see VARARGIN)

% Choose default command line output for palmer_pp_image_gui
handles.output = hObject;

% Add userdata to handles
handles.UD = struct;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes palmer_pp_image_gui wait for user response (see UIRESUME)
% uiwait(handles.figure2);



% --- Outputs from this function are returned to the command line.
function varargout = palmer_pp_image_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_load_fits.
function pushbutton_load_fits_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_fits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles.UD, 'palmer_pp_db')
	handles = pushbutton_load_db_Callback(handles.pushbutton_load_db, eventdata, handles);
end

if ~exist('plot_fits', 'file')
	addpath(fullfile(danmatlabroot, 'vlf', 'image_euv'));
end

fits_filename = get(handles.edit_fits_filename, 'String');
pathstr = fileparts(fits_filename);

fits_filelist_dir = dir(fullfile(pathstr, '*_xform.fits'));
fits_file_list = {fits_filelist_dir.name};

% Stuff the path name into each file name
fits_file_list = cellfun(@(x) fullfile(pathstr, x), fits_file_list, 'UniformOutput', false);

fits_file_index = strmatch(fits_filename, fits_file_list, 'exact');

% Update UserData with file list and index
handles.UD.fits_file_list = fits_file_list;
handles.UD.fits_file_index = fits_file_index;
guidata(hObject, handles);

db_filename = get(handles.edit_db, 'String');

b_plot_color = get(handles.checkbox_color_plot, 'Value');
b_plot_contour = get(handles.checkbox_contour_plot, 'Value');
b_plot_l_lines = get(handles.checkbox_l_lines, 'Value');

% Plot this fits file
plot_fits(fits_filename, 6, [], handles.img_ax, handles.UD.palmer_pp_db, b_plot_color, b_plot_contour, b_plot_l_lines);

% Plot plasmapause density
if get(handles.checkbox_show_density, 'Value') == 1
	plot_pp_density(fits_filename, db_filename, handles)
end

% Update "Image n of m" dialog
set(handles.edit_image_num, 'String', ...
	sprintf('%d of %d', handles.UD.fits_file_index, length(handles.UD.fits_file_list)));

% Update next fits slider
set(handles.slider_next_img, 'Value', handles.UD.fits_file_index, ...
	'Min', 1, 'Max', length(handles.UD.fits_file_list), ...
	'SliderStep', [1 10]/(length(handles.UD.fits_file_list) - 1));

% Update the "palmer plasmapause" dialog; if there's no entry in the
% database, make it blank
try
	img_datenum = get_img_datenum(fits_filename);
	L = get_from_palmer_pp_db(handles.UD.palmer_pp_db, img_datenum);
	if isnan(L)
		set(handles.edit_l_value, 'String', '<invalid>');
		set(handles.edit_l_value, 'BackgroundColor', [1 0.4 0.4]);
	elseif isinf(L)
		set(handles.edit_l_value, 'String', '<indet>');
		set(handles.edit_l_value, 'BackgroundColor', [0.9 0.9 0.4]);
	else
		set(handles.edit_l_value, 'String', num2str(L, '%0.1f'));
		set(handles.edit_l_value, 'BackgroundColor', 'w');
	end
catch er
	if ~strcmp(er.identifier, 'get_from_palmer_pp_db:NotFound'), rethrow(er); end
	set(handles.edit_l_value, 'String', '');
	set(handles.edit_l_value, 'BackgroundColor', 'w');
end

% Update handles structure
guidata(hObject, handles);

function edit_fits_filename_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fits_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fits_filename as text
%        str2double(get(hObject,'String')) returns contents of edit_fits_filename as a double


% --- Executes during object creation, after setting all properties.
function edit_fits_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fits_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function go_to_next_file(hObject, eventdata, handles, next_file_rel)
% Function to load the next file
% if next_file_rel > 0, go to later file
% if next_file_rel < 0, go to earlier file

if ~isfield(handles.UD, 'fits_file_list')
	error('Load a FITS file first');
end

if ~exist('next_file_rel', 'var') || isempty(next_file_rel)
	next_file_rel = 0;
end

% If we're in pessimistic mode, mark this image as invalid
if get(handles.checkbox_pessimistic_mode, 'Value') == 1
	handles = pushbutton_mark_invalid_Callback(handles.pushbutton_mark_invalid, eventdata, handles);
% If we're in indeterminate mode, mark this image as not having a visible
% plasmapause
elseif get(handles.checkbox_indeterminate, 'Value') == 1
	handles = pushbutton_mark_indet_Callback(handles.pushbutton_mark_indet, eventdata, handles);
end

if next_file_rel > 0
	if handles.UD.fits_file_index + next_file_rel <= length(handles.UD.fits_file_list)
		handles.UD.fits_file_index = handles.UD.fits_file_index + next_file_rel;
		set(handles.edit_fits_filename, 'String', handles.UD.fits_file_list{handles.UD.fits_file_index});
		pushbutton_load_fits_Callback(handles.pushbutton_load_fits, eventdata, handles);

		guidata(hObject, handles);

		% If we're in speedy mode, immediately get plasmapause and move on to
		% the next image
		if get(handles.checkbox_speedy_mode, 'Value') == 1
			handles = pushbutton_sel_pp_top_Callback(handles.pushbutton_sel_pp_top, eventdata, handles);
			go_to_next_file(hObject, eventdata, handles, 1);
		elseif get(handles.checkbox_speedy_mode2, 'Value') == 1
			handles = pushbutton_sel_pp_top2_Callback(handles.pushbutton_sel_pp_top, eventdata, handles);
			go_to_next_file(hObject, eventdata, handles, 1);
		elseif get(handles.checkbox_speedy_bottom, 'Value') == 1
			handles = pushbutton_sel_pp_bottom_Callback(handles.pushbutton_sel_pp_top, eventdata, handles);
			go_to_next_file(hObject, eventdata, handles, 1);
		end
	else
		disp('At end of file list');
	end
elseif next_file_rel < 0
	if handles.UD.fits_file_index + next_file_rel >= 1
		handles.UD.fits_file_index = handles.UD.fits_file_index + next_file_rel;
		set(handles.edit_fits_filename, 'String', handles.UD.fits_file_list{handles.UD.fits_file_index});
		pushbutton_load_fits_Callback(handles.pushbutton_load_fits, eventdata, handles);

		guidata(hObject, handles);
	else
		disp('At beginning of file list');
	end
end


% Update handles structure
guidata(hObject, handles);



% --- Executes on slider movement.
function slider_next_img_Callback(hObject, eventdata, handles)
% hObject    handle to slider_next_img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

UD = handles.UD;
if ~isfield(UD, 'fits_file_list')
	error('Load a FITS file first');
end

slide_value = round(get(hObject, 'Value'));
go_to_next_file(hObject, eventdata, handles, slide_value - UD.fits_file_index);


function edit_fig_title_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fig_title (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fig_title as text
%        str2double(get(hObject,'String')) returns contents of edit_fig_title as a double


% --- Executes during object creation, after setting all properties.
function edit_fig_title_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fig_title (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_sel_pp_top.
function varargout = pushbutton_sel_pp_top_Callback(hObject, eventdata, handles, str_pp_L)
% hObject    handle to pushbutton_sel_pp_top (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If str_pp_L is 'pp_L', L is saved to pp_L field
% If str_pp_L is 'pp_L2', L gathered and saved to both pp_L and pp_L2
% fields
% pp_L2 is used when there are two "plasmapauses" at Palmer's longitude.
% This only happens when there's a plume.

if ~exist('str_pp_L', 'var') || isempty(str_pp_L)
	str_pp_L = 'pp_L';
end

if strcmp(str_pp_L, 'pp_L')
	num_L = 1;
elseif strcmp(str_pp_L, 'pp_L2')
	num_L = 2;
end

axes(handles.img_ax);

for kk = 1:num_L
	[x, y] = ginput(1);
	L(kk) = sqrt(x^2+y^2);

	% y > 6 is equivalent to infinity (i.e., outside the bounds of the image)
	if y > 6
		L(kk) = inf;
	% L < 1.2 or anywhere else outside the image is invalid
	elseif L(kk) < 1.2 || y < -6 || abs(x) > 6
		error('SelPPTop:InvalidClick', 'Invalid area clicked');
	end
end

% If we didn't pick L2, then L2 = L1; also, outer plasmapause can't be
% within inner plasmapause
if length(L) == 1 || length(L) == 2 && L(2) < L(1)
	L(2) = L(1);
end

if L(1) == L(2)
	set(handles.edit_l_value, 'String', sprintf('%0.1f', L(1)));
else
	set(handles.edit_l_value, 'String', sprintf('%0.1f, %0.1f', L(1), L(2)));
end

db_filename = get(handles.edit_db, 'String');
img_datenum = get_img_datenum(get(handles.edit_fits_filename, 'String'));

handles.UD.palmer_pp_db = add_to_palmer_pp_db(handles.UD.palmer_pp_db, L(1), L(2), img_datenum, handles.text_db_warning);

% Mark plasmapause location on 2-d plot
mark_pp_on_fits(handles.UD.palmer_pp_db, img_datenum);

% Reload 1-d plot
if get(handles.checkbox_show_density, 'Value') == 1
	fits_filename = get(handles.edit_fits_filename, 'string');
	plot_pp_density(fits_filename, db_filename, handles);
end

% Update handles structure
guidata(hObject, handles);

if nargout > 0
	varargout{1} = handles;
end

% --- Executes on button press in pushbutton_mark_invalid.
function varargout = pushbutton_mark_invalid_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_mark_invalid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.edit_l_value, 'String', '<invalid>');
set(handles.edit_l_value, 'BackgroundColor', [1 0.4 0.4]);


img_datenum = get_img_datenum(get(handles.edit_fits_filename, 'String'));

handles.UD.palmer_pp_db = add_to_palmer_pp_db(handles.UD.palmer_pp_db, NaN, [], img_datenum, handles.text_db_warning);

% Update handles structure
guidata(hObject, handles);

if nargout > 0
	varargout{1} = handles;
end

function edit_l_value_Callback(hObject, eventdata, handles)
% hObject    handle to edit_l_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_l_value as text
%        str2double(get(hObject,'String')) returns contents of edit_l_value as a double


% --- Executes during object creation, after setting all properties.
function edit_l_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_l_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_browse.
function pushbutton_browse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('*_xform.fits', 'Select transformed FITS file', get(handles.edit_fits_filename, 'String'));
if ~ischar(filename), return; end
set(handles.edit_fits_filename, 'String', fullfile(pathname, filename));

pushbutton_load_fits_Callback(handles.pushbutton_load_fits, eventdata, handles);



function edit_image_num_Callback(hObject, eventdata, handles)
% hObject    handle to edit_image_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_image_num as text
%        str2double(get(hObject,'String')) returns contents of edit_image_num as a double


% --- Executes during object creation, after setting all properties.
function edit_image_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_image_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_db_Callback(hObject, eventdata, handles)
% hObject    handle to edit_db (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_db as text
%        str2double(get(hObject,'String')) returns contents of edit_db as a double


% --- Executes during object creation, after setting all properties.
function edit_db_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_db (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_speedy_mode.
function checkbox_speedy_mode_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_speedy_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_speedy_mode

if get(hObject, 'Value') == 1
	uncheck_except(hObject, handles);
	
	try
		handles = pushbutton_sel_pp_top_Callback(handles.pushbutton_sel_pp_top, eventdata, handles);
		go_to_next_file(hObject, eventdata, handles, 1);
	catch er
		if strcmp(er.identifier, 'SelPPTop:InvalidClick')
			disp('Ended speedy mode with invalid click');
			set(hObject, 'Value', 0);
			return;
		else
			rethrow(er);
		end
	end
end

% --- Executes on button press in checkbox_speedy_mode2.
function checkbox_speedy_mode2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_speedy_mode2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_speedy_mode2

if get(hObject, 'Value') == 1
	uncheck_except(hObject, handles);
	
	try
		pushbutton_sel_pp_top2_Callback(handles.pushbutton_sel_pp_top, eventdata, handles);
		go_to_next_file(hObject, eventdata, handles, 1);
	catch er
		if strcmp(er.identifier, 'SelPPTop:InvalidClick')
			disp('Ended speedy mode with invalid click');
			set(hObject, 'Value', 0);
			return;
		else
			rethrow(er);
		end
	end
end

% --- Executes on button press in checkbox_pessimistic_mode.
function checkbox_pessimistic_mode_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_pessimistic_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_pessimistic_mode

if get(hObject, 'Value') == 1
	uncheck_except(hObject, handles)
end


% --- Executes on button press in pushbutton_sel_pp_bottom.
function pushbutton_sel_pp_bottom_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sel_pp_bottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes_density_1d);
[x, y] = ginput(1);
L = x;

% L > 6 is invalid
if L > 6 || L < 1
	error('Invalid plasmapause location');
end

set(handles.edit_l_value, 'String', num2str(L, '%0.1f'));

db_filename = get(handles.edit_db, 'String');
img_datenum = get_img_datenum(get(handles.edit_fits_filename, 'String'));

handles.UD.palmer_pp_db = add_to_palmer_pp_db(handles.UD.palmer_pp_db, L, [], img_datenum, handles.text_db_warning);

% % Reload the image to show the plasmapause
% pushbutton_load_fits_Callback(handles.pushbutton_load_fits, eventdata, handles);

% Mark plasmapause location on 2-d plot
mark_pp_on_fits(handles.UD.palmer_pp_db, img_datenum);

% Reload 1-d plot
if get(handles.checkbox_show_density, 'Value') == 1
	fits_filename = get(handles.edit_fits_filename, 'string');
	plot_pp_density(fits_filename, db_filename, handles)
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in checkbox_show_density.
function checkbox_show_density_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_show_density (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_show_density


% --- Executes on button press in pushbutton_mark_indet.
function varargout = pushbutton_mark_indet_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_mark_indet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.edit_l_value, 'String', '<indet>');
set(handles.edit_l_value, 'BackgroundColor', [0.9 0.9 0.4]);

img_datenum = get_img_datenum(get(handles.edit_fits_filename, 'String'));

handles.UD.palmer_pp_db = add_to_palmer_pp_db(handles.UD.palmer_pp_db, Inf, [], img_datenum, handles.text_db_warning);

% Update handles structure
guidata(hObject, handles);

if nargout > 0
	varargout{1} = handles;
end


% --- Executes on button press in checkbox_indeterminate.
function checkbox_indeterminate_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_indeterminate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_indeterminate

if get(hObject, 'Value') == 1
	uncheck_except(hObject, handles);
end


% --- Executes on button press in checkbox_speedy_bottom.
function checkbox_speedy_bottom_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_speedy_bottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_speedy_bottom

if get(hObject, 'Value') == 1
	uncheck_except(hObject, handles);
end



% --- Executes during object creation, after setting all properties.
function slider_next_img_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_next_img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkbox_color_plot.
function checkbox_color_plot_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_color_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_color_plot


% --- Executes on button press in checkbox_contour_plot.
function checkbox_contour_plot_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_contour_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_contour_plot


% --- Executes on button press in pushbutton_next_dir.
function pushbutton_next_dir_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_next_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Two levels down - should be directory ../../yyyy-mm-dd/
this_fits_dir = fileparts(fileparts(get(handles.edit_fits_filename, 'string')));
[fits_dir, this_fits_dir_name] = fileparts(this_fits_dir);

d = dir(fullfile(fits_dir, '*-*-*')); % The other data directories
this_fits_dir_num = find(~cellfun(@isempty, strfind({d.name}, this_fits_dir_name)));

if this_fits_dir_num == length(d)
	error('No more directories after %s', this_fits_dir);
end

next_fits_dir = fullfile(fits_dir, d(this_fits_dir_num + 1).name, 'eqmapped');

d = dir(fullfile(next_fits_dir, '*_xform.fits'));

if isempty(d)
	error('No .fits files found in %s', next_fits_dir);
end

next_fits_filename = fullfile(next_fits_dir, d(1).name);

set(handles.edit_fits_filename, 'string', next_fits_filename);

% Load
pushbutton_load_fits_Callback(handles.pushbutton_load_fits, eventdata, handles);


% --- Executes on button press in checkbox_l_lines.
function checkbox_l_lines_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_l_lines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_l_lines


% --- Executes on button press in pushbutton_sel_pp_top2.
function varargout = pushbutton_sel_pp_top2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sel_pp_top2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = pushbutton_sel_pp_top_Callback(handles.pushbutton_sel_pp_top, eventdata, handles, 'pp_L2');

if nargout > 0
	varargout{1} = handles;
end

function uncheck_except(hObject, handles)
% Uncheck all checkboxes except hObject

if ~strcmp(get(hObject, 'tag'), 'checkbox_speedy_mode')
	set(handles.checkbox_speedy_mode, 'Value', 0);
end
if ~strcmp(get(hObject, 'tag'), 'checkbox_speedy_mode2')
	set(handles.checkbox_speedy_mode2, 'Value', 0);
end
if ~strcmp(get(hObject, 'tag'), 'checkbox_speedy_bottom')
	set(handles.checkbox_speedy_bottom, 'Value', 0);
end
if ~strcmp(get(hObject, 'tag'), 'checkbox_pessimistic_mode')
	set(handles.checkbox_pessimistic_mode, 'Value', 0);
end
if ~strcmp(get(hObject, 'tag'), 'checkbox_indeterminate')
	set(handles.checkbox_indeterminate, 'Value', 0);
end


% --- Executes on button press in pushbutton_load_db.
function varargout = pushbutton_load_db_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_db (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

palmer_pp_db_filename = get(handles.edit_db, 'String');
palmer_pp_db = load(palmer_pp_db_filename);

handles.UD.palmer_pp_db = palmer_pp_db.palmer_pp_db;

% Remove any db warnings
set(handles.text_db_warning, 'String', '');

% Update handles structure
guidata(hObject, handles);

if nargout > 0
	varargout{1} = handles;
end

disp(sprintf('Loaded %d epochs from %s', length(handles.UD.palmer_pp_db), palmer_pp_db_filename));

% --- Executes on button press in pushbutton_save_db.
function pushbutton_save_db_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save_db (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

palmer_pp_db_filename = get(handles.edit_db, 'String');
palmer_pp_db = handles.UD.palmer_pp_db;

save(palmer_pp_db_filename, 'palmer_pp_db');

% Remove any db warnings
set(handles.text_db_warning, 'String', '');

disp(sprintf('Saved %d epochs to %s', length(palmer_pp_db), palmer_pp_db_filename));
