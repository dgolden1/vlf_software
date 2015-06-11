function varargout = sp_emission_db_characterizer(varargin)
% SP_EMISSION_DB_CHARACTERIZER MATLAB code for sp_emission_db_characterizer.fig
%      SP_EMISSION_DB_CHARACTERIZER, by itself, creates a new SP_EMISSION_DB_CHARACTERIZER or raises the existing
%      singleton*.
%
%      H = SP_EMISSION_DB_CHARACTERIZER returns the handle to a new SP_EMISSION_DB_CHARACTERIZER or the handle to
%      the existing singleton*.
%
%      SP_EMISSION_DB_CHARACTERIZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SP_EMISSION_DB_CHARACTERIZER.M with the given input arguments.
%
%      SP_EMISSION_DB_CHARACTERIZER('Property','Value',...) creates a new SP_EMISSION_DB_CHARACTERIZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sp_emission_db_characterizer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sp_emission_db_characterizer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sp_emission_db_characterizer

% Last Modified by GUIDE v2.5 02-May-2011 16:20:36
% $Id$

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sp_emission_db_characterizer_OpeningFcn, ...
                   'gui_OutputFcn',  @sp_emission_db_characterizer_OutputFcn, ...
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


% --- Executes just before sp_emission_db_characterizer is made visible.
function sp_emission_db_characterizer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sp_emission_db_characterizer (see VARARGIN)

% Choose default command line output for sp_emission_db_characterizer
handles.output = hObject;

% Set defaults
[database_filename, cleaned_data_directory, spec_dir, yyyymmdd] = sp_emission_db_characterizer_defaults;
set(handles.edit_db_filename, 'string', database_filename);
set(handles.edit_cleaned_data_dir, 'string', cleaned_data_directory);
set(handles.edit_spec_dir, 'string', spec_dir);
set(handles.edit_yyyymmdd, 'string', yyyymmdd);

% Save user-data in the handles
handles.UD.events = [];
handles.UD.fig_h = [];
handles.UD.spec_h = [];
handles.UD.spec_datenum = [];
handles.UD.files = struct([]);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sp_emission_db_characterizer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = sp_emission_db_characterizer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_db_filename_Callback(hObject, eventdata, handles)
% hObject    handle to edit_db_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_db_filename as text
%        str2double(get(hObject,'String')) returns contents of edit_db_filename as a double


% --- Executes during object creation, after setting all properties.
function edit_db_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_db_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_cleaned_data_dir_Callback(hObject, eventdata, handles)
% hObject    handle to edit_cleaned_data_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_cleaned_data_dir as text
%        str2double(get(hObject,'String')) returns contents of edit_cleaned_data_dir as a double


% --- Executes during object creation, after setting all properties.
function edit_cleaned_data_dir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_cleaned_data_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_load_db.
function handles = pushbutton_load_db_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_db (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

db_filename = get(handles.edit_db_filename, 'string');
if exist(db_filename, 'file')
  load(db_filename, 'db_chorus', 'db_hiss');
  handles.db_chorus = db_chorus;
  handles.db_hiss = db_hiss;
  
  fprintf('Loaded %s\n', db_filename);
else
  warning('Database file %s does not exist; creating new database in memory', ...
    db_filename);
  handles.db_chorus = containers.Map('KeyType', 'double', 'ValueType', 'any');
  handles.db_hiss = containers.Map('KeyType', 'double', 'ValueType', 'any');
end

set(handles.text_warning, 'string', '');

% --- Executes on button press in pushbutton_save_db.
function pushbutton_save_db_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save_db (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

db_filename = get(handles.edit_db_filename, 'string');
db_chorus = handles.db_chorus;
db_hiss = handles.db_hiss;
save(db_filename, 'db_chorus', 'db_hiss');

set(handles.text_warning, 'string', '');


function edit_stats_Callback(hObject, eventdata, handles)
% hObject    handle to edit_stats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_stats as text
%        str2double(get(hObject,'String')) returns contents of edit_stats as a double


% --- Executes during object creation, after setting all properties.
function edit_stats_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_stats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_chorus_bounds.
function pushbutton_chorus_bounds_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_chorus_bounds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.checkbox_chorus, 'value') == 0
  set(handles.checkbox_chorus, 'value', 1);
end

try
  f = select_freq_by_click('chorus');
catch er
  if strcmp(er.identifier, 'click:OutOfBounds')
    return;
  else
    rethrow(er);
  end
end
  
set_em_bounds(handles, 'chorus', f);
plot_emission_extents('chorus', f);

start_datenum = get_start_datenum(handles);
handles.db_chorus = add_event_to_db(handles, start_datenum, handles.db_chorus, f);

% Update handles structure
guidata(hObject, handles);

% Continuously go to the next file and select the same emission until we
% run out of files or the user clicks an invalid area of the spectrogram
if get(handles.listbox_files, 'value') == length(get(handles.listbox_files, 'string'))
  return;
end
try
  pushbutton_next_Callback(handles.pushbutton_next, eventdata, handles);
  pushbutton_chorus_bounds_Callback(hObject, eventdata, handles)
catch er
  switch er.identifier
    case {'click:OutOfBounds', 'NextFile:NoMoreFiles'}
      return
    otherwise
      rethrow(er);
  end
end



% --- Executes on button press in pushbutton_hiss_bounds.
function pushbutton_hiss_bounds_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_hiss_bounds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.checkbox_hiss, 'value') == 0
  set(handles.checkbox_hiss, 'value', 1);
