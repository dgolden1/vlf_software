function ecg_zoom_emission(handles, start_datenum, end_datenum, db_filename, f_lc, f_uc, sec_per_snapshot, start_sec, single_em, str_type)
% ecg_zoom_emission(handles, start_datenum, end_datenum, db_filename, f_lc, f_uc, sec_per_snapshot, start_sec, single_em)
% Function that uses the vlfTool code to plot a zoomed-in version of the
% emission
% 
% INPUTS
% single_em: send a single emission along so that lower-level functions
% don't have to load the database. single_em can be a vector of emissions
% with the same times
% 
% str_type can be one of:
%  'raw' (default) -- use raw data
%  'cleaned' -- use cleaned data from data_products/palmer_bb_cleaned

% By Daniel Golden (dgolden1 at stanford dot edu) November 2007
% $Id$

%% Setup
addpath(fullfile(danmatlabroot, 'vlf', 'vlftool_24_hour_fcn'));

if ~exist('f_lc', 'var') || isempty(f_lc), f_lc = 300; end
if ~exist('f_uc', 'var') || isempty(f_uc), f_uc = 10e3; end
if ~exist('sec_per_snapshot', 'var') || isempty(sec_per_snapshot), sec_per_snapshot = 2; end
if ~exist('start_sec', 'var') || isempty(start_sec), start_sec = 5; end
if ~exist('single_em', 'var'), single_em = []; end
if ~exist('str_type', 'var'), str_type = []; end


if f_uc < 100, warning('f_uc is very low (%0.1f Hz)', f_uc); end %#ok<WNTAG>

%% Get the broadband files to process
if isempty(handles)
	station_name = 'palmer';
else
	[pathstr, name] = fileparts(get(handles.edit_input_jpeg, 'string'));
	station_name = strtok(name, '_');
end

switch lower(station_name)
	case {'palmer', 'palmer__', 'palmerstation'}
		station_name = 'palmer';
	case 'chistochina'
		station_name = 'chistochina';
	otherwise
		error('Unsupported station name: %s', station_name);
end

[pathname, filenames] = get_alexandria_files(station_name, start_datenum, end_datenum, str_type);
for kk = 1:length(filenames), filenames{kk} = fullfile(pathname, filenames{kk}); end
filenames = prune_irregular_synoptic_files(filenames);

%% Run the vlf tool function
% We usually ask for files 0 seconds past the minute, and the cleaned files
% usually start 5 seconds past the minute.  Add any relevant offset into
% start_sec
if strcmp(str_type, 'cleaned')
	bb_start_datenum = get_bb_fname_datenum(filenames);
	start_sec = start_sec + round((start_datenum - bb_start_datenum)*86400);
end

endSec = start_sec + sec_per_snapshot;
maxPlots = length(filenames);
bSavePlot = false;
numRows = 1;
bContSpec = true;
bProc24 = false;

% [y m d] = datevec(start_datenum);
% if y == 2001
% 	dbOffset = 5;
% else
	dbOffset = 0;
% end

vlftoolfcn(filenames, start_sec, endSec, bSavePlot, [], numRows, f_uc, f_lc, bContSpec, bProc24, dbOffset);

%% Mark known emissions
bIncludeCaption = true;
if length(filenames) == 1
	time_style = 'sec';
else
	time_style = 'true_time';
end
h_ax = findobj('tag', 'bbax');
if length(h_ax) ~= 1
	error('Unable to find vlftool spectrogram axis');
end
marker_handles = ecg_mark_known_emissions(db_filename, start_datenum, end_datenum, h_ax, bIncludeCaption, time_style, single_em);
