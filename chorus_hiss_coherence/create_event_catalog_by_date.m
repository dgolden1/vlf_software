function create_event_catalog_by_date(db_filename, output_dir, start_datenum, end_datenum)
% create_event_catalog(db_filename, output_dir, start_datenum, end_datenum)
% Create a catalog of synoptic epochs, with events labeled, if any

% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id$

%% Setup
addpath(fullfile(danmatlabroot, 'vlf', 'emission_statistics'));

%% Set paths
[~, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
  case 'quadcoredan.stanford.edu'
    default_output_dir = '~/temp/event_catalog';
    cleaned_data_dir = '/media/scott/user_data/dgolden/palmer_bb_cleaned';
  case 'scott.stanford.edu'
    default_output_dir = '~/temp/event_catalog';
    cleaned_data_dir = '/data/user_data/dgolden/palmer_bb_cleaned';
  case {'amundsen.stanford.edu', 'shackleton.stanford.edu'}
    default_output_dir = '~/temp/event_catalog';
    cleaned_data_dir = '~/scott/user_data/dgolden/palmer_bb_cleaned';
end

if ~exist('output_dir', 'var') || isempty(output_dir)
  output_dir = default_output_dir;
end
if ~exist(output_dir, 'dir')
  unix(sprintf('mkdir -p %s', output_dir));
end

%% Parallel
PARALLEL = true;

if ~PARALLEL
  warning('Parallel mode disabled!');
end

poolsize = matlabpool('size');
if PARALLEL && poolsize == 0
  matlabpool('open');
end
if ~PARALLEL && poolsize ~= 0
  matlabpool('close');
end

%% Load and parse events
load(db_filename, 'events');

event_datenums = [events.start_datenum];

if ~exist('start_datenum', 'var') || isempty(start_datenum)
  start_datenum = min(event_datenums);
end
if ~exist('end_datenum', 'var') || isempty(end_datenum)
  end_datenum = max(event_datenums);
end

dg = load('data_gaps.mat');
syn_dates = dg.synoptic_epochs(dg.synoptic_epochs >= min(event_datenums) ...
  & dg.synoptic_epochs <= max(event_datenums) & dg.b_data);
mydates = syn_dates(1:floor(length(syn_dates)/1000):end);

events = events(([events.start_datenum] >= start_datenum) & ([events.end_datenum] <= end_datenum));

%% Additional criteria on events
events = events(~strcmp({events.type}, 'noise'));

%% Delete files in output directory
d = dir(fullfile(output_dir, '*.png'));
if ~isempty(d)
  resp = input(sprintf('Erase %d PNG files from %s? [Y/N]: ', length(d), output_dir), 's');
  if strcmpi(resp, 'y')
    unix(sprintf('rm %s/*.png', output_dir));
  elseif ~strcmpi(resp, 'n')
    error('Invalid response: %s', resp);
  end
end

%% Plot and print
t_net_start = now;
progress_temp_dirname = parfor_progress_init;
% warning('Parfor disabled!');
% for kk = 1:length(events)
parfor kk = 1:length(mydates)
  t_start = now;
  
  these_events = events(abs(event_datenums - mydates(kk)) < 1/86400);
  output_filename = process_one_date(mydates(kk), these_events, cleaned_data_dir, output_dir);
  iteration_number = parfor_progress_step(progress_temp_dirname, kk);

  if ~isempty(output_filename)
    fprintf('Wrote %s (date %d of %d) in %s\n', just_filename(output_filename), iteration_number, ...
      length(mydates), time_elapsed(t_start, now));
  else
    fprintf('Skipped %s (output file exists) (event %d of %d)\n', just_filename(output_filename), iteration_number, ...
      length(mydates));
  end
end
parfor_progress_cleanup(progress_temp_dirname);

fprintf('Finished in %s\n', time_elapsed(t_net_start, now));

function output_filename = process_one_date(this_date, events, cleaned_data_dir, output_dir)
[yy, mm, dd, HH, MM, SS] = datevec(this_date);
data_filename = fullfile(cleaned_data_dir, sprintf('%04d', yy), sprintf('%02d_%02d', mm, dd), ...
  sprintf('PA_%04d_%02d_%02dT%02d%02d_05_002_cleaned.mat', yy, mm, dd, HH, MM));

t_start = 0;
t_end = 10;

output_filename = fullfile(output_dir, ...
  sprintf('%04d_%02d_%02dT%02d%02d', yy, mm, dd, HH, MM));

% if exist(output_filename, 'file')
%   output_filename = '';
%   return;
% end

DF = load(data_filename);
if ishandle(1)
  close(1);
end
figure(1);
spectrogram_cal(DF.data, 1024, 768, 1024, DF.Fs, 'palmer',this_date);
colorbar off; axis off;
title(strrep(sprintf('%04d_%02d_%02dT%02d%02d',  yy, mm, dd, HH, MM), '_', '\_'));

for kk = 1:length(events)
  f_lc = events(kk).f_lc;
  f_uc = events(kk).f_uc;
  type = events(kk).type;
  syn_rect.h(1) = rectangle('Position', [t_start, f_lc, t_end - t_start, f_uc - f_lc], ...
    'Curvature', 0.1, 'EdgeColor', 'r', 'LineWidth', 2, 'LineStyle', '-');
  syn_rect.h(2) = text(mean([t_start t_end]), mean([f_lc f_uc]), type, ...
    'color', 'k', 'backgroundcolor', 'w', 'fontweight', 'bold', 'fontsize', 14, ...
    'horizontalalignment', 'center', 'verticalalignment', 'middle');
end
  
% pos = get(gcf, 'position');
% if pos(3) == 520
  figure_grow(gcf, 1.5);
% end
print('-dpng', output_filename);