end

try
  f = select_freq_by_click('hiss');
catch er
  if strcmp(er.identifier, 'click:OutOfBounds')
    return;
  else
    rethrow(er);
  end
end

set_em_bounds(handles, 'hiss', f);
plot_emission_extents('hiss', f);

start_datenum = get_start_datenum(handles);
handles.db_hiss = add_event_to_db(handles, start_datenum, handles.db_hiss, f);

% Update handles structure
guidata(hObject, handles);

% Continuously go to the next file and select the same emission until we
% run out of files or the user clicks an invalid area of the spectrogram
if get(handles.listbox_files, 'value') == length(get(handles.listbox_files, 'string'))
  return;
end
try
  pushbutton_next_Callback(handles.pushbutton_next, eventdata, handles);
  pushbutton_hiss_bounds_Callback(hObject, eventdata, handles)
catch er
  switch er.identifier
    case {'click:OutOfBounds', 'NextFile:NoMoreFiles'}
      return
    otherwise
      rethrow(er);
  end
end


function edit_current_char_Callback(hObject, eventdata, handles)
% hObject    handle to edit_current_char (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_current_char as text
%        str2double(get(hObject,'String')) returns contents of edit_current_char as a double


% --- Executes during object creation, after setting all properties.
function edit_current_char_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_current_char (see GCBO)
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

if get(hObject, 'value')
  try
    pushbutton_chorus_bounds_Callback(handles.pushbutton_chorus_bounds, eventdata, handles);
  catch er
    if strcmp(er.identifier, 'click:OutOfBounds')
      fprintf('Warning: ignored out-of-bounds click\n');
      set(hObject, 'value', 0);
      return;
    else
      rethrow(er);
    end
  end
else
  remove_emission(handles, 'chorus');
  
  % Update handles structure
  guidata(hObject, handles);
end

% --- Executes on button press in checkbox_hiss.
function checkbox_hiss_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_hiss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_hiss

if get(hObject, 'value')
  try
    pushbutton_hiss_bounds_Callback(handles.pushbutton_hiss_bounds, eventdata, handles);
  catch er
    if strcmp(er.identifier, 'click:OutOfBounds')
      fprintf('Warning: ignored out-of-bounds click\n');
      set(hObject, 'value', 0);
      return;
    else
      rethrow(er);
    end
  end

else
  remove_emission(handles, 'hiss');
  
  % Update handles structure
  guidata(hObject, handles);
end


% --- Executes on button press in pushbutton_plot.
function pushbutton_plot_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Plot this data
filenum = get(handles.listbox_files, 'value');
set(handles.edit_data_filename, 'string', handles.UD.files(filenum).filename);
plot_data_log(get(handles.edit_spec_dir, 'string'), handles.UD.files(filenum).filename, handles.UD.files(filenum).start_datenum, handles);

% Load event db if necessary
if ~isfield(handles, 'db_chorus')
  handles = pushbutton_load_db_Callback(handles.pushbutton_load_db, eventdata, handles);

  % Update handles structure
  guidata(hObject, handles);
end

% Display and plot chorus and hiss extents if they're in the database
start_datenum = get_start_datenum(handles);
try
  chorus_f_lim = get_event_from_db(handles.db_chorus, start_datenum);
catch er
  if ~strcmp(er.identifier, 'MATLAB:Containers:Map:NoKey') % This date not in db
    rethrow(er);
  end
  chorus_f_lim = [];
end

try
  hiss_f_lim = get_event_from_db(handles.db_hiss, start_datenum);
catch er
  if ~strcmp(er.identifier, 'MATLAB:Containers:Map:NoKey') % This date not in db
    rethrow(er);
  end
  hiss_f_lim = [];
end

set_em_bounds(handles, 'chorus', chorus_f_lim);
plot_emission_extents('chorus', chorus_f_lim);
set_em_bounds(handles, 'hiss', hiss_f_lim);
plot_emission_extents('hiss', hiss_f_lim);

% --- Executes on button press in pushbutton_next.
function pushbutton_next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

current_filenum = get(handles.listbox_files, 'value');
if current_filenum == length(get(handles.listbox_files, 'string'))
  uiwait(warndlg('Already at last file'));
  return;
%   error('NextFile:NoMoreFiles', 'Already at last file');
end
set(handles.listbox_files, 'value', current_filenum + 1);

% Update handles structure
guidata(hObject, handles);

pushbutton_plot_Callback(handles.pushbutton_plot, eventdata, handles);


function edit_yyyymmdd_Callback(hObject, eventdata, handles)
% hObject    handle to edit_yyyymmdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_yyyymmdd as text
%        str2double(get(hObject,'String')) returns contents of edit_yyyymmdd as a double


% --- Executes during object creation, after setting all properties.
function edit_yyyymmdd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_yyyymmdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_hhmm_Callback(hObject, eventdata, handles)
% hObject    handle to edit_hhmm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_hhmm as text
%        str2double(get(hObject,'String')) returns contents of edit_hhmm as a double


% --- Executes during object creation, after setting all properties.
function edit_hhmm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_hhmm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_prev.
function pushbutton_prev_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

current_filenum = get(handles.listbox_files, 'value');
if current_filenum == 1
  uiwait(warndlg('Already at first file'));
  return;
%   error('NextFile:NoMoreFiles', 'Already at first file');
end
set(handles.listbox_files, 'value', current_filenum - 1);

% Update handles structure
guidata(hObject, handles);

pushbutton_plot_Callback(handles.pushbutton_plot, eventdata, handles);

function edit_data_filename_Callback(hObject, eventdata, handles)
% hObject    handle to edit_data_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_data_filename as text
%        str2double(get(hObject,'String')) returns contents of edit_data_filename as a double


% --- Executes during object creation, after setting all properties.
function edit_data_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_data_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_files.
function listbox_files_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_files contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_files


% --- Executes during object creation, after setting all properties.
function listbox_files_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_list_dir.
function handles = pushbutton_list_dir_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_list_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Load event database
if ~isfield(handles, 'db_chorus')
  handles = pushbutton_load_db_Callback(handles.pushbutton_load_db, eventdata, handles);
end

day_datenum = datenum(get(handles.edit_yyyymmdd, 'string'), 'yyyy-mm-dd');

cleaned_data_dir = fullfile(get(handles.edit_cleaned_data_dir, 'string'), ...
                            datestr(day_datenum, 'yyyy'), ...
                            datestr(day_datenum, 'mm_dd'));

% Get list of files
if isunix
  d = [dir(fullfile(cleaned_data_dir, '*.mat')); dir(fullfile(cleaned_data_dir, '*.MAT'))];
else
  d = dir(fullfile(cleaned_data_dir, '*.mat'));
end

handles.UD.files = struct([]);
for kk = 1:length(d)
  handles.UD.files(kk).filename = fullfile(cleaned_data_dir, d(kk).name);
  handles.UD.files(kk).start_datenum = get_bb_fname_datenum(fullfile(cleaned_data_dir, d(kk).name), true);
  
  try
    chorus_f_lim{kk} = get_event_from_db(handles.db_chorus, handles.UD.files(kk).start_datenum);
  catch er
    if strcmp(er.identifier, 'MATLAB:Containers:Map:NoKey')
      chorus_f_lim{kk} = [];
    else
      rethrow(er);
    end
  end
  
  try
    hiss_f_lim{kk} = get_event_from_db(handles.db_hiss, handles.UD.files(kk).start_datenum);
  catch er
    if strcmp(er.identifier, 'MATLAB:Containers:Map:NoKey')
      hiss_f_lim{kk} = [];
    else
      rethrow(er);
    end
  end
end

% Populate file list in GUI
file_list_str = {};
for kk = 1:length(handles.UD.files)
  chorus_hiss_str = '  ';
  if ~isempty(chorus_f_lim{kk}), chorus_hiss_str(1) = 'C'; end
  if ~isempty(hiss_f_lim{kk}), chorus_hiss_str(2) = 'H'; end
    
  file_list_str{kk} = sprintf('%03d %s %s %s\n', kk, ...
                              datestr(handles.UD.files(kk).start_datenum, 'HH:MM:SS'), ...
                              chorus_hiss_str, ...
                              just_filename(handles.UD.files(kk).filename));
end
if isempty(file_list_str)
  set(handles.listbox_files, 'string', '', 'Value', 1);
  error('No files found in %s', cleaned_data_dir);
end


set(handles.listbox_files, 'string', file_list_str, 'Value', 1);

% Update handles structure
guidata(hObject, handles);

function plot_data(full_filename, start_datenum, events)

addpath(fullfile(danmatlabroot, 'vlf', 'chorus_hiss_coherence')); % for get_data_specs

if ishandle(1) && ~strcmp(get(1, 'tag'), 'sp_char_fig')
  close(1);
end
sfigure(1);
if ~strcmp(get(1, 'tag'), 'sp_char_fig')
  figure_grow(gcf, 1.7, 1);
  set(gcf, 'tag', 'sp_char_fig');
else
  clf;
end

fs = 1e5;
data_uncal = matGetVariable(full_filename, 'data');
sitename = 'southpole';
[t, f, spec, ~, s_mediogram, ~, data_cal] = get_data_specs(data_uncal, fs, start_datenum, sitename);


% Plot spectrogram
s(1) = subplot(1, 4, 1:3);
imagesc(t, f/1e3, 10*log10(spec));
axis xy;
xlabel('Sec');
ylabel('kHz');
caxis([-30 10]);
title(sprintf('%s   %s', sitename, datestr(start_datenum, 31)));

% Plot mediogram
s(2) = subplot(1, 4, 4);
plot(s_mediogram, f/1e3, 'linewidth', 2);
grid on;
xlim([-30 0]);
xlabel('dB-uncal/Hz^{1/2}');
set(gca, 'yticklabel', []);

linkaxes(s, 'y');


function plot_data_log(spec_dir, full_filename, start_datenum, handles)

addpath(fullfile(danmatlabroot, 'vlf', 'chorus_hiss_coherence')); % for get_data_specs

if ishandle(1) && ~strcmp(get(1, 'tag'), 'sp_char_fig')
  close(1);
end
figure(1);
if ~strcmp(get(1, 'tag'), 'sp_char_fig')
  figure_grow(gcf, 1.7, 1);
  set(gcf, 'tag', 'sp_char_fig');
else
  clf;
end
set(gcf, 'KeyPressFcn', @(x1, x2) figure1_KeyPressFcn(x1, x2, handles));

fs = 1e5;
sitename = 'southpole';
nfft = 100;
window = 1024;
noverlap = window/2;

spec_filename = fullfile(spec_dir, datestr(start_datenum, 'yyyy'), datestr(start_datenum, 'mm_dd'), ...
  sprintf('SP_%s_spec.mat', datestr(start_datenum, 'yyyy_mm_dd_HHMM_SS')));
if exist(spec_filename, 'file')
  load(spec_filename);
else
%   warning('Precomputed spectrogram (%s) does not exist', spec_filename);
  error('Precomputed spectrogram (%s) does not exist', spec_filename);
  data_uncal = matGetVariable(full_filename, 'data');
  [~, f, t, p] = spectrogram(data_uncal, window, noverlap, logspace(log10(300), log10(50e3), nfft), fs);
  spec = 10*log10(p);
  s_mediogram = 10*log10(median(p, 2));
end

% Plot spectrogram
s(1) = subplot(1, 4, 1:3);
% h = pcolor(t, f, spec);
% set(h, 'linestyle', 'none');
% set(gca, 'yscale', 'log');
% ylabel('Hz');
imagesc(t, log10(f), spec);
axis xy;
ylabel('log_{10}(Hz)');
xlabel('Sec');
caxis([-30 20]);
title(sprintf('%s   %s', sitename, datestr(start_datenum, 31)));
set(s(1), 'tag', 'sp_char_spec_ax');
hold on;

% Plot mediogram
s(2) = subplot(1, 4, 4);
plot(s_mediogram, log10(f), 'linewidth', 2);
grid on;
xlim([-30 20]);
xlabel('dB-uncal/Hz^{1/2}');
set(gca, 'yticklabel', []);
set(s(2), 'tag', 'sp_char_medio_ax');
hold on;

increase_font;

linkaxes(s, 'y');

function plot_emission_extents(emission_type, f)
% Plot lines showing the boundary of chorus and hiss emissions
% chorus_f_lim and hiss_f_lim are 2x1 vectors of the lower and upper frequency
% limits, respectively
% If either is empty, it won't be plotted

switch emission_type
  case 'chorus'
    line_tag = 'sp_char_f_lim_chorus';
    line_color = [1 0.7 0.4];
  case 'hiss'
    line_tag = 'sp_char_f_lim_hiss';
    line_color = [0.8 0.7 1];
  otherwise
    error('Invalid value for emission_type: %s\n', emission_type);
end

delete(findobj('tag', line_tag));

if isempty(f)
  return;
end

axis_tags = {'sp_char_spec_ax', 'sp_char_medio_ax'};

for kk = 1:length(axis_tags)
  h_ax = findobj('tag', axis_tags{kk});
  saxes(h_ax);
  xl = xlim;
  xval = linspace(xl(1), xl(2), 3);

  h_line(1) = plot(xval, ones(length(xval), 1)*log10(f(1)), 'o--', 'linewidth', 4, 'color', line_color);
  h_line(2) = plot(xval, ones(length(xval), 1)*log10(f(2)), 'o--', 'linewidth', 4, 'color', line_color);
  set(h_line, 'tag', line_tag);
end


function f_lim = get_event_from_db(event_db, start_datenum)
% Search for an event with this start_datenum in events database
  
% Let the caller check for a missing key
s = event_db(start_datenum);
f_lim = s.f_lim;


function event_db = add_event_to_db(handles, start_datenum, event_db, f_lim)
% If an event is already in the database with this start datenum, it will
% be overwritten
% If chorus_f_lim or hiss_f_lim is [], then the current value in the
% database will be retained
% If both chorus_f_lim and hiss_f_lim is [], then this event will be
% removed from the database if it exists

if isempty(f_lim) && ~event_db.isKey(start_datenum)
  return % Do nothing
end

% Alert the user that there are unsaved changes
set(handles.text_warning, 'string', 'Warning: there are unsaved changes');

% Remove if f_lim is []
if isempty(f_lim)
  event_db = remove_event_from_db(event_db, start_datenum);
  return;
end

event_db(start_datenum) = struct('f_lim', f_lim);


function event_db = remove_event_from_db(event_db, start_datenum)

if event_db.isKey(start_datenum)
  event_db.remove(start_datenum);
end


function f = select_freq_by_click(em_type)

h_spec = findobj('tag', 'sp_char_spec_ax');
saxes(h_spec);
xl = xlim;
yl = ylim;

x = 5;
y = log10(23e3);

if strcmp(em_type, 'chorus')
  f_lc = log10(300);
else
  h_text = text(x, y, sprintf('Click %s bottom', em_type), 'Color', 'w', 'FontSize', 36, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center');
  [t_start, f_lc] = ginput(1);
  delete(h_text);
  if isempty(t_start) || t_start < xl(1) || t_start > xl(2),
    error('click:OutOfBounds', 'Outside of spectrogram clicked');
  end
end

h_text = text(x, y, sprintf('Click %s top', em_type), 'Color', 'w', 'FontSize', 36, 'FontWeight', 'bold', ...
  'HorizontalAlignment', 'center');
[t_end, f_uc] = ginput(1);
delete(h_text);
if isempty(t_end) || t_end < xl(1) || t_end > xl(2),
  error('click:OutOfBounds', 'Outside of spectrogram clicked');
end

if f_uc <= f_lc % Selected lower frequency higher than upper frequency
  error('Invalid f_lc, f_uc (%0.0f Hz, %0.0f Hz)', 10^f_lc, 10^f_uc);
end
if f_lc < yl(1) % Click below bottom of spectrogram
  f_lc = yl(1);
end
if f_uc > yl(2) % Click above top of spectrogram
  f_uc = yl(2);
end

f = 10.^([f_lc, f_uc]);


function set_em_bounds(handles, em_type_str, f)

switch em_type_str
  case 'chorus'
    obj_edit = handles.edit_chorus_freq;
    obj_checkbox = handles.checkbox_chorus;
  case 'hiss'
    obj_edit = handles.edit_hiss_freq;
    obj_checkbox = handles.checkbox_hiss;
  otherwise
    error('Weird em_type_str: %s', em_type_str);
end

if isempty(f)
  set(obj_edit, 'string', 'None');
  set(obj_checkbox, 'value', 0);
else
  set(obj_edit, 'string', sprintf('%0.2f\n%0.2f', f(1), f(2)));
  set(obj_checkbox, 'value', 1);
end


function edit_chorus_freq_Callback(hObject, eventdata, handles)
% hObject    handle to edit_chorus_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_chorus_freq as text
%        str2double(get(hObject,'String')) returns contents of edit_chorus_freq as a double


% --- Executes during object creation, after setting all properties.
function edit_chorus_freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_chorus_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_hiss_freq_Callback(hObject, eventdata, handles)
% hObject    handle to edit_hiss_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_hiss_freq as text
%        str2double(get(hObject,'String')) returns contents of edit_hiss_freq as a double


% --- Executes during object creation, after setting all properties.
function edit_hiss_freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_hiss_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function start_datenum = get_start_datenum(handles)
% Get start datenum for current file

filename = get(handles.edit_data_filename, 'string');
start_datenum = get_bb_fname_datenum(filename, true);



function edit_spec_dir_Callback(hObject, eventdata, handles)
% hObject    handle to edit_spec_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_spec_dir as text
%        str2double(get(hObject,'String')) returns contents of edit_spec_dir as a double


% --- Executes during object creation, after setting all properties.
function edit_spec_dir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_spec_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

switch eventdata.Key
  case 'leftarrow'
    if length(eventdata.Modifier) == 1 && strcmp(eventdata.Modifier, 'control')
      pushbutton_prev_date_Callback(handles.pushbutton_prev_date, eventdata, handles);
    else
      pushbutton_prev_Callback(handles.pushbutton_prev, eventdata, handles);
    end
  case 'rightarrow'
    if length(eventdata.Modifier) == 1 && strcmp(eventdata.Modifier, 'control')
      pushbutton_next_date_Callback(handles.pushbutton_next_date, eventdata, handles);
    else
      pushbutton_next_Callback(handles.pushbutton_next, eventdata, handles);
    end
  case 'q'
    pushbutton_chorus_bounds_Callback(handles.pushbutton_chorus_bounds, eventdata, handles)
  case 'w'
    pushbutton_hiss_bounds_Callback(handles.pushbutton_hiss_bounds, eventdata, handles);
  case 'n'
    pushbutton_no_em_Callback(handles.pushbutton_no_em, eventdata, handles);
  case 'home'
    set(handles.listbox_files, 'value', 1);
    pushbutton_plot_Callback(handles.pushbutton_plot, eventdata, handles);
  case 'end'
    set(handles.listbox_files, 'value', length(get(handles.listbox_files, 'string')));
    pushbutton_plot_Callback(handles.pushbutton_plot, eventdata, handles);
  case 's'
    pushbutton_save_db_Callback(handles.pushbutton_save_db, eventdata, handles);
end


% --- Executes on button press in pushbutton_no_em.
function pushbutton_no_em_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_no_em (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = remove_emission(handles, 'chorus');
handles = remove_emission(handles, 'hiss');

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton_next_date.
function pushbutton_next_date_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_next_date (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

this_date = datenum(get(handles.edit_yyyymmdd, 'string'), 'yyyy-mm-dd');
set(handles.edit_yyyymmdd, 'string', datestr(this_date + 1, 'yyyy-mm-dd'));
handles = pushbutton_list_dir_Callback(handles.pushbutton_list_dir, eventdata, handles);
pushbutton_plot_Callback(handles.pushbutton_plot, eventdata, handles);


% --- Executes on button press in pushbutton_prev_date.
function pushbutton_prev_date_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_prev_date (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

this_date = datenum(get(handles.edit_yyyymmdd, 'string'), 'yyyy-mm-dd');
set(handles.edit_yyyymmdd, 'string', datestr(this_date - 1, 'yyyy-mm-dd'));
handles = pushbutton_list_dir_Callback(handles.pushbutton_list_dir, eventdata, handles);
pushbutton_plot_Callback(handles.pushbutton_plot, eventdata, handles);

function handles = remove_emission(handles, em_type)
% Remove an emission on the current epoch by un-plotting it and removing it
% from the database
set_em_bounds(handles, em_type, []);
plot_emission_extents(em_type, []);

start_datenum = get_start_datenum(handles);

switch em_type
  case 'chorus'
    handles.db_chorus = add_event_to_db(handles, start_datenum, handles.db_chorus, []);
  case 'hiss'
    handles.db_hiss = add_event_to_db(handles, start_datenum, handles.db_hiss, []);
  otherwise
    error('Weird emission type: %s', em_type);
end
