function varargout = emission_db_characterizer(varargin)
% EMISSION_DB_CHARACTERIZER M-file for emission_db_characterizer.fig
%      EMISSION_DB_CHARACTERIZER, by itself, creates a new EMISSION_DB_CHARACTERIZER or raises the existing
%      singleton*.
%
%      H = EMISSION_DB_CHARACTERIZER returns the handle to a new EMISSION_DB_CHARACTERIZER or the handle to
%      the existing singleton*.
%
%      EMISSION_DB_CHARACTERIZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EMISSION_DB_CHARACTERIZER.M with the given input arguments.
%
%      EMISSION_DB_CHARACTERIZER('Property','Value',...) creates a new EMISSION_DB_CHARACTERIZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before emission_db_characterizer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to emission_db_characterizer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help emission_db_characterizer

% Last Modified by GUIDE v2.5 18-Sep-2010 15:59:20
% By Daniel Golden (dgolden1 at stanford dot edu) November 2009
% $Id$

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @emission_db_characterizer_OpeningFcn, ...
                   'gui_OutputFcn',  @emission_db_characterizer_OutputFcn, ...
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


% --- Executes just before emission_db_characterizer is made visible.
function emission_db_characterizer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to emission_db_characterizer (see VARARGIN)

% Choose default command line output for emission_db_characterizer
handles.output = hObject;

% UIWAIT makes emission_db_characterizer wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Add empty emissions struct

% Set defaults
[database_filename, cleaned_data_directory, initial_index] = emission_db_characterizer_defaults;
set(handles.edit_db_filename, 'string', database_filename);
set(handles.edit_cleaned_data_dir, 'string', cleaned_data_directory);
set(handles.edit_index, 'string', initial_index);

% Save user-data in the handles
handles.UD.events = [];
handles.UD.fig_h = [];
handles.UD.spec_h = [];
handles.UD.spec_datenum = [];
handles.UD.syn_rect = [];

% Update handles structure
guidata(hObject, handles);

% Close open figures
if ishandle(1), close(1); end
if ishandle(2), close(2); end


% --- Outputs from this function are returned to the command line.
function varargout = emission_db_characterizer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_mmddyyyy_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mmddyyyy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mmddyyyy as text
%        str2double(get(hObject,'String')) returns contents of edit_mmddyyyy as a double


% --- Executes during object creation, after setting all properties.
function edit_mmddyyyy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mmddyyyy (see GCBO)
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

this_datenum = retrieve_datenum(handles);

% Round to the nearest synoptic minute
this_datenum = round((this_datenum - 5/1440)*96)/96 + 5/1440;

set(handles.edit_mmddyyyy, 'string', datestr(this_datenum, 'yyyy-mm-dd'));
set(handles.edit_hhmm, 'string', datestr(this_datenum, 'HHMM'));



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


% --- Executes on button press in pushbutton_go.
function pushbutton_go_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.UD.events)
    handles = pushbutton_load_db_Callback(handles.pushbutton_load_db, eventdata, handles);
end

this_event_num = str2double(get(handles.edit_index, 'String'));
this_event = handles.UD.events(this_event_num);

[data, fs] = get_data_from_event(this_event, handles);
data_length = (length(data)-1)/fs;

% Open figure
if ~isempty(handles.UD.fig_h) && ishandle(handles.UD.fig_h)
  sfigure(handles.UD.fig_h);
else
  handles.UD.fig_h = figure;
  handles.UD.spec_datenum = [];
end

% Plot spectrogram
if isempty(handles.UD.spec_datenum) || handles.UD.spec_datenum ~= this_event.start_datenum
  window = 1024;
  noverlap = 768;
  nfft = 1024;
  
  if isempty(handles.UD.spec_h) || ~ishandle(handles.UD.spec_h)
    % Create the spectrogram
    handles.UD.spec_h = spectrogram_dan(data, window, noverlap, nfft, fs);
    caxis([30 80]);
  else
    % Just change the image to save time
    [S, ~] = spectrogram_dan(data, window, noverlap, nfft, fs);
    set(handles.UD.spec_h, 'CData', db(S));
  end
  
  handles.UD.spec_datenum = this_event.start_datenum;
end

% Plot rectangle
if isfield(this_event, 'type')
  type = this_event.type;
else
  type = '';
end
delete(findall(handles.UD.fig_h, 'tag', 'event_rectangle'));
handles.UD.syn_rect = plot_rectangle_on_syn_spec(0, data_length, this_event.f_lc, this_event.f_uc, type);

