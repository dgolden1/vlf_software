function varargout = emission_db_corrector(varargin)
% EMISSION_DB_CORRECTOR M-file for emission_db_corrector.fig
%      EMISSION_DB_CORRECTOR, by itself, creates a new EMISSION_DB_CORRECTOR or raises the existing
%      singleton*.
%
%      H = EMISSION_DB_CORRECTOR returns the handle to a new EMISSION_DB_CORRECTOR or the handle to
%      the existing singleton*.
%
%      EMISSION_DB_CORRECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EMISSION_DB_CORRECTOR.M with the given input arguments.
%
%      EMISSION_DB_CORRECTOR('Property','Value',...) creates a new EMISSION_DB_CORRECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before emission_db_corrector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to emission_db_corrector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help emission_db_corrector

% Last Modified by GUIDE v2.5 28-Apr-2011 07:57:36
% By Daniel Golden (dgolden1 at stanford dot edu) November 2009
% $Id$

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @emission_db_corrector_OpeningFcn, ...
                   'gui_OutputFcn',  @emission_db_corrector_OutputFcn, ...
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


% --- Executes just before emission_db_corrector is made visible.
function emission_db_corrector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to emission_db_corrector (see VARARGIN)

% Choose default command line output for emission_db_corrector
handles.output = hObject;

% UIWAIT makes emission_db_corrector wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Add userdata field to handles
handles.UD = struct;

% Add empty emissions struct
handles.UD.events = [];

% Set defaults
[database_filename, summary_plot_directory, cleaned_data_directory, initial_datenum] = emission_db_corrector_defaults;
set(handles.edit_db_filename, 'string', database_filename);
set(handles.edit_sum_plot_dir, 'string', summary_plot_directory);
set(handles.edit_cleaned_data_dir, 'string', cleaned_data_directory);
set_datenum(handles, initial_datenum);

% Use a keypress function for keyboard shortcuts
% set(handles.figure1, 'KeyPressFcn', @emission_db_corrector_keypress_fcn);

% Update handles structure
guidata(hObject, handles);

% Close open figures
if ishandle(1), close(1); end
if ishandle(2), close(2); end


% --- Outputs from this function are returned to the command line.
function varargout = emission_db_corrector_OutputFcn(hObject, eventdata, handles) 
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

if ishandle(1)
  set(1, 'tag', '');
end

go_no_24_refresh(handles, eventdata);


function go_no_24_refresh(handles, eventdata, b_no_syn_spec)
% Does what the "go" button does, but doesn't refresh the 24-hour
% spectrogram

if ~exist('b_no_syn_spec', 'var')
  b_no_syn_spec = false;
end

% Make sure database is loaded
if isempty(handles.UD.events)
  handles = pushbutton_load_db_Callback(handles.pushbutton_load_db, eventdata, handles);
end

% First load the appropriate 24-hour spectrogram in figure 1
this_datenum = retrieve_datenum(handles);
tag_name = ['24-spec_' datestr(this_datenum, 'yyyy-mm-dd')];

% Only load the spec_amp if it's not already loaded
figure(1);
if ~ishandle(1) || ~strcmp(get(1, 'tag'), tag_name)
  handles = load_24_spec(handles.pushbutton_go, handles, this_datenum);
end

% Next, load the individual spectrogram in figure 2
if b_no_syn_spec
  sfigure(2);
  clf;
else
  try
    handles = load_syn_spec(handles.pushbutton_go, handles, this_datenum);
  catch er
    if strcmp(er.identifier, 'loadcleaned:nofile')
      uiwait(errordlg(er.message));
      return;
    else
      rethrow(er);
    end
  end

end

function handles = load_24_spec(hObject, handles, this_datenum)
% Function to load the spec_amp for a given day

% Get this day's events
event_datenums = [handles.UD.events.start_datenum];
handles.UD.this_days_events = handles.UD.events(event_datenums >= floor(this_datenum) & event_datenums < floor(this_datenum+1));

tag_name = ['24-spec_' datestr(this_datenum, 'yyyy-mm-dd')];

spec_amp_dir = fullfile(get(handles.edit_sum_plot_dir, 'string'), datestr(this_datenum, 'yyyy'), 'spec_amps');
spec_amp_filename = fullfile(spec_amp_dir, sprintf('palmer_%s.mat', datestr(this_datenum, 'yyyymmdd')));
if ~exist(spec_amp_filename, 'file');
  fprintf('Spec amp %s does not exist\n', spec_amp_filename);
