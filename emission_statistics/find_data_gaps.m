function [synoptic_epochs, b_data] = find_data_gaps(varargin)
% [synoptic_epochs, b_data] = find_data_gaps(year)
% [synoptic_epochs, b_data] = find_data_gaps(start_datenum, end_datenum)
% Find data gaps in cleaned data on scott

% By Daniel Golden (dgolden1) September 2010
% $Id$

%% Setup
b_all_dates = (nargin == 0);
if b_all_dates
  start_datenum = datenum([2000 1 1 0 0 0]);
  end_datenum = floor(now);
elseif nargin == 1
	start_datenum = datenum([varargin{1} 01 01 0 05 0]);
	end_datenum = datenum([varargin{1} 12 31 23 50 0]);
elseif nargin == 2
	start_datenum = varargin{1};
	end_datenum = varargin{2};
else
	error('Wrong number of arguments (%d)', nargin);
end

[start_year, ~] = datevec(start_datenum);
[end_year, ~] = datevec(end_datenum);

% Round to the nearest synoptic minute
start_datenum = round((start_datenum - 5/1440)*96)/96 + 5/1440;
end_datenum = floor((end_datenum - 5/1440)*96)/96 + 5/1440;

synoptic_epochs = (start_datenum:15/1440:end_datenum).'; % Synoptic dates at 5, 20, 35, 50 after the hour
b_data = false(size(synoptic_epochs));

% source_dir = sprintf('/media/scott/user_data/dgolden/palmer_bb_cleaned');
source_dir = sprintf('/data/user_data/dgolden/palmer_bb_cleaned');

%% Run
t_net_start = now;

d = dir(source_dir);

full_filelist = [];
for kk = 1:length(d)
  t_start = now;
  
  this_year = str2double(d(kk).name);
  if ~(this_year >= start_year && this_year <= end_year)
    continue;
  end
  
  this_source_dir = fullfile(source_dir, d(kk).name);
  
  % Find all cleaned files in this directory
  find_cmd = sprintf('find %s -iname "*.mat" | sort', this_source_dir);
  [~, filelist_str] = unix(find_cmd);
  filelist = textscan(filelist_str, '%s');
  filelist = filelist{1};
  
  full_filelist = [full_filelist; filelist];
  
  disp(sprintf('Found %d files in %s in %s', length(filelist), this_source_dir, time_elapsed(t_start, now)));
end

for kk = 1:length(full_filelist)
  file_datenum = get_bb_fname_datenum(full_filelist{kk});
  
  offsets = abs(synoptic_epochs - file_datenum);
  b_data(offsets <= 10/86400) = true; % Any synoptic epoch with data within 10 seconds is true
end

fprintf('Processed %d files in %s\n', length(full_filelist), time_elapsed(t_net_start, now));