set_current_type_field(handles.UD.events(this_event_num), handles);

% Update GUI information
show_emission_characteristics(this_event, handles);
set_datenum(handles, this_event.start_datenum);

% Update handles structure
guidata(hObject, handles);


function set_current_type_field(event, handles)
% Update the current emission type in the GUI

if isfield(event, 'type') && ~isempty(event.type)
  type = event.type;
else
  type = 'Unchar';
end
set(handles.edit_current_char, 'String', type);

% Color to be the same as the corresponding button
switch type
  case 'chorus'
    set(handles.edit_current_char, 'BackgroundColor', get(handles.pushbutton_chorus, 'BackgroundColor'));
  case 'hiss'
    set(handles.edit_current_char, 'BackgroundColor', get(handles.pushbutton_hiss, 'BackgroundColor'));
  case 'both'
    set(handles.edit_current_char, 'BackgroundColor', get(handles.pushbutton_both, 'BackgroundColor'));
  case 'emission'
    set(handles.edit_current_char, 'BackgroundColor', get(handles.pushbutton_unknown, 'BackgroundColor'));
  case 'noise'
    set(handles.edit_current_char, 'BackgroundColor', get(handles.pushbutton_noise, 'BackgroundColor'));
  otherwise
    set(handles.edit_current_char, 'BackgroundColor', 'w');
end

function show_emission_characteristics(event, handles)
% Display emission's characteristics in the GUI

fields = fieldnames(event.ec);

str = [];
for kk = 1:length(fields)
  str = [str sprintf('%s: %g\n', fields{kk}, event.ec.(fields{kk}))];
end

set(handles.edit_emission_chars, 'String', str);


function [data, fs] = get_data_from_event(event, handles)
% Get the cleaned data filename from an event

cleaned_data_directory = get(handles.edit_cleaned_data_dir, 'String');
[y m d hh mm] = datevec(event.start_datenum);

filename = fullfile(cleaned_data_directory, sprintf('%04d', y), ...
  sprintf('%02d_%02d', m, d), ...
  sprintf('PA_%04d_%02d_%02dT%02d%02d_%02d_002_cleaned.mat', y, m, d, hh, mm, 5));

DF = load(filename);
data = DF.data;
fs = DF.Fs;


% --- Executes on button press in pushbutton_previous.
function pushbutton_previous_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_previous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

b_skip_noise = get(handles.checkbox_skip_noise, 'Value');

this_index = str2double(get(handles.edit_index, 'String'));

if ~b_skip_noise
  next_index = this_index - 1;
%   next_index = find(1:length(handles.UD.events) < this_index & ~strcmp({handles.UD.events.type}, 'noise') & ~strcmp({handles.UD.events.type}, 'chorus') ...
%     & (fpart([handles.UD.events.start_datenum]) < 13/24 & fpart([handles.UD.events.start_datenum]) > 7/24) ...
%     & [handles.UD.events.f_lc] < 1e3, 1, 'last');
%   disp('Skipping to previous dawn low-frequency non-chorus emission');
else
  next_index = find(1:length(handles.UD.events) < this_index & cellfun(@(x) ~strcmp('noise', x), {handles.UD.events.type}), 1, 'last');
end

if ~isempty(next_index) && next_index > 0
  set(handles.edit_index, 'String', num2str(next_index));
  pushbutton_go_Callback(handles.pushbutton_go, eventdata, handles);
else
  disp('No previous events');
end

% --- Executes on button press in pushbutton_next.
function pushbutton_next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

b_skip_noise = get(handles.checkbox_skip_noise, 'Value');

this_index = str2double(get(handles.edit_index, 'String'));

if ~b_skip_noise
  next_index = this_index + 1;
%   next_index = find(1:length(handles.UD.events) > this_index & ~strcmp({handles.UD.events.type}, 'noise') & ~strcmp({handles.UD.events.type}, 'chorus') ...
%     & (fpart([handles.UD.events.start_datenum]) < 13/24 & fpart([handles.UD.events.start_datenum]) > 7/24) ...
%     & [handles.UD.events.f_lc] < 1e3, 1, 'first');
%   disp('Skipping to next dawn low-frequency non-chorus emission');
else
  next_index = find(1:length(handles.UD.events) > this_index & cellfun(@(x) ~strcmp('noise', x), {handles.UD.events.type}), 1, 'first');