end

spec_amp = load(spec_amp_filename);

figure(1);
clf;
imagesc(spec_amp.t, spec_amp.f, spec_amp.spec_amp); axis xy;
pos = get(gcf, 'position');
if pos(3) == 560
  set(gcf, 'position', [0 570 pos(3:4)]);
  figure_squish(gcf, 0.4, 1.2);
  pos_a = get(gca, 'position');
%   set(gca, 'position', [0.1 pos_a(2) 0.85 pos_a(4)]);
end

datetick2('x', 'keeplimits');
colorbar;
caxis([-20 25]);
xlabel('Time');
ylabel('Frequency');
title(sprintf('%s UT, 24-hour synoptic spectrogram, 2-sec snapshots, 15-min gaps', datestr(this_datenum, 'yyyy-mm-dd')));
increase_font(gcf, 14);
set(gcf, 'tag', tag_name);

% Mark known emissions
if ~isempty(handles.UD.this_days_events)
  this_days_emissions = handles.UD.this_days_events;
  spec24_rect = plot_rectangle_on_24_spec(this_days_emissions);

  % Save handles to rectangles so we can easily delete them later
  handles.UD.spec24_rect = spec24_rect;
else
  handles.UD.spec24_rect = [];
end


% Update handles structure
guidata(hObject, handles);


function handles = load_syn_spec(hObject, handles, this_datenum)
% Load the 10-second synoptic spectrogram

[df, cleaned_data_filename] = load_cleaned_data(this_datenum, handles);

handles.UD.syn_filename = cleaned_data_filename;

figure(2);
% clf;
window = 512;
noverlap = window/2;
nfft = 512;
fs = df.Fs;
sitename = 'palmer';
[S_cal, F, T, unit_str, caxis_recommendation] = spectrogram_cal(df.data, window, noverlap, nfft, fs, sitename, this_datenum);
imagesc(T, F, S_cal); axis xy; caxis(caxis_recommendation); xlabel('Time (sec)'); ylabel('Freq. (Hz)'); 
title(sprintf('%s UT, synoptic spectrogram', datestr(this_datenum, 'yyyy-mm-dd HHMM')));
increase_font(gcf, 14);

pos = get(gcf, 'position');
if pos(3) == 560
  set(gcf, 'position', [0 55 pos(3:4)]);
  figure_squish(gcf, 0.6, 1);
end

% Draw a line on the spec_24 plot showing where we are
sfigure(1);
hold on;
yl = ylim;
delete(findall(1, 'tag', 'currentline_handle')); % Delete the old line
% if isfield(handles.UD, 'currentline_handle') && ishandle(handles.UD.currentline_handle)
%   % Delete the old line
%   delete(handles.UD.currentline_handle);
%   handles.UD.currentline_handle = nan;
% end
handles.UD.currentline_handle = plot(fpart(this_datenum)*[1 1], yl, 'w--', 'LineWidth', 3);
set(handles.UD.currentline_handle, 'tag', 'currentline_handle');
sfigure(2);

% Mark known emissions
if ~isempty(handles.UD.this_days_events)
  xl = xlim;
  start_datenums = [handles.UD.this_days_events.start_datenum];
  this_syn_emissions = handles.UD.this_days_events(start_datenums >= this_datenum & ...
    start_datenums < this_datenum + 1/96);
  
  syn_rect = struct('h', nan, 'f_lc', nan, 'f_uc', nan);
  syn_rect = repmat(syn_rect, length(this_syn_emissions), 1);
  
  for kk = 1:length(this_syn_emissions)
    t_start = xl(1);
    t_end = xl(2);
    f_lc = this_syn_emissions(kk).f_lc;
    f_uc = this_syn_emissions(kk).f_uc;

    if ~isfield(this_syn_emissions, 'type')
      type = '';
    else
      type = this_syn_emissions(kk).type;
    end
    syn_rect(kk) = plot_rectangle_on_syn_spec(t_start, t_end, f_lc, f_uc, this_syn_emissions(kk).burstiness, type);
  end
  
  % Save handles to rectangles so we can easily delete them later
  handles.UD.syn_rect = syn_rect;
