function [date, dst] = dst_read_datenum(varargin)
% [date, dst] = dst_read_datenum(year)
% [date, dst] = dst_read_datenum(start_datenum, end_datenum)
% [date, dst] = dst_read_datenum(start_datenum, end_datenum, filename)
% Function to parse DST data from the Kyoto web site
% 
% Acquire data from here: http://swdcwww.kugi.kyoto-u.ac.jp/dstae/index.html
% Data format: http://swdcwww.kugi.kyoto-u.ac.jp/dstae/format/dstformat.html

% By Daniel Golden (dgolden1 at stanford dot edu) Oct 18, 2007
% $Id$

%% Parse input args
if nargin < 1
	error('Not enough input arguments');
elseif nargin < 2
	year = varargin{1};
	filename = [];
elseif nargin < 3
	start_datenum = varargin{1};
	end_datenum = varargin{2};
	[year m d hh mm ss] = datevec(start_datenum);
	filename = [];
elseif nargin < 4
	start_datenum = varargin{1};
	end_datenum = varargin{2};
	filename = varargin{3};
else
	error('Too many input arguments (%d > 2)', nargin);
end

%% Choose DST filename
filename = sprintf('dst_%04d.txt', year);

[fid, message] = fopen(filename);
if fid == -1
	error('Error reading %s: %s', filename, message);
end

%% Preallocate dst matrix

% Count lines
numlines = 0;
while ~feof(fid)
	line = fgetl(fid);
	if length(line) < 3, continue; end
	
	% Each line begins with the text 'DST'
	if strcmp(line(1:3), 'DST')
		numlines = numlines + 1;
	end
end
frewind(fid); % Rewind file

% Preallocate output matrices
date = zeros(numlines, 1);
dst = zeros(numlines, 24);


%% Parse file
lineno = 1;
while ~feof(fid)
	% Grab one line at a time. If it's not a complete line, assume we're
	% done
	line = fgetl(fid);
	if length(line) < 120
		break;
	end

	% Grab raw values
	assert(strcmp(line(1:3), 'DST'));
	year_bot_str = line(4:5);
	mon_str = line(6:7);
	assert(strcmp(line(8), '*'));
	day_str = line(9:10);
	assert(strcmp(line(13), 'X'));
	version_str = line(14);
	year_top_str = line(15:16);
	base_val_str = line(17:20);
	
	dst_vals = zeros(1, 24);
	pos = 21;
	for kk = 1:24
		dst_vals(kk) = str2double(line(pos:pos+3));
		pos = pos + 4;
	end
	
	mean_val = str2double(line(117:120));
	
	% Write to output vectors
	year = str2double([year_top_str year_bot_str]);
	month = str2double(mon_str);
	day = str2double(day_str);
	date(lineno) = datenum([year month day 0 0 0]);
	dst(lineno, :) = dst_vals;
	
	lineno = lineno + 1;
end

% Convert nx24 dst values (with day down rows and hour across columns) to a linear array
date = linspace(date(1), date(end)+1 - 1/24, length(date)*24);
% date = date + 1/24; % the first value for each row is the average from hour 00:00 to 01:00
dst = reshape(dst.', numel(dst), 1);
date = reshape(date.', numel(date), 1);

%% Parse out requested dates (if given)
if ~exist('start_datenum', 'var')
	return;
end

dst = dst(date >= start_datenum & date <= end_datenum);
date = date(date >= start_datenum & date <= end_datenum);