end

if ~isempty(next_index) && next_index <= length(handles.UD.events)
  set(handles.edit_index, 'String', num2str(next_index));
  pushbutton_go_Callback(handles.pushbutton_go, eventdata, handles);
else
  disp('No more events');
end



function this_datenum = retrieve_datenum(handles)
% Function to get date from yyyy-mm-dd and HHMM fields and return the
% datenum
[yy mm dd] = datevec(get(handles.edit_mmddyyyy, 'string'), 'yyyy-mm-dd');
[~, ~, ~, HH, MM] = datevec(get(handles.edit_hhmm, 'string'), 'HHMM');
this_datenum = datenum([yy mm dd HH MM 00]);


function set_datenum(handles, new_datenum)
% Function to set date from a datenum into the yyyy-mm-dd and HHMM fields.
% This function doesn't do error checking.

set(handles.edit_mmddyyyy, 'string', datestr(new_datenum, 'yyyy-mm-dd'));
set(handles.edit_hhmm, 'string', datestr(new_datenum, 'HHMM'));


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

t_start = now;

% Load emissions struct
database_filename = get(handles.edit_db_filename, 'string');
if ~exist(database_filename, 'file')
  error('Datebase file %s does not exist', database_filename);
end
db = load(database_filename);

handles.UD.events = db.events;

% Update handles structure
guidata(hObject, handles);

% Remove warning about unsaved changes
set(handles.text_messages, 'String', '');

% Update number of emissions display
set(handles.text_of, 'String', sprintf('of %d', length(db.events)));

% Update datenum
set_datenum(handles, handles.UD.events(1).start_datenum);

% Add the 'type' field if it doesn't already exist
if ~isfield(db.events, 'type')
  db.events(1).type = [];
end

% Go to index 1
set(handles.edit_index, 'String', '1');

type_cell = {db.events.type};
num_chorus = sum(cellfun(@(x) strcmp(x, 'chorus'), type_cell));
num_hiss = sum(cellfun(@(x) strcmp(x, 'hiss'), type_cell));
num_noise = sum(cellfun(@(x) strcmp(x, 'noise'), type_cell));
num_unknown = sum(cellfun(@(x) strcmp(x, 'emission'), type_cell));
num_unchar = sum(cellfun(@(x) isempty(x), type_cell));

fprintf('Loaded %s\n', database_filename);
fprintf('%d events from %s to %s, took %s\n', length(db.events), ...
  datestr(min([db.events.start_datenum]), 'yyyy-mm-dd'), datestr(max([db.events.start_datenum]), 'yyyy-mm-dd'), ...
  time_elapsed(t_start, now));
fprintf('%d chorus\n%d hiss\n%d unknown emission\n%d noise\n%d unchar\n', ...
  num_chorus, num_hiss, num_unknown, num_noise, num_unchar);


