function [filename, file_start_time, file_end_time] = whTarcsaiFindFileWithDate(date, sourcedir)
% filename = whTarcsaiFindFileWithDate(date)
% Finds a data file that contains the given date
% 
% INPUTS
% date: date to search for, in Matlab serial date number format
% sourcedir: source directory of the .mat file. This should be either the
% directory containing the appropriate .mat file, or the root directory of
% the given site as on vlf-alexandria (e.g., the directory containing the
% year folders)
% 
% OUTPUTS
% filename: the full file name of the file that contains that date. Returns
% the first file found.
% 
% Errors if the file is not found

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$


%% Setup
error(nargchk(2, 2, nargin));


%% Parse the date that we're looking for
% date_vec = datevec(date);
[date_year, date_month, date_day, date_hour, date_minute, date_second] = datevec(date);

%% Find the .mat files

% Get sourcedir directory listing
all_files = dir(sourcedir);

% Partition into .mat files and subdirectories
mat_files = [];
dirs = [];
for kk = 1:length(all_files)
	if all_files(kk).isdir % If this file is a directory
		if ~isnan(str2double(all_files(kk).name)) % If this directory is a number (e.g., a 4-digit year)
			dirs = [dirs; all_files(kk)]; % Add it to the list of directories
		end
	else
		[pathstr, name, ext] = fileparts(all_files(kk).name);
		if strcmp(ext, '.mat') % Otherwise, if this is a .mat file
			mat_files = [mat_files; all_files(kk)]; % Add to the list of .mat files
		end
	end
end

% If there aren't any .mat files in this directory, assume we're in a
% directory with folders of years; descend to try to find the file
if isempty(mat_files)
	sourcedir = fullfile(sourcedir, sprintf('%04d', date_year), ...
		sprintf('%02d_%02d', date_month, date_day));
	
	mat_files = dir(fullfile(sourcedir, '*.mat'));
end


%% Scan through all the files to find the right one

if isempty(mat_files)
	error('No .mat files found in %s', sourcedir);
end

for kk = 1:length(mat_files)
	[start_time, end_time] = get_file_times(fullfile(sourcedir, mat_files(kk).name));
	if date >= start_time && date <= end_time
		filename = fullfile(sourcedir, mat_files(kk).name);
		file_start_time = start_time;
		file_end_time = end_time;
		return;
	end
end

error('Unable to find file containing date %s', datestr(date));

%% Function: get_file_times
function [start_time, end_time] = get_file_times(filename)
[fid, message] = fopen(filename, 'r');
if fid == -1, error('Error opening %s: %s', filename, message); end;

% Load all variables except for 'data', and get information about all
% variables
matLoadExcept(fid, 'data');
[varNames, varTypes, varOffsets, varDimensions] = matGetVarInfo(fid);


if ~exist('fs', 'var')
	if exist('channel_sampling_freq', 'var')
		fs = channel_sampling_freq(1);
	elseif exist('Fs', 'var')
		fs = Fs(1);
	else
		error('Unknown sampling frequency');
	end
end
% In Summer 2004 data, fs is reported as being 20 kHz, which is wrong; it's
% actually 100 kHz (verified with Chistochina 2004-07-23 0300).
if fs == 20000
	fs = 100e3;
end

% Is the data interleaved?
dataIndex = find(strcmp(varNames, 'data'));
dataDims = varDimensions(dataIndex,:);
if min(dataDims) == 1 && exist('num_channels', 'var') && num_channels == 2
	isInterleaved = true;
else
	% This line may not be true; the num_channels variable may not exist or
	% may be called something else.
	warning('''num_channels'' variable does not exist; assuming non-interleaved data (without proof)'); %#ok<WNTAG>
	isInterleaved = false;
end

start_time = datenum([start_year, start_month, start_day, start_hour, start_minute, start_second]);
if isInterleaved
	end_time = start_time + (1/86400)*max(dataDims)/2/fs;
else
	end_time = start_time + (1/86400)*max(dataDims)/fs;
end
