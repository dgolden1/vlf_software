function [pathstr, files, b_isvalid] = get_alexandria_files(sitename, start_datenum, end_datenum, str_type)
% [pathstr, files, b_isvalid] = get_alexandria_files(sitename, start_datenum, end_datenum, str_type)
% Get data from sitename and date
% 
% If there are files in the appropriate directory, but none whose start
% time falls completely within start_datenum and end_datenum (inclusive),
% get_alexandria_files will still return one file (or one file for each
% channel for AWESOME data), which is the broadband file that starts
% closest to start_datenum. In this case, b_isvalid will be false.
% 
% INPUTS
% sitename: folder name of site in awesome/broadband folder on server
% start_datenum: lower bound on file start times
% end_datenum: upper bound on file start times
% str_type can be one of:
%  'raw' (default) -- use raw data
%  'cleaned' -- use cleaned data from data_products/palmer_bb_cleaned
% 
% OUTPUTS
% pathstr: path to files
% files: cell array of filenames
% b_isvalid: false if the nearest file was returned instead of one that
% starts between start_datenum and end_datenum

% By Daniel Golden (dgolden1 at stanford dot edu) November 2007
% $Id$

%% Setup
if ~exist('str_type', 'var') || isempty(str_type)
	str_type = 'raw';
end

if strcmp(str_type, 'cleaned') && ~strcmp(sitename, 'palmer')
	error('Cleaned data is only available for Palmer station -- DIG 2009-11-18');
end

%% Set paths
raw_data_dir = fullfile(scottdataroot, 'awesome');
data_products_dir = fullfile(scottdataroot, 'user_data', 'dgolden');

if strcmp(str_type, 'raw')
	alexandria_broadband_dir = fullfile(raw_data_dir, 'broadband');
elseif strcmp(str_type, 'cleaned')
	alexandria_broadband_dir = fullfile(data_products_dir, 'palmer_bb_cleaned');
end

%% Correct roundoff errors
% Sometimes there are weird numerical precision errors in the start and end
% datenums
% Round them to the nearest second
start_datenum = round(start_datenum*86400)/86400;
end_datenum = round(end_datenum*86400)/86400;

%% Do stuff
if floor(start_datenum) ~= floor(end_datenum) && end_datenum ~= floor(start_datenum) + 1
	error('Range must be on a single day; range specified is from %s to %s', ...
		datestr(start_datenum, 'mmmm dd, yyyy'), datestr(end_datenum, 'mmmm dd, yyyy'));
end

[year, month, day] = datevec(start_datenum);

switch str_type
	case 'raw'
		pathstr = fullfile(alexandria_broadband_dir, sitename, ...
			sprintf('%04d', year), sprintf('%02d_%02d', month, day));
	case 'cleaned'
		pathstr = fullfile(alexandria_broadband_dir, ...
			sprintf('%04d', year), sprintf('%02d_%02d', month, day));
end
if ~isdir(pathstr)
	error('get_alexandria_files:PathNotExist', 'Path %s does not exist', pathstr);
end
allfiles = [dir(fullfile(pathstr, '*.mat')); dir(fullfile(pathstr, '*.MAT'))];
full_filenames = {allfiles.name}.';
full_filenames = cellfun(@(x) fullfile(pathstr, x), full_filenames, 'uniformoutput', false); % Add full path to each filename


% Remove invalid files from the file list
files = [];
b_isvalid = true;

bb_datenums = get_bb_fname_datenum(full_filenames);

% If the files don't have year, month, day info in their filename, we'll
% only get their hour, minute second. Add what we know to be their year,
% month, day to their datenum
if all(bb_datenums < 1)
	bb_datenums = bb_datenums + datenum([year month day 0 0 0]);
end

valid_idx = find(bb_datenums >= start_datenum & bb_datenums < end_datenum);

% If there were no valid files, pick the file that has the nearest datenum
% If two files are equally close, pick the earlier one
if length(valid_idx) == 0
	valid_idx = nearest(start_datenum, bb_datenums);
	
	% If the nearest file's datenum is off by more than 15 minutes and one second, give up
	if abs(start_datenum - bb_datenums(valid_idx)) > 15/1440 + 1/86400
		error('No valid BB files found for %s; nearest file is at %s (%s); difference is %s', ...
			datestr(start_datenum, 31), datestr(bb_datenums(valid_idx), 31), ...
			fullfile(pathstr, full_filenames{valid_idx}), time_elapsed(start_datenum, bb_datenums(valid_idx)));
  end
  
  b_isvalid = false;
end

files = {allfiles(valid_idx).name}; % Select just the valid filenames