% --- Executes on button press in pushbutton_save_db.
function pushbutton_save_db_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save_db (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

t_start = now;

if isempty(handles.UD.events)
  error('Database not loaded');
end

events = handles.UD.events;

database_filename = get(handles.edit_db_filename, 'string');

save(database_filename, 'events');

% Remove warning about unsaved changes
set(handles.text_messages, 'String', '');

type_cell = {events.type};
num_chorus = sum(cellfun(@(x) strcmp(x, 'chorus'), type_cell));
num_hiss = sum(cellfun(@(x) strcmp(x, 'hiss'), type_cell));
num_noise = sum(cellfun(@(x) strcmp(x, 'noise'), type_cell));
num_unknown = sum(cellfun(@(x) strcmp(x, 'emission'), type_cell));
num_unchar = sum(cellfun(@(x) isempty(x), type_cell));

fprintf('Saved %s\n', database_filename);
fprintf('%d events from %s to %s, took %s\n', length(events), ...
  datestr(min([events.start_datenum]), 'yyyy-mm-dd'), datestr(max([events.start_datenum]), 'yyyy-mm-dd'), ...
  time_elapsed(t_start, now));
fprintf('%d chorus\n%d hiss\n%d unknown emission\n%d noise\n%d unchar\n', ...
  num_chorus, num_hiss, num_unknown, num_noise, num_unchar);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton_choose_from_spec.
function pushbutton_choose_from_spec_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_choose_from_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure(1);
[x, y] = ginput(1);

% Round to the previous synoptic minute if we clicked past minute 0005
if x*1440 > 5
  x = floor((x - 5/1440)*96)/96 + 5/1440;
else
  x = 5/1440;
end

hhmm = datestr(x, 'HHMM');
set(handles.edit_hhmm, 'string', hhmm);
edit_hhmm_Callback(handles.edit_hhmm, eventdata, handles);
go_no_24_refresh(handles, eventdata)

function handles = update_event(hObject, handles, event_type)
% Function to update events struct and display warning about unsaved
% changes

event_idx = str2double(get(handles.edit_index, 'String'));
handles.UD.events(event_idx).type = event_type;
this_event = handles.UD.events(event_idx);

fprintf('Marked event %d on %s at f = %0.1f kHz as %s\n', event_idx, ...
  datestr(this_event.start_datenum, 31), this_event.ec.f_peak/1e3, event_type);

% Update handles structure
guidata(hObject, handles);

set(handles.text_messages, 'String', 'Warning: there are unsaved changes');

function [df, cleaned_data_filename] = load_cleaned_data(this_datenum, handles)
% Function to load a cleaned data file into a struct

cleaned_data_dir = fullfile(get(handles.edit_cleaned_data_dir, 'string'), ...
                          datestr(this_datenum, 'yyyy'), ...
              datestr(this_datenum, 'mm_dd'));

d = [dir(fullfile(cleaned_data_dir, '*.mat')); dir(fullfile(cleaned_data_dir, '*.MAT'))];
file_datenums = zeros(size(d));
for kk = 1:length(d)
  file_datenums(kk) = get_bb_fname_datenum(fullfile(cleaned_data_dir, d(kk).name), true);
end

idx_closest = nearest(this_datenum, file_datenums);
if abs(file_datenums(idx_closest) - this_datenum) > 1/1440
  error('loadcleaned:nofile', 'No cleaned file for %s', datestr(this_datenum, 31));
end

cleaned_data_filename = fullfile(cleaned_data_dir, d(idx_closest).name);

df = load(cleaned_data_filename);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(get(handles.text_messages, 'string'))
  choice = questdlg('You have unsaved changes to the emission database.', ...
    'Save changes?', ...
    'Save changes', 'Discard changes', 'Save changes');
  switch choice
    case 'Save changes'
      pushbutton_save_db_Callback(handles.pushbutton_save_db, eventdata, handles);
    case 'Discard changes'
      disp('Changes to event database discarded');
  end
end

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in pushbutton_fwd_em.
function pushbutton_fwd_em_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_fwd_em (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

old_datenum = retrieve_datenum(handles);
next_em_datenum_i = find([handles.UD.events.start_datenum] > old_datenum + 1/1440, 1);
if isempty(next_em_datenum_i)
  uiwait(errordlg('No future emissions'));
  return;
end
next_em_datenum = handles.UD.events(next_em_datenum_i).start_datenum;

set_datenum(handles, next_em_datenum);
go_no_24_refresh(handles, eventdata);

% --- Executes on button press in pushbutton_back_em.
function pushbutton_back_em_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_back_em (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

old_datenum = retrieve_datenum(handles);
prev_em_datenum_i = find([handles.UD.events.start_datenum] < old_datenum - 1/1440, 1, 'last');
if isempty(prev_em_datenum_i)
  uiwait(errordlg('No previous emissions'));
  return;
end
prev_em_datenum = handles.UD.events(prev_em_datenum_i).start_datenum;

set_datenum(handles, prev_em_datenum);
go_no_24_refresh(handles, eventdata);


% --- Executes on button press in pushbutton_batch_remove.
function pushbutton_batch_remove_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_batch_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

events = handles.UD.events;
this_datenum = retrieve_datenum(handles);

this_days_events_idx = find(floor([events.start_datenum]) == floor(this_datenum));
this_days_events = events(this_days_events_idx);

figure(1);
xl = xlim;
yl = ylim;
x = mean(xl);
y = yl(1) + 5/6*diff(yl);

h_text = text(x, y, 'Click lower left', 'Color', 'w', 'FontSize', 36, 'FontWeight', 'bold', ...
  'HorizontalAlignment', 'center');
[t(1), f(1)] = ginput(1);
delete(h_text);
h_text = text(x, y, 'Click upper right', 'Color', 'w', 'FontSize', 36, 'FontWeight', 'bold', ...
  'HorizontalAlignment', 'center');
[t(2), f(2)] = ginput(1);
delete(h_text);

idx_delete = find(fpart([this_days_events.start_datenum]) >= t(1) & ...
                fpart([this_days_events.end_datenum]) <= t(2) & ...
          [this_days_events.f_lc] >= f(1) & ...
          [this_days_events.f_uc] <= f(2));

if isempty(idx_delete)
  warning('No valid emissions selected');
  return;
end

for kk = 1:length(idx_delete)
  disp(sprintf('Deleting emission at %s [%0.0f %0.0f] Hz', ...
    datestr(events(this_days_events_idx(idx_delete(kk))).start_datenum), ...
    events(this_days_events_idx(idx_delete(kk))).f_lc, ...
    events(this_days_events_idx(idx_delete(kk))).f_uc));
end

events(this_days_events_idx(idx_delete)) = [];

% Delete rectangles in spec_24 (but not syn_spec)

idx_delete = find([handles.UD.spec24_rect.t_start] >= t(1) & ...
                [handles.UD.spec24_rect.t_end] <= t(2) & ...
          [handles.UD.spec24_rect.f_lc] >= f(1) & ...
          [handles.UD.spec24_rect.f_uc] <= f(2));
delete([handles.UD.spec24_rect(idx_delete).h]);
handles.UD.spec24_rect(idx_delete) = [];

% Commit the changes
handles = change_event_list(hObject, handles, events);

% Update handles structure
guidata(hObject, handles);

function syn_rect = plot_rectangle_on_syn_spec(t_start, t_end, f_lc, f_uc, type)
% Plot a rectangle on the synoptic spectrogram

syn_rect(1) = rectangle('Position', [t_start, f_lc, t_end - t_start, f_uc - f_lc], 'Curvature', 0.1, 'EdgeColor', 'r', 'LineWidth', 2);
syn_rect(2) = text(mean([t_start t_end]), mean([f_lc f_uc]), type, ...
  'color', 'k', 'backgroundcolor', 'w', 'fontweight', 'bold', 'fontsize', 14, ...
  'horizontalalignment', 'center', 'verticalalignment', 'middle');
set(syn_rect, 'tag', 'event_rectangle');


function edit_index_Callback(hObject, eventdata, handles)
% hObject    handle to edit_index (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_index as text
%        str2double(get(hObject,'String')) returns contents of edit_index as a double


% --- Executes during object creation, after setting all properties.
function edit_index_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_index (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_chorus.
function pushbutton_chorus_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_chorus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles = update_event(hObject, handles, 'chorus');
pushbutton_next_Callback(handles.pushbutton_next, eventdata, handles);


% --- Executes on button press in pushbutton_hiss.
function pushbutton_hiss_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_hiss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = update_event(hObject, handles, 'hiss');
pushbutton_next_Callback(handles.pushbutton_next, eventdata, handles);


% --- Executes on button press in pushbutton_both.
function pushbutton_both_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_both (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = update_event(hObject, handles, 'both');
pushbutton_next_Callback(handles.pushbutton_next, eventdata, handles);


% --- Executes on button press in pushbutton_unknown.
function pushbutton_unknown_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_unknown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = update_event(hObject, handles, 'emission');
pushbutton_next_Callback(handles.pushbutton_next, eventdata, handles);


% --- Executes on button press in pushbutton_noise.
function pushbutton_noise_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_noise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = update_event(hObject, handles, 'noise');
pushbutton_next_Callback(handles.pushbutton_next, eventdata, handles);



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



function edit_emission_chars_Callback(hObject, eventdata, handles)
% hObject    handle to edit_emission_chars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_emission_chars as text
%        str2double(get(hObject,'String')) returns contents of edit_emission_chars as a double


% --- Executes during object creation, after setting all properties.
function edit_emission_chars_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_emission_chars (see GCBO)
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
    pushbutton_previous_Callback(handles.pushbutton_previous, [], handles);
  case 'rightarrow'
    pushbutton_next_Callback(handles.pushbutton_previous, [], handles);
  case 'uparrow'
    pushbutton_unknown_Callback(handles.pushbutton_previous, [], handles);
  case 'downarrow'
    pushbutton_noise_Callback(handles.pushbutton_previous, [], handles);
  case 'q'
    pushbutton_chorus_Callback(handles.pushbutton_previous, [], handles);
  case 'w'
    pushbutton_hiss_Callback(handles.pushbutton_previous, [], handles);
end


% --- Executes on button press in checkbox_skip_noise.
function checkbox_skip_noise_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_skip_noise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_skip_noise