else
  handles.UD.syn_rect = [];
end

% Use a keypress function for keyboard shortcuts
% set(2, 'KeyPressFcn', @emission_db_corrector_keypress_fcn);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton_back_spec.
function pushbutton_back_spec_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_back_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

old_datenum = retrieve_datenum(handles);
new_datenum = old_datenum - 1/96;
set_datenum(handles, new_datenum);
go_no_24_refresh(handles, eventdata);

% --- Executes on button press in pushbutton_back_day.
function pushbutton_back_day_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_back_day (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

old_datenum = retrieve_datenum(handles);
new_datenum = floor(old_datenum - 1) + 5/1440;
set_datenum(handles, new_datenum);
b_no_syn_spec = true;
go_no_24_refresh(handles, eventdata, b_no_syn_spec);


% --- Executes on button press in pushbutton_fwd_spec.
function pushbutton_fwd_spec_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_fwd_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

old_datenum = retrieve_datenum(handles);
new_datenum = old_datenum + 1/96;
set_datenum(handles, new_datenum);
go_no_24_refresh(handles, eventdata);

% --- Executes on button press in pushbutton_fwd_day.
function pushbutton_fwd_day_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_fwd_day (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

old_datenum = retrieve_datenum(handles);
new_datenum = floor(old_datenum + 1) + 5/1440;
set_datenum(handles, new_datenum);
b_no_syn_spec = true;
go_no_24_refresh(handles, eventdata, b_no_syn_spec);


% --- Executes on button press in pushbutton_rem_em.
function pushbutton_rem_em_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_rem_em (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

events = handles.UD.events;

figure(2);
x = 5;
y = 9000;
h_text = text(x, y, 'Click emission to delete', 'Color', 'w', 'FontSize', 36, 'FontWeight', 'bold', ...
  'HorizontalAlignment', 'center');
[~, f] = ginput(1);
delete(h_text);

if f < 0 || f > 10e3
  error('Invalid f (%0.0f Hz)', f);
end

start_datenum = retrieve_datenum(handles);

idx_delete = find(abs([events.start_datenum] - start_datenum) < 1/1440 & ...
  [events.f_lc] <= f & [events.f_uc] >= f);

if isempty(idx_delete)
  warning('No valid emissions selected');
  return;
end

for kk = 1:length(idx_delete)
  disp(sprintf('Deleting emission at %s [%0.0f %0.0f] Hz', ...
    datestr(events(idx_delete(kk)).start_datenum), ...
    events(idx_delete(kk)).f_lc, ...
    events(idx_delete(kk)).f_uc));
end

events(idx_delete) = [];

handles = change_event_list(hObject, handles, events);

% Delete rectangles in spec_24 and syn_spec

idx = find(abs([handles.UD.spec24_rect.t_start] - fpart(start_datenum)) < 1/1440 & ...
  [handles.UD.spec24_rect.f_lc] <= f & [handles.UD.spec24_rect.f_uc] >= f);
assert(length(idx) == 1);
delete(handles.UD.spec24_rect(idx).h);
handles.UD.spec24_rect(idx) = [];

idx = find([handles.UD.syn_rect.f_lc] <= f & [handles.UD.syn_rect.f_uc] >= f);
assert(length(idx) == 1);
delete(handles.UD.syn_rect(idx).h);
handles.UD.syn_rect(idx) = [];


% Re-run "go" to show removed emission
% go_no_24_refresh(handles, eventdata);


% --- Executes on button press in pushbutton_add_em.
function handles = pushbutton_add_em_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_add_em (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

this_datenum = retrieve_datenum(handles);

events = handles.UD.events;

figure(2);
x = 5;
y = 9000;
h_text = text(x, y, 'Click bottom', 'Color', 'w', 'FontSize', 36, 'FontWeight', 'bold', ...
  'HorizontalAlignment', 'center');
[t_start, f_lc] = ginput(1);
delete(h_text);
h_text = text(x, y, 'Click top', 'Color', 'w', 'FontSize', 36, 'FontWeight', 'bold', ...
  'HorizontalAlignment', 'center');
[t_end, f_uc] = ginput(1);
delete(h_text);

if f_uc <= f_lc || min(f_lc, f_uc) < 0 || max(f_lc, f_uc) > 10000
  error('Invalid f_lc, f_uc (%0.0f Hz, %0.0f Hz)', f_lc, f_uc);
end

% Detect clicking left or right of the spectrogram
xl = xlim;
if t_start < xl(1) || t_end > xl(2)
  error('Outside of spectrogram clicked');
end


% Deal with overlap
these_emissions = events(abs([events.start_datenum] - this_datenum) < 1/1440);

% If this emission is inside another emission, or another emission is
% inside this emission, it's invalid
if any([these_emissions.f_lc] <= f_lc & [these_emissions.f_uc] >= f_uc)
  error('This emission cannot be inside other emissions');
end
if any([these_emissions.f_lc] >= f_lc & [these_emissions.f_uc] <= f_uc)
  error('Other emissions cannot be inside this emission');
end

% If this emission overlaps with other emissions, chop it until it doesn't
idx_upper_overlap = find(f_uc > [these_emissions.f_lc] & f_lc < [these_emissions.f_lc]);
if ~isempty(idx_upper_overlap)
  assert(length(idx_upper_overlap) == 1);
  f_uc = these_emissions(idx_upper_overlap).f_lc;
  disp(sprintf('Warning: truncated f_uc to %0.0f Hz', f_uc));
end
idx_lower_overlap = find(f_lc < [these_emissions.f_uc] & f_uc > [these_emissions.f_uc]);
if ~isempty(idx_lower_overlap)
  assert(length(idx_lower_overlap) == 1);
  f_lc = these_emissions(idx_lower_overlap).f_uc;
  disp(sprintf('Warning: truncated f_lc to %0.0f Hz', f_lc));
end

% Get amplitude and burstiness from original cleaned data file
ec = get_emission_stats_post_facto(this_datenum, f_lc, f_uc);

tweek_params = struct('f_peak', {}, 'time_to_term', {}, 'med_mean_peak', {}, ...
  'med_mean_avg', {}, 'upper_slope', {}, 'lower_slope', {}, 'cutoff_slope', {}, ...
  'burstiness', {});
sferic_params = struct('vcorr', {}, 'slope', {});

start_datenum = retrieve_datenum(handles);
end_datenum = start_datenum + 1/96;
notes = 'manual';
emission_type = 'unchar';

event = struct('f_lc', f_lc, 'f_uc', f_uc, 'amplitude', [], 'burstiness', [], ...
  'sferic_params', sferic_params, 'tweek_params', tweek_params, 'start_datenum', start_datenum, ...
  'end_datenum', end_datenum, 'notes', notes, 'emission_type', emission_type);

% Add event
events(end+1) = event;

handles = change_event_list(hObject, handles, events);

% Add rectangle in syn_spec
xl = xlim;
r = plot_rectangle_on_syn_spec(xl(1), xl(end), f_lc, f_uc, burstiness);
handles.UD.syn_rect = [handles.UD.syn_rect; r];

% Add rectangle in spec_24
sfigure(1);
r24.h = rectangle('Position', [fpart(start_datenum), f_lc, end_datenum - start_datenum, f_uc - f_lc], 'Curvature', 0.1, 'EdgeColor', 'r', 'LineWidth', 2);
r24.t_start = fpart(start_datenum);
r24.t_end = fpart(end_datenum);
r24.f_lc = f_lc;
r24.f_uc = f_uc;
handles.UD.spec24_rect = [handles.UD.spec24_rect; r24];

% Update handles structure
guidata(hObject, handles);

% Re-run "go" to show added emission
% go_no_24_refresh(handles, eventdata);

disp(sprintf('Added emission at %s [%0.0f %0.0f] Hz', datestr(start_datenum, 31), f_lc, f_uc));


% --- Executes on button press in pushbutton_batch_add.
function pushbutton_batch_add_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_batch_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
  while(1)
    handles = pushbutton_add_em_Callback(handles.pushbutton_add_em, eventdata, handles);
    pushbutton_fwd_spec_Callback(handles.pushbutton_fwd_spec, eventdata, handles);
  end
catch er
  disp(sprintf('Batch add ended due to error: %s', er.message));
end

% Update handles structure
guidata(hObject, handles);


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



function edit_sum_plot_dir_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sum_plot_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sum_plot_dir as text
%        str2double(get(hObject,'String')) returns contents of edit_sum_plot_dir as a double


% --- Executes during object creation, after setting all properties.
function edit_sum_plot_dir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sum_plot_dir (see GCBO)
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

disp(sprintf('Loaded %s', database_filename));
disp(sprintf('%d events from %s to %s, took %s', length(db.events), ...
  datestr(min([db.events.start_datenum]), 'yyyy-mm-dd'), datestr(max([db.events.start_datenum]), 'yyyy-mm-dd'), ...
  time_elapsed(t_start, now)));


% --- Executes on button press in pushbutton_save_db.
function pushbutton_save_db_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save_db (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

t_start = now;

if isempty(handles.UD.events)
  error('Database not loaded');
end

database_filename = get(handles.edit_db_filename, 'string');

% Resort events by start_datenum
[~, ix] = sort([handles.UD.events.start_datenum]);
handles.UD.events = handles.UD.events(ix);
events = handles.UD.events;


save(database_filename, 'events');

% Remove warning about unsaved changes
set(handles.text_messages, 'String', '');

disp(sprintf('Saved %s', database_filename));
disp(sprintf('%d events from %s to %s, took %s', length(events), ...
  datestr(min([events.start_datenum]), 'yyyy-mm-dd'), datestr(max([events.start_datenum]), 'yyyy-mm-dd'), ...
  time_elapsed(t_start, now)));

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

function handles = change_event_list(hObject, handles, new_events)
% Function to update events struct and display warning about unsaved
% changes

handles.UD.events = new_events;

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

function syn_rect = plot_rectangle_on_syn_spec(t_start, t_end, f_lc, f_uc, burstiness, type)
% Plot a rectangle on the synoptic spectrogram

linestyle = '-';

if isempty('type')
  rect_color = 'r';
else
  switch type
    case 'chorus'
      rect_color = 'r';
    case 'hiss'
      rect_color = [.6 0 1]; % Purple
    case {'unknown', 'emission'}
      rect_color = 'w';
    case 'noise'
      rect_color = [1 0 .6]; % Pink
  end
end

syn_rect.h(1) = rectangle('Position', [t_start, f_lc, t_end - t_start, f_uc - f_lc], ...
  'Curvature', 0.1, 'EdgeColor', rect_color, 'LineWidth', 2, 'LineStyle', linestyle);
syn_rect.h(2) = text(mean([t_start t_end]), mean([f_lc f_uc]), type, ...
  'color', 'k', 'backgroundcolor', 'w', 'fontweight', 'bold', 'fontsize', 14, ...
  'horizontalalignment', 'center', 'verticalalignment', 'middle');
syn_rect.f_lc = f_lc;
syn_rect.f_uc = f_uc;

function spec24_rect = plot_rectangle_on_24_spec(this_days_emissions)
% Plot rectangles on the 24-hour summary spectrogram

spec24_rect = struct('h', nan, 't_start', nan, 't_end', nan, 'f_lc', nan, 'f_uc', nan);
spec24_rect = repmat(spec24_rect, length(this_days_emissions), 1);

for kk = 1:length(this_days_emissions)
  t_start = fpart(this_days_emissions(kk).start_datenum);
  t_end = fpart(this_days_emissions(kk).end_datenum);
  if t_end < t_start, t_end = 1; end
  f_lc = this_days_emissions(kk).f_lc;
  f_uc = this_days_emissions(kk).f_uc;

  linestyle = '-';

  if ~isfield(this_days_emissions, 'type')
    rect_color = 'r';
  else
    switch this_days_emissions(kk).type
      case 'chorus'
        rect_color = 'r';
      case 'hiss'
        rect_color = [.6 0 1]; % Purple
      case {'unknown', 'emission'}
        rect_color = 'w';
      case 'noise'
        rect_color = [1 0 .6]; % Pink
    end
  end
  
  spec24_rect(kk).h = rectangle('Position', [t_start, f_lc, t_end - t_start, f_uc - f_lc], ...
    'Curvature', 0.1, 'EdgeColor', rect_color, 'LineWidth', 2, 'LineStyle', linestyle);
  spec24_rect(kk).t_start = t_start;
  spec24_rect(kk).t_end = t_end;
  spec24_rect(kk).f_lc = f_lc;
  spec24_rect(kk).f_uc = f_uc;
end
